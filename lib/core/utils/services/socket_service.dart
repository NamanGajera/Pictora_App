import 'package:pictora/core/utils/services/service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'socket_event_manager.dart';

class SocketService {
  SocketService._internal();

  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  IO.Socket? _socket;

  final SocketEventManager _eventManager = SocketEventManager();

  final List<Function(bool)> _connectionListeners = [];

  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  String? _uri;
  Map<String, dynamic>? _query;
  Map<String, dynamic>? _extraHeaders;

  bool get isConnected => _socket?.connected ?? false;

  String? get id => _socket?.id;

  SocketEventManager get eventManager => _eventManager;

  void addConnectionListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  void removeConnectionListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  void _notifyConnectionListeners(bool connected) {
    for (var listener in _connectionListeners) {
      listener(connected);
    }
  }

  void connect({
    required String uri,
    Map<String, dynamic>? query,
    Map<String, dynamic>? extraHeaders,
    List<String> transports = const ['websocket'],
  }) {
    _uri = uri;
    _query = query;
    _extraHeaders = extraHeaders;

    if (_socket != null) {
      disconnect();
    }

    logDebug(tag: "Socket Log", message: 'Connecting to Socket.IO at $uri');

    try {
      _socket = IO.io(
        uri,
        IO.OptionBuilder()
            .setTransports(transports)
            .enableAutoConnect()
            .enableReconnection()
            .setQuery(query ?? {})
            .setExtraHeaders(extraHeaders ?? {})
            .build(),
      );

      // Set up event listeners
      _socket!.onConnect((_) {
        logDebug(tag: "Socket Log", message: 'Socket.IO connected to $uri with ID: ${_socket!.id}');
        _notifyConnectionListeners(true);
      });

      _socket!.onConnectError((data) {
        logError(tag: "Socket Log", message: 'Socket.IO connect error: $data');
        _notifyConnectionListeners(false);
      });

      _socket!.onDisconnect((_) {
        logDebug(tag: "Socket Log", message: 'Socket.IO disconnected');
        _notifyConnectionListeners(false);
      });

      _socket!.onError((data) {
        logError(tag: "Socket Log", message: 'Socket.IO error: $data');
      });

      _socket!.onReconnect((_) {
        logDebug(tag: "Socket Log", message: 'Socket.IO reconnecting... attempt ${_socket!.io.reconnectionAttempts}');
      });

      _socket!.onReconnectAttempt((_) {
        logDebug(tag: "Socket Log", message: 'Socket.IO reconnection attempt');
      });

      _socket!.onReconnectError((data) {
        logError(tag: "Socket Log", message: 'Socket.IO reconnect error: $data');
      });

      _socket!.onReconnectFailed((_) {
        logError(tag: "Socket Log", message: 'Socket.IO reconnect failed');
      });

      _reRegisterEventHandlers();
    } catch (e) {
      logError(tag: "Socket Log", message: 'Failed to initialize socket: $e');
      _notifyConnectionListeners(false);
    }
  }

  void registerGlobalEvent(String eventName) {
    _socket?.on(eventName, (data) {
      _eventManager.addEvent(eventName, data);
      logDebug(tag: "Socket Log", message: 'Global event received: $eventName with data: $data');
    });
  }

  void registerGlobalEvents(List<String> eventNames) {
    for (var eventName in eventNames) {
      registerGlobalEvent(eventName);
    }
  }

  void _reRegisterEventHandlers() {
    _eventHandlers.forEach((event, handlers) {
      for (var handler in handlers) {
        _socket?.on(event, handler);
      }
    });
  }

  void on(String event, Function(dynamic) callback) {
    if (!_eventHandlers.containsKey(event)) {
      _eventHandlers[event] = [];
    }
    _eventHandlers[event]!.add(callback);

    _socket?.on(event, callback);
  }

  void off(String event, [Function(dynamic)? callback]) {
    if (callback != null) {
      _eventHandlers[event]?.remove(callback);
      _socket?.off(event, callback);
    } else {
      _eventHandlers.remove(event);
      _socket?.off(event);
    }
  }

  void offAll(String event) {
    _eventHandlers.remove(event);
    _socket?.off(event);
  }

  void emit(String event, [dynamic data, Function(dynamic)? ack]) {
    logDebug(tag: "Socket Log", message: 'Emitting event: $event with data: $data');
    if (_socket == null || !_socket!.connected) {
      throw StateError('Socket.IO is not connected');
    }

    if (ack != null) {
      _socket!.emitWithAck(event, data, ack: ack);
    } else {
      _socket!.emit(event, data);
    }
  }

  void reconnect() {
    if (_uri != null) {
      connect(
        uri: _uri!,
        query: _query,
        extraHeaders: _extraHeaders,
      );
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _notifyConnectionListeners(false);
  }

  void dispose() {
    disconnect();
    _connectionListeners.clear();
    _eventHandlers.clear();
    _eventManager.dispose();
  }
}
