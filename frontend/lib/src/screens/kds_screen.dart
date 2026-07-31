import 'package:flutter/material.dart';

class KdsScreen extends StatelessWidget {
  const KdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kitchen Display System', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                _KdsCard(status: 'Preparing', orderId: 'INV-0004', minutes: 6),
                _KdsCard(status: 'Ready', orderId: 'INV-0005', minutes: 2),
                _KdsCard(status: 'Delivered', orderId: 'INV-0003', minutes: 0),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _KdsCard extends StatelessWidget {
  final String status;
  final String orderId;
  final int minutes;

  const _KdsCard({required this.status, required this.orderId, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(orderId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(status, style: TextStyle(color: status == 'Ready' ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Timer: $minutes mins'),
          ],
        ),
      ),
    );
  }
}
