import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/invoice.dart';
import '../providers/auth_provider.dart';
import '../providers/invoice_provider.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Invoice> _filteredInvoices(List<Invoice> invoices) {
    if (_searchQuery.isEmpty) return invoices;
    return invoices.where((invoice) {
      final normalizedQuery = _searchQuery.toLowerCase();
      return invoice.invoiceNumber.toLowerCase().contains(normalizedQuery) ||
          invoice.customerId.toLowerCase().contains(normalizedQuery) ||
          invoice.paymentMethod.name.toLowerCase().contains(normalizedQuery) ||
          invoice.orderType.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Color _statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.completed:
        return Colors.greenAccent.shade400;
      case InvoiceStatus.cancelled:
        return Colors.redAccent.shade400;
      case InvoiceStatus.refunded:
        return Colors.orangeAccent.shade400;
      case InvoiceStatus.pending:
        return Colors.blueAccent.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = context.watch<InvoiceProvider>();
    final invoices = _filteredInvoices(invoiceProvider.invoices);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice History', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _searchQuery = value.trim();
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Search invoices by number, customer, payment or order type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () => invoiceProvider.loadInvoices(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: invoiceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : invoices.isEmpty
                    ? const Center(child: Text('No invoices found.'))
                    : ListView.separated(
                        itemCount: invoices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(dateFormat.format(invoice.timestamp)),
                                  const SizedBox(height: 4),
                                  Text('${invoice.orderType.name.toUpperCase()} · ${invoice.paymentMethod.name.toUpperCase()}'),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(currencyFormat.format(invoice.grandTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Chip(
                                    label: Text(invoice.status.name.toUpperCase()),
                                    backgroundColor: _statusColor(invoice.status),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => InvoiceDetailScreen(invoice: invoice),
                                ));
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({required this.invoice, super.key});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoiceItems(widget.invoice.id);
    });
  }

  Future<void> _showActionDialog(BuildContext context, bool isRefund) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final reasonController = TextEditingController();
    bool restockIngredients = true;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isRefund ? 'Refund Invoice' : 'Cancel Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: restockIngredients,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    restockIngredients = value;
                  });
                },
                title: const Text('Restock mapped recipe ingredients'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) return;
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(isRefund ? 'Confirm Refund' : 'Confirm Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final userId = authProvider.user?.id ?? '';
    final reason = reasonController.text.trim();

    if (isRefund) {
      await invoiceProvider.refundInvoice(widget.invoice.id, reason, restockIngredients, userId);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Invoice refunded successfully.')));
    } else {
      await invoiceProvider.cancelInvoice(widget.invoice.id, reason, restockIngredients, userId);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Invoice cancelled successfully.')));
    }

    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = context.watch<InvoiceProvider>();
    final invoiceItems = invoiceProvider.invoiceItems;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice.invoiceNumber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.invoice.invoiceNumber, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(dateFormat.format(widget.invoice.timestamp)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(widget.invoice.status.name.toUpperCase())),
                        Chip(label: Text(widget.invoice.orderType.name.toUpperCase())),
                        Chip(label: Text(widget.invoice.paymentMethod.name.toUpperCase())),
                      ],
                    ),
                    if (widget.invoice.customerId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Customer: ${widget.invoice.customerId}'),
                    ],
                    if (widget.invoice.deliveryAddress.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Delivery Address: ${widget.invoice.deliveryAddress}'),
                    ],
                    if (widget.invoice.riderName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Rider: ${widget.invoice.riderName}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: invoiceItems.isEmpty
                      ? const Center(child: Text('No invoice items available.'))
                      : ListView.separated(
                          itemCount: invoiceItems.length,
                          separatorBuilder: (context, index) => const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final item = invoiceItems[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product ID: ${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Variant ID: ${item.variantId} • Qty: ${item.quantity} ${item.unit}'),
                                const SizedBox(height: 4),
                                Text('Rate: ${currencyFormat.format(item.unitPrice)} | Total: ${currencyFormat.format(item.totalPrice)}'),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', currencyFormat.format(widget.invoice.subtotal)),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Tax', currencyFormat.format(widget.invoice.tax)),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Discount', '- ${currencyFormat.format(widget.invoice.discount)}'),
                    const SizedBox(height: 8),
                    const Divider(),
                    _buildSummaryRow('Grand Total', currencyFormat.format(widget.invoice.grandTotal), isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.invoice.status == InvoiceStatus.completed || widget.invoice.status == InvoiceStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionDialog(context, true),
                      icon: const Icon(Icons.restore_from_trash),
                      label: const Text('Refund'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showActionDialog(context, false),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
