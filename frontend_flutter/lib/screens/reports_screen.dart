import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial & Sales Reports')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Excel Report'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Bill #')),
                      DataColumn(label: Text('Order #')),
                      DataColumn(label: Text('Table')),
                      DataColumn(label: Text('Grand Total')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('INV-1001')),
                        DataCell(Text('ORD-1001')),
                        DataCell(Text('T2')),
                        DataCell(Text('₹493.50')),
                      ]),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
