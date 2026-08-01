import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.actions,
  });

  static const _menuItems = [
    'Dashboard',
    'POS Billing',
    'Pizza & Menu Management',
    'Orders & KDS',
    'Inventory',
    'Expenses',
    'Sales Reports',
    'Customers',
    'Staff & Roles',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLarge = constraints.maxWidth > 1000;
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF6D28D9),
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 24),
                    ],
                  ),
                ),
              ],
            ),
            actions: actions,
          ),
          drawer: isLarge ? null : Drawer(child: _buildSidebar(context)),
          body: Row(
            children: [
              if (isLarge)
                Container(
                  width: 280,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: _buildSidebar(context),
                ),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: isLarge ? null : _buildBottomNavigationBar(context),
        );
    });
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF6D28D9)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Hacky Pizza TOW', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Take Away + Delivery', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                selected: index == currentIndex,
                selectedColor: const Color(0xFF6D28D9),
                iconColor: index == currentIndex ? const Color(0xFF6D28D9) : null,
                leading: Icon(_menuIcon(index)),
                title: Text(_menuItems[index]),
                onTap: () {
                  onDestinationSelected(index);
                  if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    const bottomItems = [
      BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Reports'),
      BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
      BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Counter'),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Items'),
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
    ];

    const mappedIndices = [6, 0, 1, 2, 9];
    final selectedIndex = mappedIndices.indexOf(currentIndex);

    return BottomNavigationBar(
      currentIndex: selectedIndex >= 0 ? selectedIndex : 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6D28D9),
      unselectedItemColor: Colors.grey,
      onTap: (index) => onDestinationSelected(mappedIndices[index]),
      items: bottomItems,
    );
  }

  IconData _menuIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.point_of_sale;
      case 2:
        return Icons.local_pizza;
      case 3:
        return Icons.kitchen;
      case 4:
        return Icons.inventory_2;
      case 5:
        return Icons.receipt_long;
      case 6:
        return Icons.show_chart;
      case 7:
        return Icons.people;
      case 8:
        return Icons.admin_panel_settings;
      case 9:
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }
}
