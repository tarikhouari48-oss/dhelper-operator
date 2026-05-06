import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/services/firebase_service.dart';

final driversStreamProvider = StreamProvider<List<DriverAccount>>((ref) {
  return ref.watch(firebaseServiceProvider).watchDrivers();
});
