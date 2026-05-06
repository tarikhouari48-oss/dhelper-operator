import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/dashboard/screens/dashboard_screen.dart';
import '../../../features/orders/screens/order_list_screen.dart';
import '../../../features/map/screens/map_screen.dart';
import '../../../features/drivers/screens/drivers_screen.dart';
import '../../../features/restaurants/screens/restaurants_screen.dart';
import '../../../features/orders/providers/orders_provider.dart';
import '../../../features/drivers/providers/drivers_provider.dart';
import '../../../features/restaurants/providers/restaurants_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/driver_model.dart';

const _green = Color(0xFF10B981);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pendingCount = ref.watch(ordersStreamProvider).valueOrNull
            ?.where((o) => o.status == OrderStatus.pending)
            .length ?? 0;
    final onlineCount = ref.watch(driversStreamProvider).valueOrNull
            ?.where((d) => d.isOnline)
            .length ?? 0;

    final titles = [
      l10n.dashboard,
      l10n.orders,
      l10n.mapTab,
      l10n.driversTab,
      l10n.restaurantsTab,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
              child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deliveryPlatform,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: _green, height: 1.1)),
                Text(titles[_tab],
                    style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.1)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _confirmLogout(context, l10n),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, l10n),
      body: IndexedStack(
        index: _tab,
        children: const [
          DashboardScreen(),
          OrdersContent(),
          MapScreen(),
          DriversTab(),
          RestaurantsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.receipt_long),
            ),
            label: l10n.orders,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: onlineCount > 0,
              label: Text('$onlineCount'),
              child: const Icon(Icons.map_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: onlineCount > 0,
              label: Text('$onlineCount'),
              child: const Icon(Icons.map),
            ),
            label: l10n.mapTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.driversTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.restaurantsTab,
          ),
        ],
      ),
    );
  }

  Widget? _buildFab(BuildContext context, AppLocalizations l10n) {
    if (_tab == 3) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddDriver(context),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addDriver),
        backgroundColor: _green,
      );
    }
    if (_tab == 4) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddRestaurant(context),
        icon: const Icon(Icons.add_business_outlined),
        label: Text(l10n.addRestaurant),
        backgroundColor: _green,
      );
    }
    return null;
  }

  void _showAddDriver(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const AddDriverSheet(),
    );
  }

  void _showAddRestaurant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const AddRestaurantSheet(),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(operatorAuthProvider.notifier).state = null;
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
