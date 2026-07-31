import 'package:flutter/material.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = const [
      {'name': 'Admin', 'role': 'Admin', 'permissions': 'All access'},
      {'name': 'Manager', 'role': 'Manager', 'permissions': 'Inventory, Reports, Expenses'},
      {'name': 'Cashier', 'role': 'Cashier', 'permissions': 'Billing, Customers'},
      {'name': 'Kitchen', 'role': 'Kitchen Staff', 'permissions': 'KDS only'},
    ];

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Staff & Roles', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3,
              ),
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final member = staff[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Role: ${member['role']!}'),
                        const SizedBox(height: 4),
                        Text('Permissions: ${member['permissions']!}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
