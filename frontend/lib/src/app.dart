import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/report_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/invoice_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_management_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/pos_screen.dart';
import 'widgets/responsive_scaffold.dart';

class HackyPizzaApp extends StatelessWidget {
  const HackyPizzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<AppProvider>(builder: (context, appProvider, child) {
        return MaterialApp(
          title: 'Hacky Pizza POS',
          debugShowCheckedModeBanner: false,
          themeMode: appProvider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey.shade100,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
            ),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F1115),
            cardColor: const Color(0xFF181B20),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF14171F)),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'IN')],
          home: const AppShell(),
        );
      }),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // On web we skip heavy native plugin/database initialization because
      // packages like sqflite and path_provider are not supported in web builds.
      // This prevents MissingPluginException and allows the UI to load for preview.
      if (kIsWeb) {
        setState(() {
          _isReady = true;
        });
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

      await authProvider.initialize();
      await productProvider.loadProducts();
      await inventoryProvider.loadInventory();
      await expenseProvider.loadExpenses();
      await customerProvider.loadCustomers();
      await reportProvider.loadDashboardMetrics();
      await invoiceProvider.loadInvoices();
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    final screens = <Widget>[
      const DashboardScreen(),
      const PosScreen(),
      const MenuManagementScreen(),
      const OrdersScreen(),
      const InventoryScreen(),
      const ExpensesScreen(),
      const ReportsScreen(),
      const CustomersScreen(),
      const StaffScreen(),
      const SettingsScreen(),
    ];

    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If user is not logged in, show a plain scaffold with only the login screen
    // (no sidebar/drawer) so the login appears fullscreen on large displays.
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hacky Pizza POS')),
        body: const LoginScreen(),
      );
    }

    return ResponsiveScaffold(
      title: 'Hacky Pizza POS',
      currentIndex: appProvider.selectedIndex,
      onDestinationSelected: (index) {
        appProvider.selectedIndex = index;
      },
      actions: [
        IconButton(
          onPressed: authProvider.logout,
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
      ],
      body: screens[appProvider.selectedIndex],
    );
  }
}
