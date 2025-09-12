import 'dart:async';

class SocketEventManager {
  static final SocketEventManager _instance = SocketEventManager._internal();
  factory SocketEventManager() => _instance;
  SocketEventManager._internal();

  final Map<String, StreamController<dynamic>> _streamControllers = {};

  Stream<dynamic> eventStream(String eventName) {
    if (!_streamControllers.containsKey(eventName)) {
      _streamControllers[eventName] = StreamController<dynamic>.broadcast();
    }
    return _streamControllers[eventName]!.stream;
  }

  void addEvent(String eventName, dynamic data) {
    if (!_streamControllers.containsKey(eventName)) {
      _streamControllers[eventName] = StreamController<dynamic>.broadcast();
    }
    _streamControllers[eventName]!.add(data);
  }

  void dispose() {
    _streamControllers.forEach((_, controller) => controller.close());
    _streamControllers.clear();
  }
}
