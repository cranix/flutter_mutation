import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

List<R> useMutationDataList<R>(
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
    List<MutationKey<R>> observeKeys = const [],
    bool enable = true}) {
  final mutation = useMutation(
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
      observeKeys: observeKeys,
      key: key);
  final state = useState<List<R>>(mutation.dataList);
  useEffect(() {
    void listener(R? data, {R? before}) {
      state.value = mutation.dataList;
    }

    mutation.addOnUpdateDataCallback(listener);
    return () {
      mutation.removeOnUpdateDataCallback(listener);
    };
  }, [mutation]);
  return state.value;
}
