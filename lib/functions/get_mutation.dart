import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Mutation<R> getMutation<R>(
    {R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
    MutationKey<R>? key,
    List<MutationKey<R>> observeKeys = const []}) {
  MutationKey<R> k = key ?? MutationKey();
  return MutationCache.instance.getMutation(k) ??
      MutationCache.instance.retain<R>(k,
          initialValue: initialValue,
          getInitialValue: getInitialValue,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitializing: onUpdateInitializing,
          onUpdateLoading: onUpdateLoading,
          onClear: onClear,
          onCreate: onCreate,
          onDispose: onDispose,
          static: true,
          observeKeys: observeKeys);
}
