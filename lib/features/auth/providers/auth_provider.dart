import 'package:flutter_riverpod/flutter_riverpod.dart';

// null = not logged in  |  set to non-null to bypass login (dev mode)
final operatorAuthProvider = StateProvider<String?>((ref) => 'admin@dhelper.com');
