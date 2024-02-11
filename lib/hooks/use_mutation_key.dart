import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/mutation_key.dart';

MutationKey<R> useMutationKey<R>({bool static = false}) {
  return useMemoized(() => MutationKey<R>(static: static));
}
