import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../core/services/firebase_service.dart';
import '../../../features/drivers/providers/drivers_provider.dart';

const _green = Color(0xFF10B981);

final _periodProvider = StateProvider<String>((ref) => 'today');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final period = ref.watch(_periodProvider);
    final svc = ref.watch(firebaseServiceProvider);
    final stats = svc.computeStats(period);
    final driversAsync = ref.watch(driversStreamProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
                value: 'today',
                label: Text(l10n.today),
                icon: const Icon(Icons.today_outlined, size: 16)),
            ButtonSegment(
                value: 'month',
                label: Text(l10n.thisMonth),
                icon: const Icon(Icons.calendar_month_outlined, size: 16)),
            ButtonSegment(
                value: 'year',
                label: Text(l10n.thisYear),
                icon: const Icon(Icons.bar_chart_outlined, size: 16)),
          ],
          selected: {period},
          onSelectionChanged: (s) =>
              ref.read(_periodProvider.notifier).state = s.first,
          style:
              SegmentedButton.styleFrom(selectedBackgroundColor: _green.withAlpha(30)),
        ),
        const SizedBox(height: 16),

        // Earnings card
        _EarningsCard(
            total: stats.totalEarnings,
            totalOrders: stats.totalOrders,
            period: period,
            l10n: l10n),
        const SizedBox(height: 16),

        // Bar chart – last 7 days
        _SectionTitle(l10n.ordersLast7Days),
        const SizedBox(height: 8),
        _OrdersBarChart(data: svc.ordersLast7Days()),
        const SizedBox(height: 16),

        // Two small stat cards (cash / card)
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.payments_outlined,
                color: Colors.orange,
                label: l10n.cash,
                value: '${stats.cashOrders}',
                sub: '€${stats.cashAmount.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.credit_card_outlined,
                color: const Color(0xFF2563EB),
                label: l10n.card,
                value: '${stats.cardOrders}',
                sub: '€${stats.cardAmount.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Pie chart – cash vs card
        if (stats.totalOrders > 0) ...[
          _SectionTitle(l10n.cashVsCard),
          const SizedBox(height: 8),
          _CashCardPie(
              cashAmount: stats.cashAmount,
              cardAmount: stats.cardAmount,
              l10n: l10n),
          const SizedBox(height: 16),
        ],

        // Two more stats: avg delivery / avg per order
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.timer_outlined,
                color: Colors.teal,
                label: l10n.avgDeliveryTime,
                value: stats.avgDeliveryMinutes > 0
                    ? '${stats.avgDeliveryMinutes.toStringAsFixed(0)} min'
                    : '—',
                sub: l10n.perDelivery,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_shipping_outlined,
                color: Colors.pink,
                label: l10n.avgPerOrder,
                value: stats.totalOrders > 0
                    ? '€${(stats.totalEarnings / stats.totalOrders).toStringAsFixed(2)}'
                    : '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Drivers list
        _SectionTitle(l10n.driversTab),
        const SizedBox(height: 8),
        driversAsync.when(
          data: (drivers) => Column(
            children: drivers
                .map((d) => _DriverRow(
                      name: d.name,
                      isOnline: d.isOnline,
                      deliveries: d.todayDeliveries,
                      earnings: d.todayEarnings,
                      vehicleType: d.vehicleType.name,
                      onlineLabel: l10n.onlineLabel,
                      offlineLabel: l10n.offlineLabel,
                    ))
                .toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart – last 7 days
// ---------------------------------------------------------------------------
class _OrdersBarChart extends StatelessWidget {
  final List<int> data;
  const _OrdersBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.fold(0, (m, v) => v > m ? v : m).toDouble();
    final now = DateTime.now();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: BarChart(
        BarChartData(
          maxY: (maxVal < 2) ? 5 : maxVal + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, _, rod, __) {
                final count = data[group.x];
                final day = now.subtract(Duration(days: 6 - group.x));
                const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                final label = dayNames[day.weekday - 1];
                return BarTooltipItem(
                  '$label\n$count pedido${count == 1 ? '' : 's'}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  final day = now.subtract(Duration(days: 6 - value.toInt()));
                  const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                  return Text(
                    days[day.weekday - 1],
                    style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outlineVariant,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            7,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  color: _green,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pie chart – cash vs card
// ---------------------------------------------------------------------------
class _CashCardPie extends StatelessWidget {
  final double cashAmount;
  final double cardAmount;
  final AppLocalizations l10n;
  const _CashCardPie(
      {required this.cashAmount,
      required this.cardAmount,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    final total = cashAmount + cardAmount;
    if (total == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: cashAmount,
                    color: Colors.orange,
                    title: '${(cashAmount / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 55,
                  ),
                  PieChartSectionData(
                    value: cardAmount,
                    color: const Color(0xFF2563EB),
                    title: '${(cardAmount / total * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 55,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(color: Colors.orange, label: l10n.cash),
              const SizedBox(height: 8),
              _Legend(color: const Color(0xFF2563EB), label: l10n.card),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      );
}

// ---------------------------------------------------------------------------
// Earnings card
// ---------------------------------------------------------------------------
class _EarningsCard extends StatelessWidget {
  final double total;
  final int totalOrders;
  final String period;
  final AppLocalizations l10n;
  const _EarningsCard(
      {required this.total,
      required this.totalOrders,
      required this.period,
      required this.l10n});

  String _periodLabel(AppLocalizations l10n) => switch (period) {
        'month' => l10n.thisMonth.toLowerCase(),
        'year' => l10n.thisYear.toLowerCase(),
        _ => l10n.today.toLowerCase(),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.earnings} — ${_periodLabel(l10n)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text('€${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$totalOrders ${l10n.delivered.toLowerCase()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.euro_rounded, color: Colors.white30, size: 56),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold));
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? sub;
  const _StatCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value,
      this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          if (sub != null)
            Text(sub!,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  final String name;
  final bool isOnline;
  final int deliveries;
  final double earnings;
  final String vehicleType;
  final String onlineLabel;
  final String offlineLabel;
  const _DriverRow({
    required this.name,
    required this.isOnline,
    required this.deliveries,
    required this.earnings,
    required this.vehicleType,
    required this.onlineLabel,
    required this.offlineLabel,
  });

  IconData get _vehicleIcon => switch (vehicleType) {
        'motorcycle' => Icons.two_wheeler,
        'car' => Icons.directions_car_outlined,
        _ => Icons.pedal_bike_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isOnline ? _green.withAlpha(30) : Colors.grey.withAlpha(30),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOnline ? _green : Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Icon(_vehicleIcon, size: 14, color: Colors.grey),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? _green : Colors.grey,
                        ),
                      ),
                      Text(
                        isOnline ? onlineLabel : offlineLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: isOnline ? _green : Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$deliveries',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('€${earnings.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
