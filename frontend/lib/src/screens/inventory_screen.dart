import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../utils/currency_formatter.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<String> _tabs = ['ITEMS', 'CATEGORY', 'MODIFIERS', 'INGREDIENTS'];
  final List<String> _filters = ['All', 'Low Stock', 'Expired'];
  int _selectedTab = 0;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadInventory();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final products = productProvider.products;
    final displayItems = products.isNotEmpty
        ? products
        : _sampleProducts
            .map((item) => Product(
                  id: item['id']!,
                  name: item['name']!,
                  category: item['category']!,
                  imagePath: '',
                  unitType: 'Pc',
                  purchasePrice: item['price']!,
                  sellingPrice: item['price']!,
                  isActive: true,
                  lowStockLimit: 5,
                  taxRate: 5,
                ))
            .toList();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF6D28D9)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'INVENTORY MANAGEMENT',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.search, color: Color(0xFF6D28D9)),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final selected = index == _selectedTab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selectedColor: const Color(0xFF6D28D9),
                        backgroundColor: Colors.grey.shade200,
                        label: Text(
                          _tabs[index],
                          style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_filters.length, (index) {
                        final selected = index == _selectedFilter;
                        return ChoiceChip(
                          selectedColor: const Color(0xFF6D28D9),
                          backgroundColor: Colors.grey.shade200,
                          label: Text(
                            _filters[index],
                            style: TextStyle(color: selected ? Colors.white : Colors.black87),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = index;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Color(0xFF6D28D9)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: inventoryProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.name} Small',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                CurrencyFormatter.format(item.sellingPrice),
                                                style: const TextStyle(fontSize: 16, color: Color(0xFF6D28D9), fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _sizeButton('Small', true),
                                        const SizedBox(width: 8),
                                        _sizeButton('Medium', false),
                                        const SizedBox(width: 8),
                                        _sizeButton('Large', false),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'barcode',
                backgroundColor: const Color(0xFF6D28D9),
                onPressed: () {},
                child: const Icon(Icons.qr_code_scanner),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'add_inventory',
                backgroundColor: const Color(0xFF6D28D9),
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sizeButton(String label, bool selected) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6D28D9) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

const List<Map<String, dynamic>> _sampleProducts = [
  {'id': 'p1', 'name': '5 Papper Pizza', 'category': 'Pizza', 'price': 260.0},
  {'id': 'p2', 'name': 'Achari Do Pyaza', 'category': 'Pizza', 'price': 130.0},
  {'id': 'p3', 'name': 'Capi Bite Pizza', 'category': 'Pizza', 'price': 130.0},
  {'id': 'p4', 'name': 'Capsicum Pizza', 'category': 'Pizza', 'price': 80.0},
  {'id': 'p5', 'name': 'Cheese Corn', 'category': 'Pizza', 'price': 130.0},
  {'id': 'p6', 'name': 'Cheese Loaded Pizza', 'category': 'Pizza', 'price': 210.0},
];
