import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

bool removeMutation<R>(MutationKey<R> key) {
  return MutationCache.instance.removeStatic(key);
}
