import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/drivers/providers/drivers_provider.dart';
import '../../../core/models/driver_model.dart';

const _green = Color(0xFF10B981);
const _restLat = 41.3917;
const _restLng = 2.1649;

final _restRowProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  return Supabase.instance.client
      .from('restaurant_settings')
      .stream(primaryKey: ['id'])
      .map((rows) => rows.isEmpty ? null : Map<String, dynamic>.from(rows.first as Map));
});

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static bool _registered = false;
  static html.IFrameElement? _iframe;
  static const _viewType = 'op-leaflet-map';

  DriverAccount? _selectedDriver;
  List<DriverAccount> _prevDrivers = [];
  bool _iframeReady = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      _registered = true;
      final origin = html.window.location.origin;
      final src = '$origin/map.html?lat=$_restLat&lng=$_restLng&zoom=14&color=%2310B981';
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (id) {
        _iframe = html.IFrameElement()
          ..src = src
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return _iframe!;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() => _iframeReady = true);
        _sendRestaurant(ref.read(_restRowProvider).valueOrNull);
      }
    });
  }

  void _sendRestaurant(Map<String, dynamic>? r) {
    if (r == null) return;
    final lat = (r['lat'] as num?)?.toDouble();
    final lng = (r['lng'] as num?)?.toDouble();
    if (lat == null) return;
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'type': 'setRestaurant', 'lat': lat, 'lng': lng, 'address': r['address'] ?? ''}),
      '*',
    );
  }

  void _updateDriverMarkers(List<DriverAccount> drivers) {
    final markers = drivers
        .where((d) => d.lat != null && d.lng != null)
        .map((d) => {
              'lat': d.lat!,
              'lng': d.lng!,
              'color': d.isOnline ? '#10B981' : '#9CA3AF',
              'label': d.name.split(' ').first,
            })
        .toList();
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'type': 'setMarkers', 'markers': markers}),
      '*',
    );
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(driversStreamProvider).valueOrNull ?? [];

    // Update marker when restaurant settings change in real-time
    ref.listen(_restRowProvider, (_, next) {
      if (_iframeReady) _sendRestaurant(next.valueOrNull);
    });

    if (drivers != _prevDrivers) {
      _prevDrivers = drivers;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateDriverMarkers(drivers);
      });
    }

    return Stack(
      children: [
        // ── Leaflet map (full background) ─────────────────────────
        const Positioned.fill(child: HtmlElementView(viewType: _viewType)),

        // ── Driver info popup ─────────────────────────────────────
        if (_selectedDriver != null)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _DriverInfoCard(
              driver: _selectedDriver!,
              onClose: () => setState(() => _selectedDriver = null),
            ),
          ),

        // ── Legend ────────────────────────────────────────────────
        Positioned(
          bottom: 16,
          left: 16,
          child: _Legend(
            drivers: drivers,
            onDriverTap: (d) => setState(() =>
                _selectedDriver = _selectedDriver?.id == d.id ? null : d),
          ),
        ),
      ],
    );
  }
}

// ── Driver info card ──────────────────────────────────────────────────────────

class _DriverInfoCard extends StatelessWidget {
  final DriverAccount driver;
  final VoidCallback onClose;
  const _DriverInfoCard({required this.driver, required this.onClose});

  String _vehicleLabel(DriverVehicleType v) => switch (v) {
        DriverVehicleType.motorcycle => 'Moto',
        DriverVehicleType.bike => 'Bicicleta',
      };

  @override
  Widget build(BuildContext context) {
    final color = driver.isOnline ? _green : Colors.grey;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withAlpha(30),
              child: Text(
                driver.name[0].toUpperCase(),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(
                    children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color),
                          margin: const EdgeInsets.only(right: 4)),
                      Text(
                        driver.isOnline ? 'En línea' : 'Desconectado',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_shipping_outlined,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('${driver.todayDeliveries} hoy',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Text(
                    '${_vehicleLabel(driver.vehicleType)} · ${driver.email}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
                icon: const Icon(Icons.close, size: 18), onPressed: onClose),
          ],
        ),
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final List<DriverAccount> drivers;
  final void Function(DriverAccount) onDriverTap;
  const _Legend({required this.drivers, required this.onDriverTap});

  @override
  Widget build(BuildContext context) {
    final online = drivers.where((d) => d.isOnline).toList();
    final offline = drivers.where((d) => !d.isOnline).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...online.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () => onDriverTap(d),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: _green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(d.name.split(' ').first,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('${d.todayDeliveries}🛵',
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              )),
          if (offline > 0) ...[
            if (online.isNotEmpty) const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Offline: $offline',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
