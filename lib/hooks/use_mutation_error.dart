import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_listenable_notifier.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Object? useMutationError<R>(
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
    List<MutationKey<R>> observeKeys = const [],
    bool enable = true}) {
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
  final state = useListenableNotifier<Object?>(mutation.error, [mutation]);
  useEffect(() {
    return mutation.observe(onUpdateError: (Object? error, {Object? before}) {
      state.value = error;
    });
  }, [mutation]);
  return state.value;
}
