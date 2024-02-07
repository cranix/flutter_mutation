import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';

R? getMutationData<R>(MutationKey<R> key) {
  return MutationCache.instance.getMutation(key)?.data;
}
