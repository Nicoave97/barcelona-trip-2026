import 'package:flutter/widgets.dart';

import 'trip_controller.dart';

class TripScope extends InheritedNotifier<TripController> {
  const TripScope({
    super.key,
    required TripController controller,
    required super.child,
  }) : super(notifier: controller);

  static TripController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TripScope>();
    assert(scope != null, 'TripScope non trovato nell’albero widget');
    return scope!.notifier!;
  }
}
