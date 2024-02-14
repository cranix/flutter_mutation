import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

Object? useMutationError<R>(
    {MutationKey<R>? key,
    MutationInitialValueCallback<R>? initialValue,
    MutationLazyInitialValueCallback<R>? lazyInitialValue,
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
      initialValue: initialValue,
      lazyInitialValue: lazyInitialValue,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitialized: onUpdateInitialized,
      onUpdateLoading: onUpdateLoading,
      onOpen: onOpen,
      onClose: onClose,
      observeKeys: observeKeys);
  final state = useState<Object?>(mutation.error);
  useEffect(() {
    final subscription =
        mutation.addObserve(onUpdateError: (Object? error, {Object? before}) {
      state.value = error;
    });
    return subscription.cancel;
  }, [mutation]);
  return state.value;
}
