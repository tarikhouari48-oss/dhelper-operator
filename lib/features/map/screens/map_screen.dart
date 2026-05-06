import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../features/drivers/providers/drivers_provider.dart';
import '../../../core/models/driver_model.dart';

const _green = Color(0xFF10B981);
const _restLat = 41.3917;
const _restLng = 2.1649;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapCtrl = MapController();
  DriverAccount? _selectedDriver;

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversStreamProvider);
    final drivers = driversAsync.valueOrNull ?? [];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: const MapOptions(
            initialCenter: LatLng(_restLat, _restLng),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.dhelper.operator',
            ),
            // Restaurant zone
            CircleLayer(circles: [
              CircleMarker(
                point: const LatLng(_restLat, _restLng),
                radius: 500,
                useRadiusInMeter: true,
                color: _green.withAlpha(20),
                borderColor: _green.withAlpha(100),
                borderStrokeWidth: 1.5,
              ),
            ]),
            // Driver markers
            MarkerLayer(
              markers: [
                // Restaurant marker
                Marker(
                  point: const LatLng(_restLat, _restLng),
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: _green.withAlpha(80), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.storefront, color: Colors.white, size: 18),
                  ),
                ),
                // Driver markers
                ...drivers
                    .where((d) => d.lat != null && d.lng != null)
                    .map((d) => Marker(
                          point: LatLng(d.lat!, d.lng!),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDriver = _selectedDriver?.id == d.id ? null : d),
                            child: _DriverMarker(driver: d),
                          ),
                        )),
              ],
            ),
          ],
        ),

        // Driver info popup
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

        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: _Legend(drivers: drivers),
        ),
      ],
    );
  }
}

class _DriverMarker extends StatelessWidget {
  final DriverAccount driver;
  const _DriverMarker({required this.driver});

  IconData get _vehicleIcon => switch (driver.vehicleType) {
        DriverVehicleType.motorcycle => Icons.two_wheeler,
        DriverVehicleType.bike => Icons.pedal_bike,
      };

  @override
  Widget build(BuildContext context) {
    final color = driver.isOnline ? _green : Colors.grey;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(80), blurRadius: 6)],
          ),
          child: Icon(_vehicleIcon, color: Colors.white, size: 18),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)],
          ),
          child: Text(
            driver.name.split(' ').first,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}

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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(
                    children: [
                      Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color), margin: const EdgeInsets.only(right: 4)),
                      Text(
                        driver.isOnline ? 'En línea' : 'Desconectado',
                        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.local_shipping_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('${driver.todayDeliveries} hoy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<DriverAccount> drivers;
  const _Legend({required this.drivers});

  @override
  Widget build(BuildContext context) {
    final online = drivers.where((d) => d.isOnline).length;
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
        children: [
          _LegendRow(color: _green, label: 'En línea: $online'),
          const SizedBox(height: 4),
          _LegendRow(color: Colors.grey, label: 'Offline: $offline'),
          const SizedBox(height: 4),
          _LegendRow(color: _green, label: 'Restaurante', isSquare: true),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSquare;
  const _LegendRow({required this.color, required this.label, this.isSquare = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isSquare ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
