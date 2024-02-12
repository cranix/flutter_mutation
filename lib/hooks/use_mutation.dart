import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Mutation<R> useMutation<R>(
    {MutationKey<R>? key,
    R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
    List<MutationKey<R>> observeKeys = const []}) {
  final memoKey = useMemoized(() => key ?? MutationKey.autoClose());
  final mutation = useMemoized(() {
    final m = MutationCache.instance.retain<R>(memoKey,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
    memoKey.setMutation(m);
    return m;
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
      bool released = MutationCache.instance.release(memoKey);
      if (released) {
        mutation.close();
      }
    };
  }, [mutation]);
  return mutation;
}
