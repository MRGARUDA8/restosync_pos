import 'package:flutter/material.dart';
import '../providers/invoice_provider.dart';

import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../utils/currency_formatter.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  Future<void> _showVariantSelector(BuildContext context, Product product) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadVariants(product.id);
    if (!mounted) return;
    final variants = productProvider.variants;
    int count = 1;
    ProductVariant? selected = variants.isNotEmpty ? variants.first : null;

    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) {
      return Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: StatefulBuilder(builder: (c, setS) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (variants.isEmpty)
                  Text('No sizes available. Adding as single item at ₹${product.sellingPrice.toStringAsFixed(0)}')
                else
                  Column(
                    children: variants.map((v) => RadioListTile<ProductVariant>(
                      value: v,
                      groupValue: selected,
                      title: Text('${v.sizeName} - ${CurrencyFormatter.format(v.price)}'),
                      onChanged: (val) => setS(() => selected = val),
                    )).toList(),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(onPressed: () => setS(() { if (count>1) count--; }), icon: const Icon(Icons.remove_circle)),
                    Text(count.toString(), style: const TextStyle(fontSize: 18)),
                    IconButton(onPressed: () => setS(() { count++; }), icon: const Icon(Icons.add_circle, color: Colors.green)),
                    const Spacer(),
                    ElevatedButton.icon(onPressed: () {
                      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                      final variantToAdd = selected ?? ProductVariant(id: '', productId: product.id, sizeName: 'Standard', price: product.sellingPrice, weightVolume: 0, isAvailable: true);
                      orderProvider.addToCart(product, variantToAdd, count.toDouble());
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      Navigator.of(ctx).pop();
                    }, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add to Cart')),
                  ],
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final categories = ['All', ...productProvider.productCategories.map((pc) => pc['name'] as String)];
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = 'All';
    }

    final filtered = productProvider.products.where((p) => _selectedCategory == 'All' || p.category == _selectedCategory).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            color: const Color(0xFF6D28D9),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.white70),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I want to sell...',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create new order'))),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: const [
                        Icon(Icons.add_circle, color: Color(0xFF22C55E), size: 46),
                        SizedBox(height: 12),
                        Text(
                          'NEW ORDER',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Total Table Orders: ${invoiceProvider.invoices.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 18),
          // Category tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((c) {
                  final selected = _selectedCategory == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = c),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Products list for quick billing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Products', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filtered.map((p) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                        onPressed: () => _showVariantSelector(context, p),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(p.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
