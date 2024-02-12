import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_subscription.dart';
import 'package:flutter_mutation/mutation_types.dart';

class MutationKey<R> {
  late Mutation<R> _mutation;

  R? get data => _mutation.data;

  List<R> get dataList => _mutation.dataList;

  Object? get error => _mutation.error;

  bool get isLoading => _mutation.isLoading;

  bool get isInitialized => _mutation.isInitilized;

  final bool static;

  // static mode is retain now
  MutationKey(
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []})
      : static = true {
    _mutation = MutationCache.instance.retain(this,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
  }

  // autoClose mode is retain outside
  MutationKey.autoClose() : static = false;

  setMutation(Mutation<R> mutation) {
    _mutation = mutation;
  }

  @override
  String toString() {
    return shortHash(this);
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) {
    return _mutation.mutate(future, append: append);
  }

  Future<bool> updateInitialize(MutationGetInitialValueCallback<R> callback) {
    return _mutation.updateInitialize(callback);
  }

  bool? clear() {
    return _mutation.clear();
  }

  bool? clearError() {
    return _mutation.clearError();
  }

  bool? clearData() {
    return _mutation.clearData();
  }

  void close() {
    _mutation.close();
    MutationCache.instance.remove(this);
  }

  MutationSubscription<R> observe({
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
  }) {
    return MutationCache.instance.addObserve(this,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose);
  }
}
