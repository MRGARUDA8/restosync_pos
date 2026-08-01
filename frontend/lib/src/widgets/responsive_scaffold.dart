import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/local_database.dart';
import '../screens/kds_screen.dart';
import '../screens/invoice_history_screen.dart';

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
                  width: 300,
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._drawerSections.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (section.title != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(section.title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    ...section.items.map((item) {
                      final selected = item.destinationIndex != null && item.destinationIndex == currentIndex;
                      return ListTile(
                        selected: selected,
                        selectedColor: const Color(0xFF6D28D9),
                        iconColor: selected ? const Color(0xFF6D28D9) : const Color(0xFF6D28D9),
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        trailing: () {
                          if (item.badgeCount != null) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6D28D9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text('${item.badgeCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }
                          if (item.badgeLabel != null) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(item.badgeLabel!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }

                          // Dynamic badges for Inventory and Receipts
                          if (item.title == 'Inventory Management') {
                            return FutureBuilder<int>(
                              future: LocalDatabaseService.instance.countLowStockIngredients(),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                if (count <= 0) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              },
                            );
                          }

                          if (item.title == 'Receipts') {
                            return FutureBuilder<int>(
                              future: LocalDatabaseService.instance.countOpenInvoices(),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                if (count <= 0) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              },
                            );
                          }

                          return null;
                        }(),
                        onTap: () {
                          if (item.destinationIndex != null) {
                            onDestinationSelected(item.destinationIndex!);
                          } else if (item.routeBuilder != null) {
                            Navigator.of(context).push(MaterialPageRoute(builder: item.routeBuilder!));
                          } else if (item.action != null) {
                            item.action!(context);
                          }
                          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context);
                        },
                      );
                    }),
                    const Divider(height: 1, thickness: 1),
                  ],
                );
              }),
            ],
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

}

void _openComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
}

void _logout(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  authProvider.logout();
}

Widget _invoiceHistory(BuildContext context) => const InvoiceHistoryScreen();

Widget _kitchenDisplay(BuildContext context) => const KdsScreen();

class _DrawerSection {
  final String? title;
  final List<_SidebarItem> items;

  const _DrawerSection({this.title, required this.items});
}

class _SidebarItem {
  final String title;
  final IconData icon;
  final int? badgeCount;
  final String? badgeLabel;
  final int? destinationIndex;
  final WidgetBuilder? routeBuilder;
  final void Function(BuildContext)? action;

  const _SidebarItem({
    required this.title,
    required this.icon,
    this.badgeCount,
    this.badgeLabel,
    this.destinationIndex,
    this.routeBuilder,
    this.action,
  });
}

final List<_DrawerSection> _drawerSections = [
  _DrawerSection(
    items: [
      _SidebarItem(title: 'Inventory Management', icon: Icons.inventory_2, badgeCount: 129, destinationIndex: 4),
      _SidebarItem(title: 'Add Expense', icon: Icons.add_card, destinationIndex: 5),
      _SidebarItem(title: 'Receipts', icon: Icons.receipt_long, routeBuilder: _invoiceHistory),
      _SidebarItem(title: 'Customers Management', icon: Icons.group, badgeCount: 23, destinationIndex: 7),
      _SidebarItem(title: 'Staff Management', icon: Icons.badge, badgeCount: 0, destinationIndex: 8),
      _SidebarItem(title: 'Table Management', icon: Icons.table_restaurant, badgeCount: 4, destinationIndex: 2),
      _SidebarItem(title: 'ShopFront', icon: Icons.storefront, badgeCount: 0, destinationIndex: 1),
    ],
  ),
  _DrawerSection(
    title: 'Other apps',
    items: [
      _SidebarItem(title: 'Refer App', icon: Icons.share, action: (context) => _openComingSoon(context, 'Refer app')),
      _SidebarItem(title: 'Returned Receipt', icon: Icons.receipt_long, routeBuilder: _invoiceHistory),
      _SidebarItem(title: 'Web Back Office', icon: Icons.web, action: (context) => _openComingSoon(context, 'Web back office')),
      _SidebarItem(title: 'Feedback', icon: Icons.thumb_up, action: (context) => _openComingSoon(context, 'Feedback')),
      _SidebarItem(title: 'Buy Printer', icon: Icons.print, badgeLabel: 'NEW', action: (context) => _openComingSoon(context, 'Printer purchase')),
      _SidebarItem(title: 'Connect Kitchen display App', icon: Icons.kitchen, routeBuilder: _kitchenDisplay),
    ],
  ),
  _DrawerSection(
    title: 'Settings',
    items: [
      _SidebarItem(title: 'Language - English', icon: Icons.language, action: (context) => _openComingSoon(context, 'Language settings')),
      _SidebarItem(title: 'Weighing Machine', icon: Icons.scale, badgeLabel: 'NEW', action: (context) => _openComingSoon(context, 'Weighing machine')),
      _SidebarItem(title: 'Receipt Settings', icon: Icons.receipt, destinationIndex: 9),
      _SidebarItem(title: 'Business Settings', icon: Icons.business_center, destinationIndex: 9),
      _SidebarItem(title: 'General settings', icon: Icons.settings, destinationIndex: 9),
      _SidebarItem(title: 'Printer Setup', icon: Icons.print, destinationIndex: 9),
      _SidebarItem(title: 'Logout', icon: Icons.logout, action: _logout),
    ],
  ),
];
