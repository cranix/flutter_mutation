import 'dart:async';

import 'package:flutter_mutation/mutation_key.dart';

extension MutationsFutureExtension<R> on Future<R> {
  Future<R> mutate(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutate(this, append: append);
  }
}

extension MutationsFutureOrExtension<R> on FutureOr<R> {
  FutureOr<R> mutate(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutate(this, append: append);
  }
}
