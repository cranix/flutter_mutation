import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

bool removeObserveMutation<R>(
  MutationKey<R> key, {
  MutationOnUpdateDataCallback<R>? onUpdateData,
  MutationOnUpdateErrorCallback? onUpdateError,
  MutationOnUpdateInitializingCallback? onUpdateInitializing,
  MutationOnUpdateLoadingCallback? onUpdateLoading,
  MutationOnClearCallback? onClear,
  MutationOnCreateCallback<R>? onCreate,
  MutationOnDisposeCallback<R>? onDispose,
}) {
  return MutationCache.instance.removeObserve(key,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitializing: onUpdateInitializing,
      onUpdateLoading: onUpdateLoading,
      onClear: onClear,
      onCreate: onCreate,
      onDispose: onDispose);
}
