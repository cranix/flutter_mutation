import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_types.dart';

class MutationKey<R> {
  Mutation<R>? _mutation;

  R? get data => _mutation?.data;

  List<R> get dataList => _mutation?.dataList ?? [];

  Object? get error => _mutation?.error;

  bool get isLoading => _mutation?.isLoading ?? false;

  bool get isInitialized => _mutation?.isInitilized ?? false;

  static final Map<String, MutationKey> _keyStore = {};

  MutationKey<R> open(
      {MutationInitialDataCallback<R>? initialData,
      MutationMutateCallback<R>? initialMutate,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []}) {
    _mutation = MutationCache.instance.getOrOpen(this,
        initialData: initialData,
        initialMutate: initialMutate,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
    return this;
  }

  MutationKey<R> retain(
      {MutationInitialDataCallback<R>? initialData,
      MutationMutateCallback<R>? initialMutate,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []}) {
    _mutation = MutationCache.instance.retain(this,
        initialData: initialData,
        initialMutate: initialMutate,
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

  Future<bool> forceInitialMutate() {
    return _mutation!.forceInitialMutate();
  }

  Future<bool>? tryForceInitialMutate() {
    return _mutation?.forceInitialMutate();
  }

  Future<bool> mutate(MutationMutateCallback<R> callback,
      {bool append = false}) {
    return _mutation!.mutate(callback, append: append);
  }

  Future<bool>? tryMutate(MutationMutateCallback<R> callback,
      {bool append = false}) {
    return _mutation?.mutate(callback, append: append);
  }

  Future<R> mutateNow(FutureOr<R> future, {bool append = false}) {
    return _mutation!.mutateNow(future, append: append);
  }

  Future<R>? tryMutateNow(FutureOr<R> future, {bool append = false}) {
    return _mutation?.mutateNow(future, append: append);
  }

  Future<bool> updateInitialMutate(MutationMutateCallback<R> callback) {
    return _mutation!.updateInitialMutate(callback);
  }

  Future<bool>? tryUpdateInitialMutate(MutationMutateCallback<R> callback) {
    return _mutation?.updateInitialMutate(callback);
  }

  bool clear() {
    return _mutation?.clear() ?? false;
  }

  bool clearError() {
    return _mutation?.clearError() ?? false;
  }

  bool clearData() {
    return _mutation?.clearData() ?? false;
  }

  bool close() {
    return MutationCache.instance.close(this);
  }

  bool release() {
    return MutationCache.instance.release(this);
  }

  MutationCancelFunction observe(
      {MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      bool initialCall = false}) {
    return MutationCache.instance.addObserve(this,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        initialCall: initialCall);
  }
}
