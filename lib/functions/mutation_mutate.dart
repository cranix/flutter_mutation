import 'dart:async';

import 'package:flutter_mutation/functions/get_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';


Future<R> mutationMutate<R>(MutationKey<R> key, FutureOr<R> future,
    {bool append = false}) {
  return getMutation(key: key).mutate(future, append: append);
}
