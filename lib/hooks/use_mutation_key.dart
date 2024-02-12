import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/mutation_key.dart';

MutationKey<R> useMutationKey<R>() {
  return useMemoized(() => MutationKey<R>.autoClose());
}
