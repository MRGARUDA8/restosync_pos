import 'package:flutter/material.dart';

class CartBottomSheet extends StatelessWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> menuItems;
  final double totalPrice;
  final String selectedTable;
  final String orderType;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final VoidCallback onClearCart;

  const CartBottomSheet({
    super.key,
    required this.cart,
    required this.menuItems,
    required this.totalPrice,
    required this.selectedTable,
    required this.orderType,
    required this.onAdd,
    required this.onRemove,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    final tax = totalPrice * 0.05; // 5% GST
    final finalAmount = totalPrice + tax;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('$selectedTable • $orderType',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onClearCart,
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),

          // Cart Item List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cart.keys.length,
              itemBuilder: (context, index) {
                final id = cart.keys.elementAt(index);
                final item =
                    menuItems.firstWhere((element) => element['id'] == id);
                final qty = cart[id]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.grey, size: 20),
                            onPressed: () => onRemove(id),
                          ),
                          Text('$qty',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Color(0xFF6366F1), size: 20),
                            onPressed: () => onAdd(id),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '₹${(item['price'] * qty)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white12, height: 24),

          // Billing Calculation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text('₹${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GST (5%)', style: TextStyle(color: Colors.grey)),
              Text('₹${tax.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('₹${finalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // Action KOT Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('KOT Sent to Kitchen & Printer Successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SEND KOT TO KITCHEN',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}
