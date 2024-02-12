import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

import 'mutation_types.dart';

class MutationSubscription<R> {
  MutationKey<R> key;
  MutationOnUpdateInitializedCallback? onUpdateInitialized;
  MutationOnUpdateDataCallback<R>? onUpdateData;
  MutationOnUpdateErrorCallback? onUpdateError;
  MutationOnUpdateLoadingCallback? onUpdateLoading;
  MutationOnCloseCallback<R>? onClose;

  MutationSubscription(
    this.key, {
    this.onUpdateData,
    this.onUpdateError,
    this.onUpdateInitialized,
    this.onUpdateLoading,
    this.onClose,
  });

  void cancel() {
    final mutation = MutationCache.instance.getMutation(key);
    if (mutation == null) {
      return;
    }
    mutation.removeObserve(
        onUpdateInitialized: onUpdateInitialized,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateLoading: onUpdateLoading,
        onClose: onClose);
  }
}
