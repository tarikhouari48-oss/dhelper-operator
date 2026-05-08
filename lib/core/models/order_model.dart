enum OrderStatus { pending, accepted, preparing, ready, pickedUp, delivered, rejected }

enum PaymentType { cash, card, bizum }

class FoodItem {
  final String name;
  final int quantity;
  final double price;

  const FoodItem({required this.name, required this.quantity, required this.price});

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'price': price};

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );
}

class OrderModel {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final List<FoodItem> items;
  final PaymentType paymentType;
  final OrderStatus status;
  final DateTime createdAt;
  final String operatorId;
  final String? driverId;
  final bool fromCall;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.items,
    required this.paymentType,
    required this.status,
    required this.createdAt,
    required this.operatorId,
    this.driverId,
    this.fromCall = false,
    this.pickedUpAt,
    this.deliveredAt,
  });

  double get total => items.fold(0.0, (s, i) => s + i.price * i.quantity);

  int? get deliveryMinutes {
    if (pickedUpAt == null || deliveredAt == null) return null;
    return deliveredAt!.difference(pickedUpAt!).inMinutes;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'deliveryAddress': deliveryAddress,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'paymentType': paymentType.name,
        'operatorId': operatorId,
        'driverId': driverId,
        'fromCall': fromCall,
        'pickedUpAt': pickedUpAt?.millisecondsSinceEpoch,
        'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      };

  Map<String, dynamic> toSupabase() => {
        'customer_name':    customerName,
        'phone_number':     phoneNumber,
        'delivery_address': deliveryAddress,
        'delivery_lat':     deliveryLat,
        'delivery_lng':     deliveryLng,
        'items':            items.map((i) => i.toJson()).toList(),
        'status':           status.name,
        'created_at':       createdAt.millisecondsSinceEpoch,
        'payment_type':     paymentType.name,
        'operator_id':      operatorId,
        'driver_id':        driverId,
        'from_call':        fromCall,
      };

  factory OrderModel.fromSupabase(Map<String, dynamic> r) => OrderModel(
        id:              r['id']?.toString() ?? '',
        customerName:    r['customer_name']?.toString() ?? '',
        phoneNumber:     r['phone_number']?.toString() ?? '',
        deliveryAddress: r['delivery_address']?.toString() ?? '',
        deliveryLat:     (r['delivery_lat'] as num?)?.toDouble(),
        deliveryLng:     (r['delivery_lng'] as num?)?.toDouble(),
        items: (r['items'] as List<dynamic>? ?? [])
            .map((i) => FoodItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
        status: OrderStatus.values.firstWhere(
          (s) => s.name == r['status'],
          orElse: () => OrderStatus.pending,
        ),
        paymentType: PaymentType.values.firstWhere(
          (p) => p.name == r['payment_type'],
          orElse: () => PaymentType.cash,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (r['created_at'] as num?)?.toInt() ?? 0),
        operatorId: r['operator_id']?.toString() ?? 'local',
        driverId:   r['driver_id']?.toString(),
        fromCall:   r['from_call'] as bool? ?? false,
        pickedUpAt: r['picked_up_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch((r['picked_up_at'] as num).toInt())
            : null,
        deliveredAt: r['delivered_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch((r['delivered_at'] as num).toInt())
            : null,
      );

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
        id: m['id']?.toString() ?? '',
        customerName: m['customerName']?.toString() ?? '',
        phoneNumber: m['phoneNumber']?.toString() ?? '',
        deliveryAddress: m['deliveryAddress']?.toString() ?? '',
        deliveryLat: (m['deliveryLat'] as num?)?.toDouble(),
        deliveryLng: (m['deliveryLng'] as num?)?.toDouble(),
        items: (m['items'] as List<dynamic>?)
                ?.map((i) => FoodItem.fromJson(Map<String, dynamic>.from(i as Map)))
                .toList() ??
            [],
        status: OrderStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => OrderStatus.pending,
        ),
        paymentType: PaymentType.values.firstWhere(
          (p) => p.name == m['paymentType'],
          orElse: () => PaymentType.cash,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] as num?)?.toInt() ?? 0),
        operatorId: m['operatorId']?.toString() ?? 'local',
        driverId: m['driverId']?.toString(),
        fromCall: m['fromCall'] as bool? ?? false,
        pickedUpAt: m['pickedUpAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch((m['pickedUpAt'] as num).toInt())
            : null,
        deliveredAt: m['deliveredAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch((m['deliveredAt'] as num).toInt())
            : null,
      );

  OrderModel copyWith({
    OrderStatus? status,
    String? driverId,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) =>
      OrderModel(
        id: id,
        customerName: customerName,
        phoneNumber: phoneNumber,
        deliveryAddress: deliveryAddress,
        deliveryLat: deliveryLat,
        deliveryLng: deliveryLng,
        items: items,
        paymentType: paymentType,
        status: status ?? this.status,
        createdAt: createdAt,
        operatorId: operatorId,
        driverId: driverId ?? this.driverId,
        fromCall: fromCall,
        pickedUpAt: pickedUpAt ?? this.pickedUpAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
      );
}
