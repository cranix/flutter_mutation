import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';
import 'package:flutter_mutation/mutation_types.dart';

class MutationKey<R> {
  Mutation<R>? get _mutation => MutationCache.instance.getMutation(this);

  R? get data => _mutation?.data;

  List<R>? get dataList => _mutation?.dataList;

  Object? get error => _mutation?.error;

  bool? get isLoading => _mutation?.isLoading;

  bool? get isInitialized => _mutation?.isInitilized;

  final bool static;

  MutationKey({this.static = true});

  @override
  String toString() {
    return shortHash(this);
  }

  Mutation<R> _getMutationOrNew() {
    return _mutation ?? MutationCache.instance.retain(this);
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) {
    return _getMutationOrNew().mutate(future, append: append);
  }

  Future<bool> updateInitialize(MutationGetInitialValueCallback<R> callback) {
    return _getMutationOrNew().updateInitialize(callback);
  }

  void clear() {
    _mutation?.clear();
  }

  void clearError() {
    _mutation?.clearError();
  }

  void addObserve({
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    MutationCache.instance.addObserve(this,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear,
        onCreate: onCreate,
        onDispose: onDispose);
  }

  bool removeObserve({
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    return MutationCache.instance.removeObserve(this,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear,
        onCreate: onCreate,
        onDispose: onDispose);
  }

  void dispose() {
    MutationCache.instance.dispose(this);
  }
}
