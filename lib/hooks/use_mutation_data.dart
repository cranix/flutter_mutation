import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

R? useMutationData<R>(
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
  final state = useState<R?>(mutation.data);
  useEffect(() {
    void listener(R? data, {R? before}) {
      state.value = data;
    }

    mutation.addOnUpdateDataCallback(listener);
    return () {
      mutation.removeOnUpdateDataCallback(listener);
    };
  }, [mutation]);
  return state.value;
}
