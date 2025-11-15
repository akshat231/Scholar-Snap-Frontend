import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';
import 'package:scholar_snap_frontend/utils/serverConfig.dart';
import '../presentation/widgets/updateSnackBar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger();

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket _socket;

  SocketService._internal();

  void initSocket({
    required String userId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
      final protocol = dotenv.env['BACKEND_PROTOCOL'] ?? 'http';
  final host = dotenv.env['BACKEND_HOST'] ?? '10.0.2.2';
  final port = dotenv.env['BACKEND_PORT'] ?? '5000';
    final url = '$protocol://$host:$port';
_socket = IO.io(
 url,
  IO.OptionBuilder().setTransports(['websocket']).build(),
);

    _socket.onConnect((_) {
      logger.i('✅ Connected to socket server as user: $userId');
      _socket.emit('subscribe', {'userId': userId});
    });

    _socket.onAny((event, data) {
      logger.i('📡 Event received: $event');
      logger.i('📦 Data type: ${data.runtimeType} - Value: $data');
    });

    _socket.on('doc_status_update', (data) {
      try {
        final decoded = data is String ? jsonDecode(data) : data;

        logger.i('📩 Document update received: $decoded');
        onUpdate(
          decoded,
        ); // Passing whole payload: { userId, docId, updatedField }

        final status =
            decoded['updatedField']; // ✅ this is a String like 'summary'
        final documentName = decoded['docId'];

        switch (status) {
          case 'summary':
            showGlobalSnackBar('✅ Summary has been generated for $documentName!');
            break;
          case 'citation':
            showGlobalSnackBar('📚 Citation has been generated for $documentName!');
            break;
          case 'embedding':
            showGlobalSnackBar('🧠 Embedding has been generated for $documentName!');
            break;
          default:
            logger.w('⚠️ Unknown status: $status');
        }
      } catch (e, stack) {
        logger.e('❌ Socket handler error: $e\n$stack');
      }
    });

    _socket.onDisconnect((_) => logger.i('🔌 Disconnected from socket'));
    _socket.onConnectError((err) => logger.e('❗ Connect error: $err'));
    _socket.onError((err) => logger.e('❗ Socket error: $err'));
  }

  void dispose() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    _socket.dispose();
    logger.i('🧹 Socket disposed');
  }
}
