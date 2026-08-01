import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';

class BluetoothPrintService {
  BluetoothPrintService._();
  static final BluetoothPrintService instance = BluetoothPrintService._();
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    final devices = await _printer.getBondedDevices();
    return devices;
  }

  Future<bool> connectTo(BluetoothDevice device) async {
    try {
      await _printer.connect(device);
      final connected = await _printer.isConnected ?? false;
      return connected;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
    } catch (_) {}
  }

  Future<bool> printInvoiceThermal(Invoice invoice, List<InvoiceItem> items, {int paperWidth = 58}) async {
    // Returns true on success, false on failure
    try {
      final isConnected = await _printer.isConnected ?? false;
      if (!isConnected) {
        // try to auto-connect first paired device
        final devices = await getPairedDevices();
        if (devices.isNotEmpty) {
          try {
            await _printer.connect(devices.first);
          } catch (_) {}
        }
      }

      final connectedNow = await _printer.isConnected ?? false;
      if (!connectedNow) return false;

      // Header
      await _printer.printNewLine();
      await _printer.printCustom('Hacky Pizza', 3, 1);
      await _printer.printCustom('Invoice: ${invoice.invoiceNumber}', 1, 1);
      await _printer.printNewLine();

      // Items - use 3 column layout: name, qty, total (approx)
      for (final it in items) {
        final name = it.productId.length > 16 ? it.productId.substring(0, 16) : it.productId;
        final qty = it.quantity.toString();
        final total = (it.totalPrice).toStringAsFixed(2);
        await _printer.print3Column(name, qty, total, 1);
      }

      await _printer.printNewLine();
      await _printer.printLeftRight('Subtotal', invoice.subtotal.toStringAsFixed(2), 1);
      await _printer.printLeftRight('Tax', invoice.tax.toStringAsFixed(2), 1);
      await _printer.printLeftRight('Discount', '-${invoice.discount.toStringAsFixed(2)}', 1);
      await _printer.printNewLine();
      await _printer.printLeftRight('GRAND TOTAL', invoice.grandTotal.toStringAsFixed(2), 2);
      await _printer.printNewLine();
      await _printer.printCustom('Payment: ${invoice.paymentMethod.name.toUpperCase()}', 1, 0);
      await _printer.printNewLine();
      await _printer.printCustom('Thank you!', 1, 1);
      await _printer.printNewLine();
      await _printer.paperCut();

      return true;
    } catch (e) {
      // best effort: disconnect on error
      try {
        await _printer.disconnect();
      } catch (_) {}
      return false;
    }
  }
}
