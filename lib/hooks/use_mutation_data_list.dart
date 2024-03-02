import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_listenable_notifier.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

List<R> useMutationDataList<R>(
    {MutationKey<R>? key,
    String? keyOf,
    MutationInitialDataCallback<R>? initialData,
    MutationFetchCallback<R>? lazyInitialData,
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
  final state = useListenableNotifier<List<R>>(mutation.dataList, [mutation]);
  useEffect(() {
    return mutation.observe(onUpdateData: (R? data, {R? before}) {
      state.value = mutation.dataList;
    });
  }, [mutation]);
  return state.value;
}
