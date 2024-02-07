import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_exception.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Mutation<R> useMutation<R>(
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
    bool static = false,
    List<MutationKey<R>> observeKeys = const []}) {
  if (static && key == null) {
    throw const MutationException("static must have retainKey");
  }
  MutationKey<R> memoKey = useMemoized(() => key ?? MutationKey(), [key]);
  final mutation = useMemoized(() {
    return MutationCache.instance.retain<R>(memoKey,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitializing: onUpdateInitializing,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear,
        onCreate: onCreate,
        onDispose: onDispose,
        static: static,
        observeKeys: observeKeys);
  }, [memoKey]);

  useEffect(() {
    if (mutation.isInitilized) {
      return;
    }
    if (getInitialValue == null) {
      return;
    }
    Future.delayed(Duration.zero, () {
      mutation.updateInitialize(getInitialValue);
    });
  }, [mutation, getInitialValue]);

  useEffect(() {
    return () {
      MutationCache.instance.release(memoKey);
    };
  }, [mutation]);
  return mutation;
}
