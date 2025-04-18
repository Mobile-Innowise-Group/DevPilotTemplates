import 'dart:async';

import 'package:core/core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketApiProvider {
  final String _baseUrl;
  final Map<String, WebSocketChannel> _urlsToSockets = <String, WebSocketChannel>{};
  final Map<int, StreamSubscription<dynamic>> _handlers = <int, StreamSubscription<dynamic>>{};
  final Map<String, int> _urlsToHandlerCounts = <String, int>{};
  final Map<int, String> _handlersToUrls = <int, String>{};

  WebSocketApiProvider({
    required String baseUrl,
  }) : _baseUrl = baseUrl;

  Future<int> connect({
    required String url,
    required Function(dynamic data) onData,
  }) async {
    final int id = DateTime.timestamp().millisecondsSinceEpoch;
    final Uri uri = Uri.parse('$_baseUrl/$url');
    final WebSocketChannel socket = _urlsToSockets[url] ?? WebSocketChannel.connect(uri);

    _handlers[id] = socket.stream.listen(onData);
    _urlsToSockets[url] = socket;
    _urlsToHandlerCounts[url] = (_urlsToHandlerCounts[url] ?? 0) + 1;
    _handlersToUrls[id] = url;

    return id;
  }

  Future<void> disconnect({
    required int id,
  }) async {
    await _handlers[id]?.cancel();
    _handlers.remove(id);

    final String? url = _handlersToUrls[id];
    if (url == null) {
      throw const AppException.unknown();
    }

    _handlersToUrls.remove(id);

    final int? count = _urlsToHandlerCounts[url];
    if (count == null) {
      throw const AppException.unknown();
    }

    if (count == 1) {
      _urlsToHandlerCounts.remove(url);
      await _urlsToSockets[url]?.sink.close();
      _urlsToSockets.remove(url);
    } else {
      _urlsToHandlerCounts[url] = count - 1;
    }
  }

  Future<void> send({
    required int id,
    required dynamic message,
  }) async {
    final WebSocketChannel? socket = _urlsToSockets[_handlersToUrls[id]];

    if (socket == null) {
      throw const AppException.unknown();
    }

    socket.sink.add(message);
  }
}
