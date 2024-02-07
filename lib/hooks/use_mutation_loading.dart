import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

bool useMutationLoading<R>(
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
  final state = useState<bool>(mutation.isLoading);
  useEffect(() {
    void listener(bool loading) {
      state.value = loading;
    }

    mutation.addOnUpdateLoadingCallback(listener);
    return () {
      mutation.removeOnUpdateLoadingCallback(listener);
    };
  }, [mutation]);
  return state.value;
}
