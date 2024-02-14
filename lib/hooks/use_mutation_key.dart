import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/mutation_key.dart';

MutationKey<R> useMutationKey<R>([String? value]) {
  return useMemoized(() {
    if (value == null) {
      return MutationKey<R>();
    }
    return MutationKey.of<R>(value);
  });
}
