import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'constants.dart';

class SocketClient {
  static IO.Socket? socket;

  static void initSocket(Function(String event, dynamic data) onEvent) {
    socket = IO.io(AppConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket?.onConnect((_) {
      print('[Socket] Connected to server');
      socket?.emit('join:branch', 'branch-1');
    });

    socket?.on('order-created', (data) => onEvent('order-created', data));
    socket?.on('kot-created', (data) => onEvent('kot-created', data));
    socket?.on('kot-preparing', (data) => onEvent('kot-preparing', data));
    socket?.on('kot-ready', (data) => onEvent('kot-ready', data));
    socket?.on('bill-generated', (data) => onEvent('bill-generated', data));
    socket?.on('inventory-updated', (data) => onEvent('inventory-updated', data));
  }

  static void disconnect() {
    socket?.disconnect();
  }
}
