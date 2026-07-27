import 'package:flutter/material.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Display System (KDS)')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildKotCard('KOT-1001', 'T2', ['1x Classic Cheese Burger', '1x Iced Coffee'], 'New', Colors.orange),
          _buildKotCard('KOT-1002', 'T4', ['1x Margherita Pizza'], 'Preparing', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildKotCard(String kotNo, String table, List<String> items, String status, Color color) {
    return Card(
      elevation: 4,
      shape: Border(top: BorderSide(color: color, width: 4)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(kotNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Table: $table', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(i, style: const TextStyle(fontSize: 14)),
                )).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40), backgroundColor: color),
              child: Text('Mark $status Ready'),
            )
          ],
        ),
      ),
    );
  }
}
