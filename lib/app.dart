import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:operator_app/l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/main/screens/main_screen.dart';
import 'features/orders/screens/create_order_screen.dart';
import 'features/settings/screens/settings_screen.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final _routerProvider = Provider<GoRouter>((ref) {
  final authId = ref.watch(operatorAuthProvider);

  return GoRouter(
    initialLocation: authId != null ? '/' : '/login',
    redirect: (context, state) {
      final loggedIn = authId != null;
      final onAuth = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && state.matchedLocation == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/', builder: (_, __) => const MainScreen()),
      GoRoute(path: '/orders/create', builder: (_, __) => const CreateOrderScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});

class OperatorApp extends ConsumerWidget {
  const OperatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Delivery Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: locale,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
      ],
    );
  }
}
