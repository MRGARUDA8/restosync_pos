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
          title: Text(title),
          actions: actions ?? [
            IconButton(onPressed: () {}, icon: const Icon(Icons.sync)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.print)),
          ],
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
      );
    });
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          child: Center(
            child: Text('Hacky Pizza', style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                selected: index == currentIndex,
                selectedColor: Theme.of(context).colorScheme.primary,
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
