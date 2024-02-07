import 'dart:async';

import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

extension MutationsFutureExtension<R> on Future<R> {
  Future<R> mutate(MutationKey<R> retainKey, {bool append = false}) {
    final mutation = MutationCache.instance.getMutation<R>(retainKey);
    return mutation!.mutate(this, append: append);
  }
}

extension MutationsFutureOrExtension<R> on FutureOr<R> {
  FutureOr<R> mutate(MutationKey<R> retainKey, {bool append = false}) {
    final mutation = MutationCache.instance.getMutation<R>(retainKey);
    return mutation!.mutate(this, append: append);
  }
}
