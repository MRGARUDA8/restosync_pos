import 'package:flutter/material.dart';

import 'invoice_history_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders & KDS', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('Invoice History'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const InvoiceHistoryScreen(),
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              children: const [
                                _OrderTile(orderId: 'INV-0001', status: 'Preparing', time: '10:04 AM'),
                                _OrderTile(orderId: 'INV-0002', status: 'Ready', time: '10:21 AM'),
                                _OrderTile(orderId: 'INV-0003', status: 'Delivered', time: '10:37 AM'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kitchen Display', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.kitchen, size: 64, color: Colors.orange),
                                  SizedBox(height: 12),
                                  Text('Live KDS updates stream here.', style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text('Connect to Socket.IO for real-time order state sync.', textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final String orderId;
  final String status;
  final String time;

  const _OrderTile({required this.orderId, required this.status, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(orderId),
        subtitle: Text('$status • $time'),
        trailing: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
