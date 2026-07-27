import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'name': 'Burger Bun',
        'stock': 150,
        'unit': 'pcs',
        'status': 'Sufficient'
      },
      {
        'name': 'Cheese Slice',
        'stock': 200,
        'unit': 'pcs',
        'status': 'Sufficient'
      },
      {
        'name': 'Chicken Patty',
        'stock': 12,
        'unit': 'pcs',
        'status': 'Low Stock'
      },
      {
        'name': 'Mozzarella Cheese',
        'stock': 4500,
        'unit': 'grams',
        'status': 'Sufficient'
      },
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text('Inventory Stock & Recipe Deduction Engine')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, idx) {
          final item = items[idx];
          final isLow = item['status'] == 'Low Stock';
          return ListTile(
            title: Text(item['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Current Stock: ${item['stock']} ${item['unit']}'),
            trailing: Chip(
              label: Text(item['status'].toString()),
              backgroundColor: isLow
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : Colors.greenAccent.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                  color: isLow ? Colors.redAccent : Colors.greenAccent),
            ),
          );
        },
      ),
    );
  }
}
