import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/invoice.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../services/printer_service.dart';
import '../utils/currency_formatter.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  ProductVariant? _selectedVariant;
  Product? _selectedProduct;
  double _quantity = 1;
  String _customerId = '';
  String _deliveryAddress = '';
  String _riderName = '';
  double _discount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  void _addItemToCart(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (_selectedProduct != null && _selectedVariant != null) {
      orderProvider.addToCart(_selectedProduct!, _selectedVariant!, _quantity);
    }
  }

  Future<void> _checkout(OrderType orderType) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return;
    final totalAmount = orderProvider.calculateGrandTotal(orderProvider.calculateTax(5), _discount);
    final invoiceNumber = await orderProvider.createInvoice(
      customerId: _customerId,
      paymentMethod: PaymentMethod.cash,
      orderType: orderType,
      userId: authProvider.user!.id,
      discount: _discount,
      deliveryAddress: _deliveryAddress,
      riderName: _riderName,
    );
    await PrinterService.instance.printInvoice(invoiceNumber, 'Paid: ${CurrencyFormatter.format(totalAmount)}');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice $invoiceNumber created')));
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POS Billing', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Product'),
                        const SizedBox(height: 12),
                        DropdownButton<Product>(
                          isExpanded: true,
                          value: _selectedProduct,
                          hint: const Text('Choose product'),
                          items: productProvider.products
                              .map((product) => DropdownMenuItem(value: product, child: Text(product.name)))
                              .toList(),
                          onChanged: (product) {
                            setState(() {
                              _selectedProduct = product;
                              _selectedVariant = null;
                            });
                            if (product != null) {
                              productProvider.loadVariants(product.id);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<ProductVariant>(
                          isExpanded: true,
                          value: _selectedVariant,
                          hint: const Text('Choose size/variant'),
                          items: productProvider.variants
                              .map((variant) => DropdownMenuItem(value: variant, child: Text('${variant.sizeName} - ${CurrencyFormatter.format(variant.price)}')))
                              .toList(),
                          onChanged: (variant) {
                            setState(() {
                              _selectedVariant = variant;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Quantity:'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Slider(
                                min: 0.5,
                                max: 10,
                                divisions: 19,
                                value: _quantity,
                                label: _quantity.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    _quantity = value;
                                  });
                                },
                              ),
                            ),
                            Text(_quantity.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Cart'),
                          onPressed: () => _addItemToCart(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        if (orderProvider.cartItems.isEmpty)
                          const Text('Cart is empty, add items to start billing.')
                        else
                          ...orderProvider.cartItems.map((item) {
                            return ListTile(
                              title: Text('${item.product.name} (${item.variant.sizeName})'),
                              subtitle: Text('${item.quantity} ${item.product.unitType} x ${CurrencyFormatter.format(item.variant.price)}'),
                              trailing: Text(CurrencyFormatter.format(item.lineTotal)),
                            );
                          }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(CurrencyFormatter.format(orderProvider.subtotal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (5%)'),
                            Text(CurrencyFormatter.format(orderProvider.calculateTax(5))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount'),
                            Text(CurrencyFormatter.format(_discount)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(CurrencyFormatter.format(orderProvider.calculateGrandTotal(orderProvider.calculateTax(5), _discount)), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Customer ID / Mobile', border: OutlineInputBorder()),
                          onChanged: (value) => _customerId = value,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
                          onChanged: (value) => _deliveryAddress = value,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Rider Name', border: OutlineInputBorder()),
                          onChanged: (value) => _riderName = value,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Flat Discount', border: OutlineInputBorder()),
                          onChanged: (value) => _discount = double.tryParse(value) ?? 0,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.shopping_bag),
                              label: const Text('Take Away'),
                              onPressed: () => _checkout(OrderType.takeAway),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delivery_dining),
                              label: const Text('Delivery'),
                              onPressed: () => _checkout(OrderType.delivery),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
