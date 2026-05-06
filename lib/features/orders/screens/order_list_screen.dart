import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../core/models/order_model.dart';
import '../providers/orders_provider.dart';

const _green = Color(0xFF10B981);

// Orders tab body — used inside MainScreen's IndexedStack
class OrdersContent extends ConsumerWidget {
  const OrdersContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final allOrdersAsync = ref.watch(ordersStreamProvider);
    final filteredAsync = ref.watch(filteredOrdersProvider);

    return Column(
      children: [
        allOrdersAsync.when(
          data: (orders) => _StatsHeader(orders: orders, l10n: l10n),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        _StatusFilterBar(),
        Expanded(
          child: filteredAsync.when(
            data: (orders) => orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(l10n.noOrdersYet, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error)),
          ),
        ),
      ],
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final List<OrderModel> orders;
  final AppLocalizations l10n;
  const _StatsHeader({required this.orders, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final pending = orders.where((o) => o.status == OrderStatus.pending).length;
    final active = orders.where((o) => [OrderStatus.accepted, OrderStatus.preparing, OrderStatus.ready, OrderStatus.pickedUp].contains(o.status)).length;
    final done = orders.where((o) => o.status == OrderStatus.delivered).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _StatPill(label: l10n.pending, count: pending, color: Colors.orange),
          const SizedBox(width: 8),
          _StatPill(label: 'En curso', count: active, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          _StatPill(label: 'Entregados', count: done, color: _green),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(orderStatusFilterProvider);

    final filters = <OrderStatus?, String>{
      null: l10n.all,
      OrderStatus.pending: l10n.pending,
      OrderStatus.accepted: l10n.accepted,
      OrderStatus.preparing: l10n.preparing,
      OrderStatus.ready: l10n.ready,
    };

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: filters.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(e.value),
              selected: selected == e.key,
              onSelected: (_) => ref.read(orderStatusFilterProvider.notifier).state = e.key,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.accepted => const Color(0xFF2563EB),
        OrderStatus.preparing => Colors.purple,
        OrderStatus.ready => _green,
        OrderStatus.pickedUp => Colors.teal,
        OrderStatus.delivered => Colors.green.shade700,
        OrderStatus.rejected => Colors.red,
      };

  String _elapsed(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inHours < 1) return 'hace ${d.inMinutes} min';
    return 'hace ${d.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (order.fromCall) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_in_talk, size: 10, color: Colors.deepPurple),
                              SizedBox(width: 3),
                              Text('Llamada', style: TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.status.name, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order.deliveryAddress,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(order.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(),
                Icon(
                  order.paymentType == PaymentType.cash ? Icons.payments_outlined : Icons.credit_card_outlined,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(width: 3),
                Text(
                  '${order.paymentType.name} · €${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(_elapsed(order.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
