import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/restaurant_model.dart';
import '../../../core/services/firebase_service.dart';

final restaurantsStreamProvider = StreamProvider<List<RestaurantAccount>>((ref) {
  return ref.watch(firebaseServiceProvider).watchRestaurants();
});
