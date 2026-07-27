import 'package:flutter/material.dart';
import 'pos_billing_screen.dart';
import 'tables_screen.dart';
import 'kitchen_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHomeView(),
    const PosBillingScreen(),
    const TablesScreen(),
    const KitchenScreen(),
    const InventoryScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) =>
                setState(() => _selectedIndex = idx),
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1E293B),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.dashboard), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.point_of_sale), label: Text('POS')),
              NavigationRailDestination(
                  icon: Icon(Icons.table_restaurant), label: Text('Tables')),
              NavigationRailDestination(
                  icon: Icon(Icons.soup_kitchen), label: Text('KDS')),
              NavigationRailDestination(
                  icon: Icon(Icons.inventory), label: Text('Inventory')),
              NavigationRailDestination(
                  icon: Icon(Icons.assessment), label: Text('Reports')),
            ],
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  const _DashboardHomeView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RestoSync Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildKpiCard(
                  'Today\'s Sales', '₹14,850.00', Icons.payments, Colors.green),
              const SizedBox(width: 16),
              _buildKpiCard(
                  'Today\'s Orders', '42 Orders', Icons.receipt, Colors.indigo),
              const SizedBox(width: 16),
              _buildKpiCard('Active Tables', '4 Occupied', Icons.table_bar,
                  Colors.orange),
              const SizedBox(width: 16),
              _buildKpiCard(
                  'Pending KOTs', '2 Preparing', Icons.kitchen, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
