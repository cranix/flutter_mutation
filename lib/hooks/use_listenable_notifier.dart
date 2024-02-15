import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<T> useListenableNotifier<T>(T initialValue,
    [List<Object?>? keys]) {
  final state = useValueNotifier<T>(initialValue, keys);
  return useListenable(state);
}
