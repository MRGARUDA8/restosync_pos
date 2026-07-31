import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();
  socket_io.Socket? _socket;

  void connect(String url) {
    _socket = socket_io.io(url, socket_io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build());
    _socket?.onConnect((_) {
      // ignore: avoid_print
      print('KDS socket connected');
    });

    _socket?.onDisconnect((_) {
      // ignore: avoid_print
      print('KDS socket disconnected');
    });
  }

  void emitOrderUpdate(Map<String, dynamic> payload) {
    _socket?.emit('order_update', payload);
  }

  void onOrderEvent(void Function(dynamic) callback) {
    _socket?.on('order_update', callback);
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
