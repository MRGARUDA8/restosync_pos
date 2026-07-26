import 'package:flutter/material.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tables = [
      {'number': 'T1', 'status': 'Available', 'seats': 2},
      {'number': 'T2', 'status': 'Occupied', 'seats': 4},
      {'number': 'T3', 'status': 'Available', 'seats': 4},
      {'number': 'T4', 'status': 'Reserved', 'seats': 6},
      {'number': 'T5', 'status': 'Available', 'seats': 2},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Visual Floor Plan & Table Management')),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: tables.length,
        itemBuilder: (ctx, idx) {
          final t = tables[idx];
          final isOccupied = t['status'] == 'Occupied';
          return Card(
            color: isOccupied
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: isOccupied ? Colors.red : Colors.green, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t['number'].toString(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${t['seats']} Seats',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Chip(
                  label: Text(t['status'].toString(),
                      style: const TextStyle(fontSize: 10)),
                  backgroundColor: isOccupied ? Colors.red : Colors.green,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
