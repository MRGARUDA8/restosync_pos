import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../utils/currency_formatter.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pizza & Menu Management', style: Theme.of(context).textTheme.headlineMedium),
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
                          const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (productProvider.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: productProvider.products.length,
                                itemBuilder: (context, index) {
                                  final product = productProvider.products[index];
                                  return ListTile(
                                    title: Text(product.name),
                                    subtitle: Text('${product.category} • ${product.unitType}'),
                                    trailing: Text(CurrencyFormatter.format(product.sellingPrice)),
                                    onTap: () => productProvider.loadVariants(product.id),
                                  );
                                },
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
                          const Text('Variants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (productProvider.variants.isEmpty)
                            const Text('Select a product to view sizes and pricing.')
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: productProvider.variants.length,
                                itemBuilder: (context, index) {
                                  final variant = productProvider.variants[index];
                                  return ListTile(
                                    title: Text(variant.sizeName),
                                    subtitle: Text('₹${variant.price.toStringAsFixed(0)} • ${variant.isAvailable ? 'In Stock' : 'Out of Stock'}'),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
