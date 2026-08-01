import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/product_provider.dart';
import '../utils/currency_formatter.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final tc = TextEditingController();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(controller: tc, decoration: const InputDecoration(labelText: 'Category name')),
          actions: [
            TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Add')),
          ],
        );
      },
    );
    if (confirmed == true && tc.text.trim().isNotEmpty) {
      await provider.addCategory(tc.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category added')));
    }
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final nameTc = TextEditingController();
    final priceTc = TextEditingController();
    String selectedCategory = provider.productCategories.isNotEmpty ? (provider.productCategories.first['name'] as String) : '';
    bool advanced = false;

    final List<Map<String, TextEditingController>> sizeControllers = [];
    String? imagePath;

    void addSizeRow() {
      sizeControllers.add({
        'label': TextEditingController(),
        'price': TextEditingController(),
      });
    }

    addSizeRow(); // start with one row

    await showDialog<void>(
      context: context,
      builder: (dctx) {
        return StatefulBuilder(builder: (c, setS) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
            if (picked != null) {
              setS(() => imagePath = picked.path);
            }
          }

          return AlertDialog(
            title: const Text('Add New Item'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameTc, decoration: const InputDecoration(labelText: 'Item name')),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory.isEmpty ? null : selectedCategory,
                      items: provider.productCategories.map((pc) => DropdownMenuItem(value: pc['name'] as String, child: Text(pc['name'] as String))).toList(),
                      onChanged: (v) => setS(() => selectedCategory = v ?? ''),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [Expanded(child: TextField(controller: priceTc, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (single)'))), const SizedBox(width: 8), Checkbox(value: advanced, onChanged: (v) => setS(() => advanced = v ?? false)), const Text('Advanced (sizes)')]),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: imagePath == null
                            ? const Center(child: Text('Tap to select product image'))
                            : Image.file(File(imagePath!), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (advanced) ...[
                      const Align(alignment: Alignment.centerLeft, child: Text('Sizes', style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(sizeControllers.length, (i) {
                          final controllers = sizeControllers[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(child: TextField(controller: controllers['label'], decoration: const InputDecoration(labelText: 'Size label (e.g. Regular)'))),
                                const SizedBox(width: 8),
                                SizedBox(width: 140, child: TextField(controller: controllers['price'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'))),
                                const SizedBox(width: 8),
                                if (sizeControllers.length > 1)
                                  IconButton(onPressed: () => setS(() => sizeControllers.removeAt(i)), icon: const Icon(Icons.delete, color: Colors.red))
                              ],
                            ),
                          );
                        }),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(onPressed: () => setS(() => addSizeRow()), icon: const Icon(Icons.add), label: const Text('Add size')),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Cancel')),
              ElevatedButton(onPressed: () async {
                final name = nameTc.text.trim();
                if (name.isEmpty) return;
                if (advanced) {
                  final sizes = <String,double>{};
                  for (final entry in sizeControllers) {
                    final label = entry['label']!.text.trim();
                    final priceText = entry['price']!.text.trim();
                    if (label.isEmpty || priceText.isEmpty) continue;
                    final p = double.tryParse(priceText) ?? 0;
                    sizes[label] = p;
                  }
                  final firstPrice = sizes.isNotEmpty ? sizes.values.first : 0.0;
                  await provider.addProduct(name, selectedCategory, firstPrice, sizes: sizes, imagePath: imagePath ?? '');
                } else {
                  final price = double.tryParse(priceTc.text.trim()) ?? 0;
                  await provider.addProduct(name, selectedCategory, price, imagePath: imagePath ?? '');
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')));
                Navigator.of(dctx).pop();
              }, child: const Text('Save')),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // initialize selected category if not set
    if (_selectedCategory == null && productProvider.productCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedCategory = 'All';
        });
      });
    }

    final categories = productProvider.productCategories.map((pc) => pc['name'] as String).toList();
    final filteredProducts = (productProvider.products.where((p) => _selectedCategory == null || _selectedCategory == 'All' || p.category == _selectedCategory)).toList();

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
                // Categories column
                Container(
                  width: 200,
                  padding: const EdgeInsets.only(right: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(title: const Text('Categories')),
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                selected: _selectedCategory == 'All' || _selectedCategory == null,
                                title: const Text('All'),
                                onTap: () => setState(() => _selectedCategory = 'All'),
                              ),
                              ...categories.map((c) => ListTile(
                                    selected: _selectedCategory == c,
                                    title: Text(c),
                                    onTap: () => setState(() => _selectedCategory = c),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(onPressed: () => _showAddCategoryDialog(context), icon: const Icon(Icons.add), label: const Text('Add Category')),
                        )
                      ],
                    ),
                  ),
                ),

                // Products column
                Expanded(
                  flex: 2,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  ElevatedButton.icon(onPressed: () => _showAddCategoryDialog(context), icon: const Icon(Icons.category), label: const Text('Add Category')),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(onPressed: () => _showAddItemDialog(context), icon: const Icon(Icons.add), label: const Text('Add Item')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (productProvider.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
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

                // Variants column
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
