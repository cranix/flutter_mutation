import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

void mutationClearError<R>(MutationKey<R> key) {
  MutationCache.instance.getMutation(key)?.clearError();
}
