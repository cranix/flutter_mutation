import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/hooks/use_listenable_notifier.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

bool useMutationLoading<R>(
    {MutationKey<R>? key,
    String? keyOf,
    MutationInitialDataCallback<R>? initialData,
    MutationLazyInitialDataCallback<R>? lazyInitialData,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
    List<MutationKey<R>> observeKeys = const []}) {
  final mutation = useMutation(
      key: key,
      keyOf: keyOf,
      initialData: initialData,
      lazyInitialData: lazyInitialData,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitialized: onUpdateInitialized,
      onUpdateLoading: onUpdateLoading,
      onOpen: onOpen,
      onClose: onClose,
      observeKeys: observeKeys);
  final state = useListenableNotifier<bool>(mutation.isLoading, [mutation]);
  useEffect(() {
    return mutation.observe(onUpdateLoading: (bool loading) {
      state.value = loading;
    });
  }, [mutation]);
  return state.value;
}
