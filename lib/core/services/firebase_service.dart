import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/driver_model.dart';
import '../models/restaurant_model.dart';

const _dbUrl = 'https://d-helper-f1331-default-rtdb.firebaseio.com';

// Restaurant coords — Carrer de Provença 78, Barcelona
const _restLat = 41.3917;
const _restLng = 2.1649;
const _maxOrdersPerDriver = 3;

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

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
  final _client = http.Client();

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

  // --- Orders (Firebase Realtime Database) ---

  // Local cache updated by the watchOrders stream for synchronous reads
  List<OrderModel> _cachedOrders = [];

  // driverId → number of non-delivered active orders
  final Map<String, int> _driverActiveOrders = {};

  FirebaseService() {
    _drivers = _seedDrivers();
    _startGpsSimulation();
  }

  // ── Auto-assignment helpers ───────────────────────────────────────────────

  static double _distToRestaurant(DriverAccount d) {
    if (d.lat == null || d.lng == null) return 99999;
    final dlat = d.lat! - _restLat;
    final dlng = d.lng! - _restLng;
    return sqrt(dlat * dlat + dlng * dlng);
  }

  DriverAccount? _findBestDriver() {
    final available = _drivers.where((d) {
      if (!d.isOnline) return false;
      if ((_driverActiveOrders[d.id] ?? 0) >= _maxOrdersPerDriver) return false;
      // Block driver if they have any pickedUp order (delivering mode)
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

  Stream<List<OrderModel>> watchOrders() async* {
    while (true) {
      try {
        final res = await _client
            .get(Uri.parse('$_dbUrl/orders.json'))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200 && res.body != 'null') {
          final map = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
          final orders = map.entries.map((e) {
            final m = Map<String, dynamic>.from(e.value as Map);
            if (m['id'] == null || (m['id'] as String).isEmpty) m['id'] = e.key;
            return OrderModel.fromMap(m);
          }).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _cachedOrders = orders;
          yield orders;
        } else {
          _cachedOrders = [];
          yield [];
        }
      } catch (_) {
        yield _cachedOrders;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<String> createOrder(OrderModel order) async {
    final driver = _findBestDriver();
    final status = driver != null ? OrderStatus.accepted : OrderStatus.pending;
    final withId = OrderModel(
      id: '',
      customerName: order.customerName,
      phoneNumber: order.phoneNumber,
      deliveryAddress: order.deliveryAddress,
      deliveryLat: order.deliveryLat,
      deliveryLng: order.deliveryLng,
      items: order.items,
      paymentType: order.paymentType,
      status: status,
      createdAt: DateTime.now(),
      operatorId: 'local',
      driverId: driver?.id,
      fromCall: order.fromCall,
    );
    if (driver != null) {
      _driverActiveOrders[driver.id] = (_driverActiveOrders[driver.id] ?? 0) + 1;
    }
    final res = await _client.post(
      Uri.parse('$_dbUrl/orders.json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(withId.toMap()),
    );
    final key = (jsonDecode(res.body) as Map)['name'] as String;
    await _client.patch(
      Uri.parse('$_dbUrl/orders/$key.json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': key}),
    );
    return key;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final body = <String, dynamic>{'status': status.name};
    if (status == OrderStatus.pickedUp) {
      body['pickedUpAt'] = DateTime.now().millisecondsSinceEpoch;
    }
    if (status == OrderStatus.delivered) {
      body['deliveredAt'] = DateTime.now().millisecondsSinceEpoch;
      final res = await _client.get(Uri.parse('$_dbUrl/orders/$orderId.json'));
      if (res.statusCode == 200 && res.body != 'null') {
        final order = OrderModel.fromMap(Map<String, dynamic>.from(jsonDecode(res.body) as Map));
        final driverId = order.driverId;
        if (driverId != null) {
          final current = _driverActiveOrders[driverId] ?? 1;
          _driverActiveOrders[driverId] = (current - 1).clamp(0, _maxOrdersPerDriver);
          final di = _drivers.indexWhere((d) => d.id == driverId);
          if (di != -1) {
            _drivers[di] = _drivers[di].copyWith(
              todayDeliveries: _drivers[di].todayDeliveries + 1,
              todayEarnings: _drivers[di].todayEarnings + order.total,
            );
            _driversCtrl.add(List.unmodifiable(_drivers));
          }
        }
      }
    }
    await _client.patch(
      Uri.parse('$_dbUrl/orders/$orderId.json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // --- Stats ---
  PlatformStats computeStats(String period) {
    final now = DateTime.now();
    final delivered = _cachedOrders.where((o) => o.status == OrderStatus.delivered);

    Iterable<OrderModel> filtered;
    switch (period) {
      case 'month':
        filtered = delivered.where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month);
        break;
      case 'year':
        filtered = delivered.where((o) => o.createdAt.year == now.year);
        break;
      default: // 'today'
        filtered = delivered.where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day);
    }

    final list = filtered.toList();
    if (list.isEmpty) return const PlatformStats();

    final cashList = list.where((o) => o.paymentType == PaymentType.cash).toList();
    final cardList = list.where((o) => o.paymentType == PaymentType.card).toList();
    final times = list.where((o) => o.deliveryMinutes != null).map((o) => o.deliveryMinutes!).toList();

    return PlatformStats(
      totalOrders: list.length,
      fromCalls: list.where((o) => o.fromCall).length,
      cashOrders: cashList.length,
      cashAmount: cashList.fold(0.0, (s, o) => s + o.total),
      cardOrders: cardList.length,
      cardAmount: cardList.fold(0.0, (s, o) => s + o.total),
      totalEarnings: list.fold(0.0, (s, o) => s + o.total),
      avgDeliveryMinutes: times.isEmpty ? 0 : times.reduce((a, b) => a + b) / times.length,
    );
  }

  // --- Drivers ---
  late List<DriverAccount> _drivers;
  final _driversCtrl = StreamController<List<DriverAccount>>.broadcast();

  Future<void> addDriver({
    required String name,
    required String email,
    required String phone,
    required DriverVehicleType vehicleType,
    required String password,
  }) async {
    final id = 'drv-${DateTime.now().millisecondsSinceEpoch}';
    _drivers.insert(0, DriverAccount(
      id: id,
      name: name,
      email: email.toLowerCase(),
      phone: phone,
      vehicleType: vehicleType,
    ));
    _driversCtrl.add(List.unmodifiable(_drivers));
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    _driversCtrl.add(List.unmodifiable(_drivers));
  }

  Stream<List<DriverAccount>> watchDrivers() {
    Future.microtask(() => _driversCtrl.add(List.unmodifiable(_drivers)));
    return _driversCtrl.stream;
  }

  Future<void> initNotifications() async {}

  // ── Restaurant settings ───────────────────────────────────────────────────

  Future<Map<String, String>> getRestaurantSettings() async {
    try {
      final res = await _client
          .get(Uri.parse('$_dbUrl/settings/restaurant.json'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 && res.body != 'null') {
        final m = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
        return {
          'name':    m['name']?.toString()    ?? '',
          'address': m['address']?.toString() ?? '',
          'phone':   m['phone']?.toString()   ?? '',
          'hours':   m['hours']?.toString()   ?? '',
        };
      }
    } catch (_) {}
    return {'name': '', 'address': '', 'phone': '', 'hours': ''};
  }

  Future<void> saveRestaurantSettings({
    required String name,
    required String address,
    required String phone,
    required String hours,
  }) async {
    await _client.put(
      Uri.parse('$_dbUrl/settings/restaurant.json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'address': address, 'phone': phone, 'hours': hours}),
    );
  }

  // ── GPS simulation ────────────────────────────────────────────────────────
  // Moves online drivers by a small random amount every 5 s and writes to Firebase.
  Timer? _gpsSimTimer;

  void _startGpsSimulation() {
    final rng = Random();
    _gpsSimTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      bool changed = false;
      for (int i = 0; i < _drivers.length; i++) {
        final d = _drivers[i];
        if (!d.isOnline || d.lat == null || d.lng == null) continue;
        final dlat = (rng.nextDouble() - 0.5) * 0.00018;
        final dlng = (rng.nextDouble() - 0.5) * 0.00018;
        _drivers[i] = d.copyWith(lat: d.lat! + dlat, lng: d.lng! + dlng);
        // Write to Firebase REST
        _client.patch(
          Uri.parse('$_dbUrl/drivers/${d.id}.json'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'lat': _drivers[i].lat,
            'lng': _drivers[i].lng,
            'isOnline': true,
            'name': d.name,
            'id': d.id,
          }),
        );
        changed = true;
      }
      if (changed) _driversCtrl.add(List.unmodifiable(_drivers));
    });
  }

  // Helper: name of assigned driver for display in order list
  String? driverName(String? driverId) {
    if (driverId == null) return null;
    try {
      return _drivers.firstWhere((d) => d.id == driverId).name;
    } catch (_) {
      return null;
    }
  }

  // --- Restaurants ---
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

  // --- Chart data ---
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

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------
  static List<DriverAccount> _seedDrivers() => [
        const DriverAccount(
          id: 'drv-seed-1',
          name: 'Ahmed Benali',
          email: 'ahmed@dhelper.com',
          phone: '+34 611 111 111',
          vehicleType: DriverVehicleType.motorcycle,
          isOnline: true,
          lat: 41.3938,
          lng: 2.1618,
          todayDeliveries: 7,
          todayEarnings: 98.50,
        ),
        const DriverAccount(
          id: 'drv-seed-2',
          name: 'Juan García',
          email: 'juan@dhelper.com',
          phone: '+34 622 222 222',
          vehicleType: DriverVehicleType.motorcycle,
          isOnline: true,
          lat: 41.3851,
          lng: 2.1960,
          todayDeliveries: 5,
          todayEarnings: 74.00,
        ),
        const DriverAccount(
          id: 'drv-seed-3',
          name: 'María López',
          email: 'maria@dhelper.com',
          phone: '+34 633 333 333',
          vehicleType: DriverVehicleType.bike,
          isOnline: false,
          lat: 41.3845,
          lng: 2.1320,
          todayDeliveries: 3,
          todayEarnings: 41.50,
        ),
      ];
}
