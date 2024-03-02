import 'dart:async';

import 'package:flutter_mutation/mutation_key.dart';

extension MutationsFutureExtension<R> on Future<R> {
  Future<R> mutateNow(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutateNow(this, append: append);
  }
}

extension MutationsFutureOrExtension<R> on FutureOr<R> {
  FutureOr<R> mutateNow(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutateNow(this, append: append);
  }
}
