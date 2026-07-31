import 'package:flutter/foundation.dart';

import '../services/printer_service.dart';
import '../services/socket_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _printerConnected = false;
  String _printerMac = '';
  DateTime? _lastConnected;
  final PrinterService _printerService = PrinterService.instance;
  final SocketService _socketService = SocketService.instance;

  bool get printerConnected => _printerConnected;
  String get printerMac => _printerMac;
  DateTime? get lastConnected => _lastConnected;

  Future<void> connectPrinter() async {
    _printerConnected = await _printerService.connect();
    if (_printerConnected) {
      _printerMac = 'Bluetooth Printer';
      _lastConnected = DateTime.now();
    }
    notifyListeners();
  }

  Future<void> disconnectPrinter() async {
    await _printerService.disconnect();
    _printerConnected = false;
    _printerMac = '';
    notifyListeners();
  }

  void initializeSocket(String url) {
    _socketService.connect(url);
  }
}
