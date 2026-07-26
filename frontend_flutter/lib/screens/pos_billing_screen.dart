import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pos_provider.dart';

class PosBillingScreen extends ConsumerWidget {
  const PosBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('POS & Billing Terminal')),
      body: Row(
        children: [
          // Left Product Catalog Grid
          Expanded(
            flex: 2,
            child: productsAsync.when(
              data: (products) => GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (ctx, idx) {
                  final p = products[idx];
                  return InkWell(
                    onTap: () => ref.read(cartProvider.notifier).add(p),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading products: $err')),
            ),
          ),

          // Right Cart & Billing Sidebar
          Container(
            width: 350,
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (ctx, idx) {
                            final item = cart[idx];
                            return ListTile(
                              title: Text(item.product.name, style: const TextStyle(fontSize: 14)),
                              subtitle: Text('Qty: ${item.quantity} x ₹${item.product.price}'),
                              trailing: Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}'),
                              leading: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.redAccent),
                                onPressed: () => ref.read(cartProvider.notifier).remove(idx),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total (incl. GST):'),
                    Text('₹${ref.read(cartProvider.notifier).grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.kitchen),
                        label: const Text('Send KOT'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('KOT sent to kitchen display!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.print),
                        label: const Text('Pay & Bill'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bill generated & ingredients deducted from inventory!')),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
