import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';

part 'app_error_handler_event.dart';
part 'app_error_handler_state.dart';

class AppErrorHandlerBloc extends Bloc<AppErrorHandlerEvent, AppErrorHandlerState> {
  final AppEventObserver _appEventObserver;

  late final StreamSubscription<CoreEvent> _coreEventSubscription;
  late final StreamSubscription<DomainEvent> _domainEventSubscription;

  AppErrorHandlerBloc({
    required AppEventObserver appEventObserver,
  })  : _appEventObserver = appEventObserver,
        super(const AppErrorHandlerState()) {
    on<CoreEventReceived>(_onCoreEventReceived);
    on<DomainEventReceived>(_onDomainEventReceived);

    _coreEventSubscription = _appEventObserver.observe<CoreEvent>(
      (CoreEvent event) => add(CoreEventReceived(event)),
    );

    _domainEventSubscription = _appEventObserver.observe<DomainEvent>(
      (DomainEvent event) => add(DomainEventReceived(event)),
    );
  }

  Future<void> _onCoreEventReceived(
    CoreEventReceived event,
    Emitter<AppErrorHandlerState> emit,
  ) async {
    switch (event.data) {
      case InternetConnectionLostEvent():
      // TODO: Handle InternetConnectionLostEvent
    }
  }

  Future<void> _onDomainEventReceived(
    DomainEventReceived event,
    Emitter<AppErrorHandlerState> emit,
  ) async {
    switch (event.data) {
      case UnauthorizedEvent():
      // TODO: Handle UnauthorizedEvent
    }
  }

  @override
  Future<void> close() async {
    await _coreEventSubscription.cancel();
    await _domainEventSubscription.cancel();
    await super.close();
  }
}
