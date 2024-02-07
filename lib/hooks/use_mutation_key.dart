import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_exception.dart';

MutationKey<R> useMutationKey<R>() {
  return useMemoized(() => MutationKey());
}
