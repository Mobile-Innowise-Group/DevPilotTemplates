import 'dart:async';

import 'package:core/core.dart';

class AppEvenBusImpl implements AppEventNotifier, AppEventObserver {
  final StreamController<AppEvent> _controller = StreamController<AppEvent>.broadcast();

  @override
  StreamSubscription<T> observe<T extends AppEvent>(
    void Function(T event) handler, {
    bool exactType = false,
  }) {
    return _controller.stream
        .where((AppEvent event) => event.runtimeType == T || (!exactType && event is T))
        .cast<T>()
        .listen(handler);
  }

  @override
  void notify(AppEvent event) => _controller.add(event);

  Future<void> dispose() async {
    await _controller.close();
  }
}
