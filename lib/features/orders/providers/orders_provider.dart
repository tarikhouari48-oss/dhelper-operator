import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/firebase_service.dart';

final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchOrders();
});

final orderStatusFilterProvider = StateProvider<OrderStatus?>((ref) => null);

final filteredOrdersProvider = Provider<AsyncValue<List<OrderModel>>>((ref) {
  final orders = ref.watch(ordersStreamProvider);
  final filter = ref.watch(orderStatusFilterProvider);

  return orders.whenData(
    (list) => filter == null ? list : list.where((o) => o.status == filter).toList(),
  );
});
