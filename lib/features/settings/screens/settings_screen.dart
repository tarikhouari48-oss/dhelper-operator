import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operator_app/l10n/app_localizations.dart';
import '../../../app.dart';
import '../../../core/services/firebase_service.dart';

const _green = Color(0xFF10B981);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _hoursCtrl   = TextEditingController();
  bool _loadingInfo  = true;
  bool _saving       = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final svc = ref.read(firebaseServiceProvider);
    final info = await svc.getRestaurantSettings();
    if (mounted) {
      setState(() {
        _nameCtrl.text    = info['name']    ?? '';
        _addressCtrl.text = info['address'] ?? '';
        _phoneCtrl.text   = info['phone']   ?? '';
        _hoursCtrl.text   = info['hours']   ?? '';
        _loadingInfo      = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(firebaseServiceProvider).saveRestaurantSettings(
      name:    _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone:   _phoneCtrl.text.trim(),
      hours:   _hoursCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurante actualizado'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    const languages = [
      ('English', Locale('en')),
      ('Español', Locale('es')),
      ('Français', Locale('fr')),
      ('العربية', Locale('ar')),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 8),

          // ── Restaurant info ──────────────────────────────────────
          _SectionHeader('RESTAURANTE'),
          if (_loadingInfo)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del restaurante',
                      prefixIcon: Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 400;
                    final phoneField = TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    );
                    final hoursField = TextField(
                      controller: _hoursCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Horario',
                        prefixIcon: Icon(Icons.schedule_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    );
                    if (wide) {
                      return Row(children: [
                        Expanded(child: phoneField),
                        const SizedBox(width: 10),
                        Expanded(child: hoursField),
                      ]);
                    }
                    return Column(children: [
                      phoneField,
                      const SizedBox(height: 10),
                      hoursField,
                    ]);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Guardar'),
                      style: FilledButton.styleFrom(backgroundColor: _green),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(),

          // ── Appearance ───────────────────────────────────────────
          _SectionHeader('APARIENCIA'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
                ButtonSegment(value: ThemeMode.light,  icon: Icon(Icons.light_mode),      label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark,   icon: Icon(Icons.dark_mode),       label: Text('Oscuro')),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).state = s.first,
            ),
          ),

          const Divider(),

          // ── Language ─────────────────────────────────────────────
          _SectionHeader(l10n.language.toUpperCase()),
          ...languages.map(
            (lang) => RadioListTile<Locale>(
              title: Text(lang.$1),
              value: lang.$2,
              groupValue: currentLocale,
              onChanged: (v) => ref.read(localeProvider.notifier).state = v!,
            ),
          ),

          const Divider(),
          const ListTile(
            leading: Icon(Icons.local_shipping_rounded, color: _green),
            title: Text('D-helper'),
            subtitle: Text('Delivery Platform v1.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
      );
}
