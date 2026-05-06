import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/services/firebase_service.dart';
import '../providers/drivers_provider.dart';

const _green = Color(0xFF10B981);

class DriversTab extends ConsumerWidget {
  const DriversTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final driversAsync = ref.watch(driversStreamProvider);

    return driversAsync.when(
      data: (drivers) => drivers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noDrivers,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(l10n.addFirstHint,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: drivers.length,
              itemBuilder: (_, i) => _DriverCard(driver: drivers[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _DriverCard extends ConsumerWidget {
  final DriverAccount driver;
  const _DriverCard({required this.driver});

  IconData _vehicleIcon(DriverVehicleType v) => switch (v) {
        DriverVehicleType.motorcycle => Icons.two_wheeler,
        DriverVehicleType.bike => Icons.pedal_bike_outlined,
      };

  String _vehicleLabel(DriverVehicleType v, AppLocalizations l10n) => switch (v) {
        DriverVehicleType.motorcycle => l10n.motorcycle,
        DriverVehicleType.bike => l10n.bike,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'R',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: _green),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          driver.email,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(driver.phone,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(_vehicleIcon(driver.vehicleType),
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(_vehicleLabel(driver.vehicleType, l10n),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
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

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDriverTitle),
        content: Text(l10n.confirmDelete(driver.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(firebaseServiceProvider).deleteDriver(driver.id);
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

class AddDriverSheet extends ConsumerStatefulWidget {
  const AddDriverSheet({super.key});

  @override
  ConsumerState<AddDriverSheet> createState() => _AddDriverSheetState();
}

class _AddDriverSheetState extends ConsumerState<AddDriverSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  DriverVehicleType _vehicle = DriverVehicleType.motorcycle;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      setState(() => _error = l10n.fillAllFields);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = l10n.minPassword);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await ref.read(firebaseServiceProvider).addDriver(
          name: name,
          email: email,
          phone: phone,
          vehicleType: _vehicle,
          password: pass,
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
              Text(l10n.addDriver,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outlined),
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
                  textInputAction: TextInputAction.next,
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
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.passwordField,
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(l10n.vehicleType, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _VehicleBtn(
                icon: Icons.pedal_bike_outlined,
                label: l10n.bike,
                value: DriverVehicleType.bike,
                selected: _vehicle,
                onTap: (v) => setState(() => _vehicle = v),
              ),
              const SizedBox(width: 8),
              _VehicleBtn(
                icon: Icons.two_wheeler,
                label: l10n.motorcycle,
                value: DriverVehicleType.motorcycle,
                selected: _vehicle,
                onTap: (v) => setState(() => _vehicle = v),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _VehicleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final DriverVehicleType value;
  final DriverVehicleType selected;
  final ValueChanged<DriverVehicleType> onTap;

  const _VehicleBtn({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _green.withAlpha(20) : Colors.transparent,
            border: Border.all(
              color: isSelected ? _green : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _green : Colors.grey, size: 20),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? _green : Colors.grey,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
