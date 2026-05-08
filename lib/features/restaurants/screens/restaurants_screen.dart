import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/services/firebase_service.dart';
import '../providers/restaurants_provider.dart';

const _green = Color(0xFF10B981);

class RestaurantsTab extends ConsumerWidget {
  const RestaurantsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final restaurantsAsync = ref.watch(restaurantsStreamProvider);

    return restaurantsAsync.when(
      data: (restaurants) => restaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noRestaurants, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(l10n.addFirstHint, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: restaurants.length,
              itemBuilder: (_, i) => _RestaurantCard(restaurant: restaurants[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _RestaurantCard extends ConsumerWidget {
  final RestaurantAccount restaurant;
  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _green.withAlpha(30),
              child: Text(
                restaurant.name.isNotEmpty ? restaurant.name[0].toUpperCase() : 'R',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _green),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(restaurant.email,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRestaurantTitle),
        content: Text(l10n.confirmDelete(restaurant.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(firebaseServiceProvider).deleteRestaurant(restaurant.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class AddRestaurantSheet extends ConsumerStatefulWidget {
  const AddRestaurantSheet({super.key});

  @override
  ConsumerState<AddRestaurantSheet> createState() => _AddRestaurantSheetState();
}

class _AddRestaurantSheetState extends ConsumerState<AddRestaurantSheet> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefillAddress();
  }

  Future<void> _prefillAddress() async {
    final settings = await ref.read(firebaseServiceProvider).getRestaurantSettings();
    final address = settings['address']?.toString() ?? '';
    if (mounted && address.isNotEmpty && _addressCtrl.text.isEmpty) {
      setState(() => _addressCtrl.text = address);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty || email.isEmpty) {
      setState(() => _error = l10n.fillAllFields);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await ref.read(firebaseServiceProvider).addRestaurant(
      name: name,
      address: address,
      phone: phone,
      email: email,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.addRestaurant,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.restaurantName,
              prefixIcon: const Icon(Icons.storefront_outlined),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.restaurantAddress,
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: _green,
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
