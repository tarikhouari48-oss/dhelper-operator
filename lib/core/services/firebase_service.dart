import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/driver_model.dart';
import '../models/restaurant_model.dart';

const _restLat = 41.3917;
const _restLng = 2.1649;
const _maxOrdersPerDriver = 3;

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

SupabaseClient get _db => Supabase.instance.client;

// ---------------------------------------------------------------------------
// Stats model
// ---------------------------------------------------------------------------
class PlatformStats {
  final int totalOrders;
  final int fromCalls;
  final int cashOrders;
  final double cashAmount;
  final int cardOrders;
  final double cardAmount;
  final double totalEarnings;
  final double avgDeliveryMinutes;

  const PlatformStats({
    this.totalOrders = 0,
    this.fromCalls = 0,
    this.cashOrders = 0,
    this.cashAmount = 0,
    this.cardOrders = 0,
    this.cardAmount = 0,
    this.totalEarnings = 0,
    this.avgDeliveryMinutes = 0,
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------
class FirebaseService {
  // --- Operator auth (mock) ---
  static const _adminEmail = 'admin@dhelper.com';
  static const _adminPassword = 'admin123';
  String? _resetCode;

  bool login(String email, String password) =>
      email.toLowerCase() == _adminEmail && password == _adminPassword;

  String generateResetCode(String email) {
    if (email.toLowerCase() != _adminEmail) return '';
    final code = (100000 + Random().nextInt(900000)).toString();
    _resetCode = code;
    return code;
  }

  bool validateResetCode(String code) => code == _resetCode;
  void clearResetCode() => _resetCode = null;

  // --- Caches ---
  List<OrderModel> _cachedOrders = [];
  List<DriverAccount> _cachedDrivers = [];
  final Map<String, int> _driverActiveOrders = {};

  FirebaseService() {
    _initDrivers();
    _startGpsSimulation();
  }

  // --- Driver helpers ---

  static DriverAccount _driverFromRow(Map<String, dynamic> r) => DriverAccount(
        id: r['id']?.toString() ?? '',
        name: r['name']?.toString() ?? '',
        email: r['email']?.toString() ?? '',
        phone: r['phone']?.toString() ?? '',
        vehicleType: r['vehicle_type'] == 'motorcycle'
            ? DriverVehicleType.motorcycle
            : DriverVehicleType.bike,
        isOnline: r['is_online'] as bool? ?? false,
        lat: (r['lat'] as num?)?.toDouble(),
        lng: (r['lng'] as num?)?.toDouble(),
        todayDeliveries: (r['today_deliveries'] as num?)?.toInt() ?? 0,
        todayEarnings: (r['today_earnings'] as num?)?.toDouble() ?? 0,
      );

  Future<void> _initDrivers() async {
    try {
      final rows = await _db.from('drivers').select();
      final list = rows as List<dynamic>;
      if (list.isEmpty) {
        await _seedDrivers();
        final seeded = await _db.from('drivers').select();
        _cachedDrivers = (seeded as List<dynamic>)
            .map((r) => _driverFromRow(Map<String, dynamic>.from(r as Map)))
            .toList();
      } else {
        _cachedDrivers = list
            .map((r) => _driverFromRow(Map<String, dynamic>.from(r as Map)))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _seedDrivers() async {
    await _db.from('drivers').upsert([
      {
        'id': 'drv-seed-1',
        'name': 'Ahmed Benali',
        'email': 'ahmed@dhelper.com',
        'phone': '+34 611 111 111',
        'vehicle_type': 'motorcycle',
        'is_online': true,
        'lat': 41.3938,
        'lng': 2.1618,
        'today_deliveries': 7,
        'today_earnings': 98.50,
      },
      {
        'id': 'drv-seed-2',
        'name': 'Juan García',
        'email': 'juan@dhelper.com',
        'phone': '+34 622 222 222',
        'vehicle_type': 'motorcycle',
        'is_online': true,
        'lat': 41.3851,
        'lng': 2.1960,
        'today_deliveries': 5,
        'today_earnings': 74.00,
      },
      {
        'id': 'drv-seed-3',
        'name': 'María López',
        'email': 'maria@dhelper.com',
        'phone': '+34 633 333 333',
        'vehicle_type': 'bike',
        'is_online': false,
        'lat': 41.3845,
        'lng': 2.1320,
        'today_deliveries': 3,
        'today_earnings': 41.50,
      },
    ]);
  }

  // ── Auto-assignment helpers ───────────────────────────────────────────────

  static double _distToRestaurant(DriverAccount d) {
    if (d.lat == null || d.lng == null) return 99999;
    final dlat = d.lat! - _restLat;
    final dlng = d.lng! - _restLng;
    return sqrt(dlat * dlat + dlng * dlng);
  }

  DriverAccount? _findBestDriver() {
    final available = _cachedDrivers.where((d) {
      if (!d.isOnline) return false;
      if ((_driverActiveOrders[d.id] ?? 0) >= _maxOrdersPerDriver) return false;
      final isDelivering = _cachedOrders.any(
        (o) => o.driverId == d.id && o.status == OrderStatus.pickedUp,
      );
      return !isDelivering;
    }).toList();
    if (available.isEmpty) return null;
    available.sort((a, b) {
      final byOrders = (_driverActiveOrders[a.id] ?? 0)
          .compareTo(_driverActiveOrders[b.id] ?? 0);
      if (byOrders != 0) return byOrders;
      return _distToRestaurant(a).compareTo(_distToRestaurant(b));
    });
    return available.first;
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> watchOrders() {
    return _db
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          final orders = rows.map((r) => OrderModel.fromSupabase(r)).toList();
          _cachedOrders = orders;
          return orders;
        });
  }

  Future<String> createOrder(OrderModel order) async {
    final driver = _findBestDriver();
    final status = driver != null ? OrderStatus.accepted : OrderStatus.pending;
    if (driver != null) {
      _driverActiveOrders[driver.id] = (_driverActiveOrders[driver.id] ?? 0) + 1;
    }
    final toInsert = {
      'customer_name':    order.customerName,
      'phone_number':     order.phoneNumber,
      'delivery_address': order.deliveryAddress,
      'delivery_lat':     order.deliveryLat,
      'delivery_lng':     order.deliveryLng,
      'items':            order.items.map((i) => i.toJson()).toList(),
      'status':           status.name,
      'created_at':       DateTime.now().millisecondsSinceEpoch,
      'payment_type':     order.paymentType.name,
      'operator_id':      order.operatorId,
      'driver_id':        driver?.id,
      'from_call':        order.fromCall,
    };
    final row = await _db.from('orders').insert(toInsert).select().single();
    return row['id'].toString();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final body = <String, dynamic>{'status': status.name};
    if (status == OrderStatus.pickedUp) {
      body['picked_up_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    if (status == OrderStatus.delivered) {
      body['delivered_at'] = DateTime.now().millisecondsSinceEpoch;
      final matching = _cachedOrders.where((o) => o.id == orderId);
      if (matching.isNotEmpty) {
        final order = matching.first;
        final driverId = order.driverId;
        if (driverId != null) {
          final di = _cachedDrivers.indexWhere((d) => d.id == driverId);
          if (di != -1) {
            final d = _cachedDrivers[di];
            await _db.from('drivers').update({
              'today_deliveries': d.todayDeliveries + 1,
              'today_earnings':   d.todayEarnings + order.total,
            }).eq('id', driverId);
          }
          final current = _driverActiveOrders[driverId] ?? 1;
          _driverActiveOrders[driverId] = (current - 1).clamp(0, _maxOrdersPerDriver);
        }
      }
    }
    await _db.from('orders').update(body).eq('id', orderId);
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  PlatformStats computeStats(String period) {
    final now = DateTime.now();
    final delivered = _cachedOrders.where((o) => o.status == OrderStatus.delivered);

    Iterable<OrderModel> filtered;
    switch (period) {
      case 'month':
        filtered = delivered.where(
            (o) => o.createdAt.year == now.year && o.createdAt.month == now.month);
        break;
      case 'year':
        filtered = delivered.where((o) => o.createdAt.year == now.year);
        break;
      default:
        filtered = delivered.where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day);
    }

    final list = filtered.toList();
    if (list.isEmpty) return const PlatformStats();

    final cashList = list.where((o) => o.paymentType == PaymentType.cash).toList();
    final cardList = list.where((o) => o.paymentType == PaymentType.card).toList();
    final times = list
        .where((o) => o.deliveryMinutes != null)
        .map((o) => o.deliveryMinutes!)
        .toList();

    return PlatformStats(
      totalOrders: list.length,
      fromCalls: list.where((o) => o.fromCall).length,
      cashOrders: cashList.length,
      cashAmount: cashList.fold(0.0, (s, o) => s + o.total),
      cardOrders: cardList.length,
      cardAmount: cardList.fold(0.0, (s, o) => s + o.total),
      totalEarnings: list.fold(0.0, (s, o) => s + o.total),
      avgDeliveryMinutes:
          times.isEmpty ? 0 : times.reduce((a, b) => a + b) / times.length,
    );
  }

  // ── Drivers ───────────────────────────────────────────────────────────────

  Stream<List<DriverAccount>> watchDrivers() {
    return _db
        .from('drivers')
        .stream(primaryKey: ['id'])
        .map((rows) {
          _cachedDrivers = rows
              .map((r) => _driverFromRow(Map<String, dynamic>.from(r as Map)))
              .toList();
          return List<DriverAccount>.unmodifiable(_cachedDrivers);
        });
  }

  Future<void> addDriver({
    required String name,
    required String email,
    required String phone,
    required DriverVehicleType vehicleType,
    required String password,
  }) async {
    final id = 'drv-${DateTime.now().millisecondsSinceEpoch}';
    await _db.from('drivers').insert({
      'id':               id,
      'name':             name,
      'email':            email.toLowerCase(),
      'phone':            phone,
      'vehicle_type':     vehicleType.name,
      'is_online':        false,
      'today_deliveries': 0,
      'today_earnings':   0.0,
    });
  }

  Future<void> deleteDriver(String id) async {
    await _db.from('drivers').delete().eq('id', id);
  }

  String? driverName(String? driverId) {
    if (driverId == null) return null;
    try {
      return _cachedDrivers.firstWhere((d) => d.id == driverId).name;
    } catch (_) {
      return null;
    }
  }

  Future<void> initNotifications() async {}

  // ── Restaurant settings ───────────────────────────────────────────────────

  static Future<(double?, double?)> _geocode(String address) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': address, 'format': 'json', 'limit': '1',
      });
      final response = await http.get(uri, headers: {'User-Agent': 'DHelperApp/1.0'});
      if (response.statusCode != 200) return (null, null);
      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) return (null, null);
      final first = data.first as Map<String, dynamic>;
      return (
        double.tryParse(first['lat']?.toString() ?? ''),
        double.tryParse(first['lon']?.toString() ?? ''),
      );
    } catch (_) {
      return (null, null);
    }
  }

  Future<Map<String, dynamic>> getRestaurantSettings() async {
    try {
      final rows = await _db
          .from('restaurant_settings')
          .select()
          .eq('id', 'restaurant');
      if ((rows as List).isEmpty) {
        return {'name': '', 'address': '', 'phone': '', 'hours': '', 'lat': null, 'lng': null};
      }
      final r = rows.first as Map<String, dynamic>;
      return {
        'name':    r['name']?.toString()    ?? '',
        'address': r['address']?.toString() ?? '',
        'phone':   r['phone']?.toString()   ?? '',
        'hours':   r['hours']?.toString()   ?? '',
        'lat':     (r['lat'] as num?)?.toDouble(),
        'lng':     (r['lng'] as num?)?.toDouble(),
      };
    } catch (_) {
      return {'name': '', 'address': '', 'phone': '', 'hours': '', 'lat': null, 'lng': null};
    }
  }

  Future<void> saveRestaurantSettings({
    required String name,
    required String address,
    required String phone,
    required String hours,
  }) async {
    final (lat, lng) = await _geocode(address);
    final data = <String, dynamic>{
      'id':      'restaurant',
      'name':    name,
      'address': address,
      'phone':   phone,
      'hours':   hours,
    };
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    await _db.from('restaurant_settings').upsert(data);
  }

  // ── GPS simulation ────────────────────────────────────────────────────────
  Timer? _gpsSimTimer;

  void _startGpsSimulation() {
    final rng = Random();
    _gpsSimTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      for (final d in List<DriverAccount>.from(_cachedDrivers)) {
        if (!d.isOnline || d.lat == null || d.lng == null) continue;
        final dlat = (rng.nextDouble() - 0.5) * 0.00018;
        final dlng = (rng.nextDouble() - 0.5) * 0.00018;
        _db.from('drivers').update({
          'lat': d.lat! + dlat,
          'lng': d.lng! + dlng,
        }).eq('id', d.id);
      }
    });
  }

  // ── Restaurants (in-memory) ───────────────────────────────────────────────

  final List<RestaurantAccount> _restaurants = [
    const RestaurantAccount(
      id: 'rst-seed-1',
      name: 'D-helper Kitchen',
      address: 'Carrer de Balmes 120, Barcelona',
      phone: '+34 931 000 001',
      email: 'kitchen@dhelper.com',
    ),
    const RestaurantAccount(
      id: 'rst-seed-2',
      name: 'Kebab Palace',
      address: 'Gran Via 300, Barcelona',
      phone: '+34 931 000 002',
      email: 'kebab@dhelper.com',
    ),
  ];
  final _restaurantsCtrl = StreamController<List<RestaurantAccount>>.broadcast();

  Future<void> addRestaurant({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    final id = 'rst-${DateTime.now().millisecondsSinceEpoch}';
    _restaurants.insert(0, RestaurantAccount(
      id: id,
      name: name,
      address: address,
      phone: phone,
      email: email,
    ));
    _restaurantsCtrl.add(List.unmodifiable(_restaurants));
  }

  Future<void> deleteRestaurant(String id) async {
    _restaurants.removeWhere((r) => r.id == id);
    _restaurantsCtrl.add(List.unmodifiable(_restaurants));
  }

  Stream<List<RestaurantAccount>> watchRestaurants() {
    Future.microtask(() => _restaurantsCtrl.add(List.unmodifiable(_restaurants)));
    return _restaurantsCtrl.stream;
  }

  // ── Chart data ────────────────────────────────────────────────────────────

  List<int> ordersLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _cachedOrders
          .where((o) =>
              o.createdAt.year == day.year &&
              o.createdAt.month == day.month &&
              o.createdAt.day == day.day)
          .length;
    });
  }
}
