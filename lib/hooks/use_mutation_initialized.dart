import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_listenable_notifier.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

bool useMutationInitialized<R>(
    {MutationKey<R>? key,
    String? keyOf,
    MutationInitialValueCallback<R>? initialValue,
    MutationLazyInitialValueCallback<R>? lazyInitialValue,
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
      initialValue: initialValue,
      lazyInitialValue: lazyInitialValue,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitialized: onUpdateInitialized,
      onUpdateLoading: onUpdateLoading,
      onOpen: onOpen,
      onClose: onClose,
      observeKeys: observeKeys);
  final state = useListenableNotifier<bool>(key?.isInitialized ?? false, [mutation]);
  useEffect(() {
    final subscription = mutation.addObserve(onUpdateInitialized: () {
      state.value = true;
    });
    return subscription.cancel;
  }, [mutation]);
  return state.value;
}
