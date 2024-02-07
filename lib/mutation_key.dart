import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/functions/mutation_clear.dart';
import 'package:flutter_mutation/functions/mutation_clear_error.dart';
import 'package:flutter_mutation/functions/mutation_mutate.dart';

class MutationKey<R> {
  MutationKey();

  @override
  String toString() {
    return shortHash(this);
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) {
    return mutationMutate(this, future, append: append);
  }

  clear() {
    mutationClear(this);
  }

  clearError() {
    mutationClearError(this);
  }
}
