import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<bool> connect() async {
    final isConnected = await _printer.isConnected ?? false;
    if (isConnected) {
      return true;
    }
    final devices = await _printer.getBondedDevices();
    if (devices.isEmpty) {
      return false;
    }
    await _printer.connect(devices.first);
    final connected = await _printer.isConnected ?? false;
    return connected;
  }

  Future<void> disconnect() async {
    final isConnected = await _printer.isConnected ?? false;
    if (isConnected) {
      await _printer.disconnect();
    }
  }

  Future<void> printInvoice(String invoiceNumber, String body) async {
    final isConnected = await _printer.isConnected ?? false;
    if (!isConnected) {
      await generatePdfFallback(invoiceNumber, body);
      return;
    }
    _printer.printNewLine();
    _printer.printCustom('Hacky Pizza POS', 3, 1);
    _printer.printCustom('Invoice #$invoiceNumber', 1, 1);
    _printer.printNewLine();
    _printer.printCustom(body, 1, 0);
    _printer.printNewLine();
    _printer.paperCut();
  }

  Future<void> generatePdfFallback(String invoiceNumber, String body) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Hacky Pizza POS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('Invoice #$invoiceNumber', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 16),
            pw.Text(body),
          ],
        ),
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_$invoiceNumber.pdf');
  }
}
