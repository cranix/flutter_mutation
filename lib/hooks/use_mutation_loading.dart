import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/hooks/use_mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

bool useMutationLoading<R>(
    {MutationKey<R>? key,
    R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
    List<MutationKey<R>> observeKeys = const []}) {
  final mutation = useMutation(
      key: key,
      initialValue: initialValue,
      getInitialValue: getInitialValue,
      onUpdateData: onUpdateData,
      onUpdateError: onUpdateError,
      onUpdateInitialized: onUpdateInitialized,
      onUpdateLoading: onUpdateLoading,
      onOpen: onOpen,
      onClose: onClose,
      observeKeys: observeKeys);
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
