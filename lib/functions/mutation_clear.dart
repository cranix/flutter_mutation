import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

void mutationClear<R>(MutationKey<R> key) {
  MutationCache.instance.getMutation(key)?.clear();
}
