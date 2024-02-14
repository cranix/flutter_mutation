import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_cache_subscription.dart';
import 'package:flutter_mutation/mutation_types.dart';

class MutationKey<R> {
  late Mutation<R> _mutation;

  R? get data => _mutation.data;

  List<R> get dataList => _mutation.dataList;

  Object? get error => _mutation.error;

  bool get isLoading => _mutation.isLoading;

  bool get isInitialized => _mutation.isInitilized;

  static final Map<String, MutationKey> _keyStore = {};


  MutationKey<R> retain(
      {MutationInitialValueCallback<R>? initialValue,
      MutationLazyInitialValueCallback<R>? lazyInitialValue,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []}) {
    _mutation = MutationCache.instance.retain(this,
        initialValue: initialValue,
        lazyInitialValue: lazyInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
    return this;
  }

  static MutationKey<R> of<R>(String value) {
    return _keyStore.putIfAbsent(value, () {
      final key = MutationKey<R>();
      key.observe(onClose: _keyStore.remove);
      return key;
    }) as MutationKey<R>;
  }

  void setMutation(Mutation<R> mutation) {
    _mutation = mutation;
  }

  @override
  String toString() {
    return shortHash(this);
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) {
    return _mutation.mutate(future, append: append);
  }

  Future<bool> updateInitialize(MutationLazyInitialValueCallback<R> callback) {
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

  MutationCacheSubscription<R> observe({
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
