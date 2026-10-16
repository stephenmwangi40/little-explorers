import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<AppScope>()!.widget as AppScope).notifier!;
}

/// Reduce motion: the app setting or the operating-system setting.
bool reduceMotion(BuildContext context) {
  final scope = context.getElementForInheritedWidgetOfExactType<AppScope>();
  final app = scope == null ? false : (scope.widget as AppScope).notifier!.settings.reduceMotion;
  return app || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
}
