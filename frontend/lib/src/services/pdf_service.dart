import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class PdfService {
  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  static Future<Uint8List> generateInvoicePdf(Invoice invoice, List<InvoiceItem> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4, // use A4 fallback; mobile/print dialog will scale as needed
        build: (context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(child: pw.Text('Hacky Pizza', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 6),
                  pw.Text('Invoice: ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(invoice.timestamp)}', style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 8),

                  // Table header
                  pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 3, child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 3, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                  pw.Divider(),

                  // Items
                  ...items.map((it) {
                    return pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(it.productId, style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 2, child: pw.Text(it.quantity.toString(), style: pw.TextStyle(fontSize: 10))),
                        pw.Expanded(flex: 3, child: pw.Text(_currency.format(it.unitPrice), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                        pw.Expanded(flex: 3, child: pw.Text(_currency.format(it.totalPrice), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }).toList(),

                  pw.Divider(),
                  pw.SizedBox(height: 6),

                  // Summary
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(_currency.format(invoice.subtotal), style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(_currency.format(invoice.tax), style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('- ${_currency.format(invoice.discount)}', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),

                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text(_currency.format(invoice.grandTotal), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),

                  pw.SizedBox(height: 12),
                  pw.Center(child: pw.Text('Thank you for your order!', style: pw.TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Generate a small receipt-style PDF preview from settings map
  static Future<Uint8List> generateReceiptPreview(Map<String, String> settings) async {
    final pdf = pw.Document();
    final currency = _currency;
    final businessName = settings['business_name'] ?? 'Hacky Pizza';
    final phone = settings['phone'] ?? '';
    final address = settings['address'] ?? '';
    final gst = settings['gst'] ?? '';
    final footer = settings['footer_text'] ?? 'Thank You, Visit Again.';
    final title = settings['receipt_title'] ?? '** Invoice **';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, 200 * PdfPageFormat.mm), // narrow receipt width (~58mm)
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(businessName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(fontSize: 9)),
                if (address.isNotEmpty) pw.Text(address, style: pw.TextStyle(fontSize: 9)),
                if (gst.isNotEmpty) pw.Text('GST: $gst', style: pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 6),
                pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Row(children: [pw.Expanded(child: pw.Text('Margherita (Regular)')), pw.Text('1 x ${currency.format(149)}')]),
                pw.Row(children: [pw.Expanded(child: pw.Text('Paneer Tikka (Medium)')), pw.Text('1 x ${currency.format(249)}')]),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal'), pw.Text(currency.format(398))]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Tax'), pw.Text(currency.format(20))]),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GRAND TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(currency.format(418), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
                pw.SizedBox(height: 10),
                pw.Text(footer, style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

