import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_key.dart';

import 'mutation_types.dart';

class MutationSubscription<R> {
  MutationKey<R> key;
  MutationOnUpdateDataCallback<R>? onUpdateData;
  MutationOnUpdateErrorCallback? onUpdateError;
  MutationOnUpdateInitializedCallback? onUpdateInitialized;
  MutationOnUpdateLoadingCallback? onUpdateLoading;
  MutationOnOpenCallback<R>? onOpen;
  MutationOnCloseCallback<R>? onClose;

  MutationSubscription(
    this.key, {
    this.onUpdateData,
    this.onUpdateError,
    this.onUpdateInitialized,
    this.onUpdateLoading,
    this.onOpen,
    this.onClose,
  });

  cancel() {
    MutationCache.instance.removeObserve(key,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose);
  }
}
