import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../services/local_database.dart';
import '../services/pdf_service.dart';
import '../services/bluetooth_print_service.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();

  @override
  void initState() {
    super.initState();
    // default range: start of today to end of today
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, now.day, 0, 0, 0);
    _to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = context.watch<InvoiceProvider>();
    // only show invoices within selected date range
    final allInvoices = invoiceProvider.invoices;
    final invoicesInRange = allInvoices.where((inv) => inv.timestamp.isAfter(_from.subtract(const Duration(seconds:1))) && inv.timestamp.isBefore(_to.add(const Duration(seconds:1)))).toList();
    final invoices = _filteredInvoices(invoicesInRange);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipts', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),

            // Date range selectors
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _from, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (d != null) setState(() => _from = DateTime(d.year, d.month, d.day, 0, 0, 0));
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(color: const Color(0xFF6D28D9), borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('From', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Text(DateFormat('dd MMM yyyy').format(_from), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _to, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (d != null) setState(() => _to = DateTime(d.year, d.month, d.day, 23, 59, 59));
                    },
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(color: const Color(0xFF6D28D9), borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('To', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Text(DateFormat('dd MMM yyyy').format(_to), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: invoiceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : invoices.isEmpty
                      ? const Center(child: Text('No receipts found for selected range.'))
                      : ListView.separated(
                          itemCount: invoices.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.currency_rupee, color: Colors.green,)),

                                title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('by ${invoice.paymentMethod.name.toUpperCase()}', style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    FutureBuilder<int>(
                                      future: LocalDatabaseService.instance.countInvoiceItems(invoice.id),
                                      builder: (context, snap) {
                                        final count = snap.data ?? 0;
                                        return Text('$count Items · ${DateFormat('dd MMM yyyy - hh:mm a').format(invoice.timestamp)}', style: const TextStyle(color: Colors.grey));
                                      },
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormat.format(invoice.grandTotal), style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.print, size: 18, color: Colors.grey),
                                          tooltip: 'Print/Export',
                                          onPressed: () async {
                                            final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                                            // load items then generate PDF and print
                                            await invoiceProvider.loadInvoiceItems(invoice.id);
                                            final items = invoiceProvider.invoiceItems;
                                            final pdf = await PdfService.generateInvoicePdf(invoice, items);
                                            // Use printing package to show print/share dialog
                                            try {
                                              await Printing.layoutPdf(onLayout: (_) => pdf);
                                            } catch (e) {
                                               if (!mounted) return;
                                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to print invoice')));
                                             }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.print_disabled, size: 18, color: Colors.grey),
                                          tooltip: 'Print to Bluetooth',
                                          onPressed: () async {
                                            final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
                                            final authUserId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
                                            await invoiceProvider.loadInvoiceItems(invoice.id);
                                            final items = invoiceProvider.invoiceItems;
                                            final success = await BluetoothPrintService.instance.printInvoiceThermal(invoice, items, paperWidth: 58);
                                            await LocalDatabaseService.instance.logPrintAttempt(invoice.id, authUserId, success);
                                            if (!success) {
                                              // fallback to PDF
                                              try {
                                                final pdf = await PdfService.generateInvoicePdf(invoice, items);
                                                await Printing.layoutPdf(onLayout: (_) => pdf);
                                              } catch (_) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to print or export invoice')));
                                              }
                                            } else {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Bluetooth printer')));
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6D28D9)),
                                          tooltip: 'Open',
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (_) => InvoiceDetailScreen(invoice: invoice),
                                            ));
                                          },
                                        ),
                                      ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print / Export',
            onPressed: () async {
              final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
              // ensure items loaded
              await invoiceProvider.loadInvoiceItems(widget.invoice.id);
              final items = invoiceProvider.invoiceItems;
              try {
                final pdf = await PdfService.generateInvoicePdf(widget.invoice, items);
                await Printing.layoutPdf(onLayout: (_) => pdf);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to print invoice')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_disabled),
            tooltip: 'Print to Bluetooth',
            onPressed: () async {
              final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
              final authUserId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
              await invoiceProvider.loadInvoiceItems(widget.invoice.id);
              final items = invoiceProvider.invoiceItems;

              final success = await BluetoothPrintService.instance.printInvoiceThermal(widget.invoice, items, paperWidth: 58);
              // log the result
              await LocalDatabaseService.instance.logPrintAttempt(widget.invoice.id, authUserId, success);

              if (!success) {
                // fallback to PDF
                try {
                  final pdf = await PdfService.generateInvoicePdf(widget.invoice, items);
                  await Printing.layoutPdf(onLayout: (_) => pdf);
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to print or export invoice')));
                }
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Bluetooth printer')));
              }
            },
          ),
        ],
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
