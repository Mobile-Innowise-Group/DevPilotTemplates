import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../bloc/app_error_handler_bloc.dart';

class AppErrorHandlerWrapper extends StatelessWidget {
  final Widget child;

  const AppErrorHandlerWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppErrorHandlerBloc>(
      lazy: false,
      create: (_) => AppErrorHandlerBloc(
        appEventObserver: appLocator<AppEventObserver>(),
      ),
      child: child,
    );
  }
}
