import 'dart:async';

import 'package:flutter_mutation/mutation_key.dart';

extension MutationsFutureExtension<R> on Future<R> {
  Future<R> mutateNowOf(String of, {bool append = false}) {
    final key = MutationKey.of<R>(of);
    return key.mutateNow(this, append: append);
  }

  Future<R> mutateNow(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutateNow(this, append: append);
  }
}

extension MutationsFutureOrExtension<R> on FutureOr<R> {
  Future<R> mutateNowOf(String of, {bool append = false}) {
    final key = MutationKey.of<R>(of);
    return key.mutateNow(this, append: append);
  }

  FutureOr<R> mutateNow(MutationKey<R> retainKey, {bool append = false}) {
    return retainKey.mutateNow(this, append: append);
  }
}
