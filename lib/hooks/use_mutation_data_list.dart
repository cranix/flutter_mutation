import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

List<R> useMutationDataList<R>(
    {MutationKey<R>? key,
    R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
    List<MutationKey<R>> observeKeys = const [],
    bool enable = true}) {
  final mutation = useMutation(
      key: key,
      initialValue: initialValue,
      getInitialValue: getInitialValue,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitializing: onUpdateInitializing,
      onUpdateLoading: onUpdateLoading,
      onClear: onClear,
      onCreate: onCreate,
      onDispose: onDispose,
      observeKeys: observeKeys);
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
