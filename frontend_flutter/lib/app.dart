import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacky_pizza_pos/screens/login_screen.dart';
import 'package:hacky_pizza_pos/screens/dashboard_screen.dart';
import 'package:hacky_pizza_pos/screens/pos_screen.dart';
import 'package:hacky_pizza_pos/screens/kitchen_screen.dart';
import 'package:hacky_pizza_pos/screens/inventory_screen.dart';
import 'package:hacky_pizza_pos/screens/report_screen.dart';
import 'package:hacky_pizza_pos/screens/settings_screen.dart';
import 'package:hacky_pizza_pos/services/auth_provider.dart';

class HackyPizzaApp extends ConsumerWidget {
  const HackyPizzaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _router(ref);
    return MaterialApp.router(
      title: 'Hacky Pizza POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8A00), // orange like pizza
          secondary: Color(0xFFFFC107),
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        // Glass‑morphism style can be applied per widget
      ),
      routerConfig: router,
    );
  }

  GoRouter _router(WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;
    return GoRouter(
      initialLocation: isLoggedIn ? '/dashboard' : '/login',
      redirect: (context, state) {
        final loggedIn = ref.read(authProvider).isAuthenticated;
        final loggingIn = state.location == '/login';
        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/pos', builder: (c, s) => const PosScreen()),
        GoRoute(path: '/kitchen', builder: (c, s) => const KitchenScreen()),
        GoRoute(path: '/inventory', builder: (c, s) => const InventoryScreen()),
        GoRoute(path: '/reports', builder: (c, s) => const ReportScreen()),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      ],
    );
  }
}
