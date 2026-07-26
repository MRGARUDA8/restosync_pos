import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/cart_bottom_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedCategoryIndex = 0;
  String _selectedOrderType = 'Dine-In';
  String _selectedTable = 'T-1';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Pizza Mania',
    'Classic Pizza',
    'Special Pizza',
    'Deluxe Pizza',
    'Cheese Loaded',
    'Kulhad Pizza',
    'Burger',
    'Sandwich',
    'Rolls',
    'Pasta',
    'Sides',
    'Cake'
  ];

  // All Pizza Items Configured with Regular, Medium & Large Sizes
  final List<Map<String, dynamic>> _menuItems = [
    // --- 1. Pizza Mania (Reg / Med / Lrg) ---
    {
      'id': '101',
      'name': 'Onion Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 59, 'Medium': 119, 'Large': 199}
    },
    {
      'id': '102',
      'name': 'Tomato Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 69, 'Medium': 129, 'Large': 209}
    },
    {
      'id': '103',
      'name': 'Capsicum Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 79, 'Medium': 139, 'Large': 219}
    },
    {
      'id': '104',
      'name': 'Golden Corn Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 89, 'Medium': 149, 'Large': 229}
    },
    {
      'id': '105',
      'name': 'Spicy Corn / Onion Capsicum',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 99, 'Medium': 169, 'Large': 249}
    },
    {
      'id': '106',
      'name': 'Paneer Special Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 99, 'Medium': 169, 'Large': 249}
    },
    {
      'id': '107',
      'name': 'Veg Loaded Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 219, 'Large': 319}
    },
    {
      'id': '108',
      'name': 'Extra Veg Loaded Pizza',
      'category': 'Pizza Mania',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 159, 'Medium': 249, 'Large': 349}
    },

    // --- 2. Classic Pizza (Reg: 129 / Med: 229 / Lrg: 329) ---
    {
      'id': '201',
      'name': 'Cheese Corn',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },
    {
      'id': '202',
      'name': 'Fresh Veg',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },
    {
      'id': '203',
      'name': 'Onion & Capsicum',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },
    {
      'id': '204',
      'name': 'Cheese Margherita',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },
    {
      'id': '205',
      'name': 'Achari Do Pyaza',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },
    {
      'id': '206',
      'name': 'Cheese Paneer',
      'category': 'Classic Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 129, 'Medium': 229, 'Large': 329}
    },

    // --- 3. Special Pizza (Reg: 169 / Med: 269 / Lrg: 369) ---
    {
      'id': '301',
      'name': 'Paneer Makhani',
      'category': 'Special Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 169, 'Medium': 269, 'Large': 369}
    },
    {
      'id': '302',
      'name': 'Country Special',
      'category': 'Special Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 169, 'Medium': 269, 'Large': 369}
    },
    {
      'id': '303',
      'name': 'Spicy Delight',
      'category': 'Special Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 169, 'Medium': 269, 'Large': 369}
    },
    {
      'id': '304',
      'name': 'Kadhai Paneer',
      'category': 'Special Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 169, 'Medium': 269, 'Large': 369}
    },

    // --- 4. Deluxe Pizza (Reg: 209 / Med: 309 / Lrg: 409) ---
    {
      'id': '401',
      'name': 'Farmhouse',
      'category': 'Deluxe Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 209, 'Medium': 309, 'Large': 409}
    },
    {
      'id': '402',
      'name': 'Green Mexican Wave',
      'category': 'Deluxe Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 209, 'Medium': 309, 'Large': 409}
    },
    {
      'id': '403',
      'name': 'Indi Tandoori',
      'category': 'Deluxe Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 209, 'Medium': 309, 'Large': 409}
    },
    {
      'id': '404',
      'name': 'Gourmet Pizza',
      'category': 'Deluxe Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 209, 'Medium': 309, 'Large': 409}
    },
    {
      'id': '405',
      'name': 'Veggie Paradise',
      'category': 'Deluxe Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 209, 'Medium': 309, 'Large': 409}
    },

    // --- 5. Cheese Loaded (Reg: 259 / Med: 359 / Lrg: 459) ---
    {
      'id': '501',
      'name': 'Veg Deluxe',
      'category': 'Cheese Loaded',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 259, 'Medium': 359, 'Large': 459}
    },
    {
      'id': '502',
      'name': 'Hacky Pizza Special',
      'category': 'Cheese Loaded',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 259, 'Medium': 359, 'Large': 459}
    },

    // --- 6. Kulhad Pizza (Reg / Med) ---
    {
      'id': '601',
      'name': 'Kulhad Pizza',
      'category': 'Kulhad Pizza',
      'isVeg': true,
      'hasVariants': true,
      'variants': {'Regular': 99, 'Medium': 129}
    },

    // --- Single Items (Burgers, Sandwiches, Rolls, Pasta, Sides, Cake) ---
    {
      'id': '701',
      'name': 'Classic Veg Burger',
      'price': 49,
      'category': 'Burger',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '702',
      'name': 'Classic Tikki Burger',
      'price': 59,
      'category': 'Burger',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '703',
      'name': 'Premium Tikki Burger',
      'price': 69,
      'category': 'Burger',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '801',
      'name': 'Veg Sandwich',
      'price': 49,
      'category': 'Sandwich',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '802',
      'name': 'Grilled Sandwich',
      'price': 59,
      'category': 'Sandwich',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '901',
      'name': 'Veg Roll',
      'price': 49,
      'category': 'Rolls',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '902',
      'name': 'Paneer Roll',
      'price': 69,
      'category': 'Rolls',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1001',
      'name': 'White Sauce Pasta',
      'price': 129,
      'category': 'Pasta',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1002',
      'name': 'Red Sauce Pasta',
      'price': 129,
      'category': 'Pasta',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1101',
      'name': 'Garlic Breadstick',
      'price': 69,
      'category': 'Sides',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1102',
      'name': 'Stuffed Garlic Bread',
      'price': 129,
      'category': 'Sides',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1201',
      'name': 'Cake Half (0.5 KG)',
      'price': 270,
      'category': 'Cake',
      'isVeg': true,
      'hasVariants': false
    },
    {
      'id': '1202',
      'name': 'Cake Full (1 KG)',
      'price': 530,
      'category': 'Cake',
      'isVeg': true,
      'hasVariants': false
    },
  ];

  // Cart Management
  final Map<String, Map<String, dynamic>> _cart = {};

  void _addItemToCart(
      Map<String, dynamic> item, String? variantName, double price) {
    final cartKey = variantName != null
        ? '${item['id']}_$variantName'
        : item['id'].toString();
    final displayName =
        variantName != null ? '${item['name']} ($variantName)' : item['name'];

    setState(() {
      if (_cart.containsKey(cartKey)) {
        _cart[cartKey]!['quantity'] = _cart[cartKey]!['quantity'] + 1;
      } else {
        _cart[cartKey] = {
          'id': cartKey,
          'baseId': item['id'],
          'name': displayName,
          'price': price,
          'quantity': 1,
        };
      }
    });
  }

  void _removeCartItemByKey(String cartKey) {
    setState(() {
      if (_cart.containsKey(cartKey)) {
        if (_cart[cartKey]!['quantity'] > 1) {
          _cart[cartKey]!['quantity'] = _cart[cartKey]!['quantity'] - 1;
        } else {
          _cart.remove(cartKey);
        }
      }
    });
  }

  void _showVariantSelectionDialog(Map<String, dynamic> item) {
    final variants = item['variants'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Size: ${item['name']}',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: variants.entries.map((entry) {
              final size = entry.key;
              final price = (entry.value as num).toDouble();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(size,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  trailing: Text('₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    _addItemToCart(item, size, price);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int get _totalCartItems =>
      _cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get _totalCartPrice => _cart.values.fold(
      0.0,
      (sum, item) =>
          sum + ((item['price'] as double) * (item['quantity'] as int)));

  List<Map<String, dynamic>> get _filteredItems {
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _menuItems.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item['category'] == selectedCategory;
      final matchesSearch = item['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int _getItemTotalCountInCart(String baseId) {
    int count = 0;
    _cart.forEach((key, value) {
      if (value['baseId'] == baseId || key == baseId) {
        count += (value['quantity'] as int);
      }
    });
    return count;
  }

  Map<String, int> get _cartQuantitiesOnly {
    final Map<String, int> map = {};
    _cart.forEach((key, value) {
      map[key] = value['quantity'] as int;
    });
    return map;
  }

  List<Map<String, dynamic>> get _cartItemListFormatted {
    return _cart.values
        .map((v) => {
              'id': v['id'],
              'name': v['name'],
              'price': v['price'],
            })
        .toList();
  }

  void _openCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CartBottomSheet(
        cart: _cartQuantitiesOnly,
        menuItems: _cartItemListFormatted,
        totalPrice: _totalCartPrice,
        selectedTable: _selectedTable,
        orderType: _selectedOrderType,
        onAdd: (key) {
          final item = _cart[key];
          if (item != null) {
            _addItemToCart(
                {'id': item['baseId'] ?? item['id'], 'name': item['name']},
                null,
                (item['price'] as num).toDouble());
          }
        },
        onRemove: _removeCartItemByKey,
        onClearCart: () {
          setState(() => _cart.clear());
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hacky Pizza Town POS',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('Table: $_selectedTable • $_selectedOrderType',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTable,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                items: ['T-1', 'T-2', 'T-3', 'T-4', 'T-5', 'Takeaway']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTable = val);
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Pizza, Burger, Pasta...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(10)),
                    child:
                        const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                  color: const Color(0xFF1E293B),
                  onSelected: (type) =>
                      setState(() => _selectedOrderType = type),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'Dine-In',
                        child: Text('Dine-In',
                            style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(
                        value: 'Takeaway',
                        child: Text('Takeaway',
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
              ],
            ),
          ),

          // Horizontal Categories Slider
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.white12),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Menu Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final baseId = item['id'].toString();
                final hasVariants = item['hasVariants'] == true;
                final totalQtyInCart = _getItemTotalCountInCart(baseId);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: totalQtyInCart > 0
                            ? const Color(0xFF6366F1)
                            : Colors.white10,
                        width: totalQtyInCart > 0 ? 1.5 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.circle,
                              size: 14, color: Colors.green),
                          if (hasVariants)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('Sizes Available',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF818CF8),
                                      fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 4),

                      // Starting Price Text
                      Text(
                        hasVariants
                            ? '₹${(item['variants']['Regular'])} Onwards'
                            : '₹${item['price']}',
                        style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Add Button Triggering Size Popup
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (hasVariants) {
                              _showVariantSelectionDialog(item);
                            } else {
                              _addItemToCart(item, null,
                                  (item['price'] as num).toDouble());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: totalQtyInCart > 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            totalQtyInCart > 0
                                ? '+ ADDED ($totalQtyInCart)'
                                : '+ ADD',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Cart Strip
      bottomNavigationBar: _totalCartItems > 0
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_totalCartItems ITEMS IN CART',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        Text('₹${_totalCartPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _openCartBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('VIEW BILL / KOT',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
