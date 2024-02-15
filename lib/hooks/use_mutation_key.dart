import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/exception/mutation_exception.dart';
import 'package:flutter_mutation/mutation_key.dart';

MutationKey<R> useMutationKey<R>({String? of, MutationKey<R>? key}) {
  return useMemoized(() {
    if (of != null && key != null) {
      throw const MutationException("of and key 같이 쓸수 없음.");
    }
    if (of == null) {
      return key ?? MutationKey<R>();
    }
    return MutationKey.of<R>(of);
  }, [of, key]);
}
