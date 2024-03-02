import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_mutation_key.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Mutation<R> useMutation<R>(
    {MutationKey<R>? key,
    String? keyOf,
    MutationInitialDataCallback<R>? initialData,
    MutationMutateCallback<R>? initialMutate,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
    List<MutationKey<R>> observeKeys = const []}) {
  final mutationKey = useMutationKey(of: keyOf, key: key);
  final mutation = useMemoized(() {
    final m = MutationCache.instance.retain<R>(mutationKey,
        initialData: initialData,
        initialMutate: initialMutate,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
    mutationKey.setMutation(m);
    return m;
  }, [mutationKey]);
  useEffect(() {
    if (mutation.isInitilized) {
      return;
    }
    if (initialMutate == null) {
      return;
    }
    Future.delayed(Duration.zero, () {
      mutation.updateInitialMutate(initialMutate);
    });
  }, [mutation, initialMutate]);
  useEffect(() {
    return () {
      MutationCache.instance.release(mutationKey);
    };
  }, [mutation]);
  return mutation;
}
