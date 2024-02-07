import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_mutation/mutation_exception.dart';
import 'package:flutter_mutation/mutation_key.dart';

import 'mutation_types.dart';

class Mutation<R> extends ChangeNotifier {
  final MutationKey<R> key;
  final bool autoInitialize;

  Object? _error;

  bool _loading = false;

  List<R> dataList = [];

  Object? get error => _error;

  R? get data => dataList.isEmpty ? null : dataList.last;

  bool get isLoading => _loading;

  bool get hasData => data != null;

  bool get hasError => error != null;

  bool get isEmpty => data == null;

  bool get isInitializing => _loading && !_initialized;

  bool get isInitilized => _initialized;

  bool _disposed = false;

  bool get isDisposed => _disposed;

  bool _initialized = false;

  final List<MutationOnUpdateDataCallback<R>> _onUpdateDataList = [];
  final List<MutationOnUpdateErrorCallback> _onUpdateErrorList = [];
  final List<MutationOnUpdateInitializingCallback> _onUpdateInitializingList =
      [];
  final List<MutationOnUpdateLoadingCallback> _onUpdateLoadingList = [];
  final List<MutationOnClearCallback> _onClearList = [];

  final List<MutationOnDisposeCallback<R>> _onDisposeList = [];

  MutationGetInitialValueCallback<R>? _getInitialValue;

  Mutation(this.key,
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateInitializingCallback? onUpdateInitializing,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnClearCallback? onClear,
      MutationOnCreateCallback<R>? onCreate,
      MutationOnDisposeCallback<R>? onDispose,
      this.autoInitialize = true,
      bool enableInitialize = true}) {
    if (onUpdateData != null) {
      _onUpdateDataList.add(onUpdateData);
    }
    if (onUpdateError != null) {
      _onUpdateErrorList.add(onUpdateError);
    }
    if (onUpdateInitializing != null) {
      _onUpdateInitializingList.add(onUpdateInitializing);
    }
    if (onUpdateLoading != null) {
      _onUpdateLoadingList.add(onUpdateLoading);
    }
    if (onClear != null) {
      _onClearList.add(onClear);
    }
    if (onDispose != null) {
      _onDisposeList.add(onDispose);
    }
    if (initialValue != null) {
      _setData(initialValue);
    }
    _getInitialValue = getInitialValue;

    if (onCreate != null) {
      final res = onCreate(this);
      if (res != null) {
        _onDisposeList.add((mutation) {
          res();
        });
      }
    }
  }

  updateInitialize(MutationGetInitialValueCallback<R> callback) {
    _getInitialValue = callback;
    initialize();
  }

  initialize() {
    if (_initialized || _getInitialValue == null) {
      return false;
    }
    _initialized = true;
    _runInitializeFuture(_getInitialValue);
    return true;
  }

  _runInitializeFuture(MutationGetInitialValueCallback<R>? callback) async {
    if (callback == null) {
      return;
    }
    try {
      for (var element in _onUpdateInitializingList) {
        element(true);
      }
      _updateLoading(true);
      R? value = await callback();
      if (value == null) {
        return;
      }
      _updateData(value);
    } catch (e) {
      _updateError(e);
      rethrow;
    } finally {
      _updateLoading(false);
      for (var element in _onUpdateInitializingList) {
        element(false);
      }
    }
  }

  Mutation<R> addOnDisposeCallback(MutationOnDisposeCallback<R> callback) {
    _onDisposeList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnDisposeCallback(MutationOnDisposeCallback<R> callback) {
    _onDisposeList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateDataCallback(
      MutationOnUpdateDataCallback<R> callback) {
    _onUpdateDataList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnUpdateDataCallback(
      MutationOnUpdateDataCallback<R> callback) {
    _onUpdateDataList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateErrorCallback(MutationOnUpdateErrorCallback callback) {
    _onUpdateErrorList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnUpdateErrorCallback(
      MutationOnUpdateErrorCallback callback) {
    _onUpdateErrorList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateLoadingCallback(
      MutationOnUpdateLoadingCallback callback) {
    _onUpdateLoadingList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnUpdateLoadingCallback(
      MutationOnUpdateLoadingCallback callback) {
    _onUpdateLoadingList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateInitializingCallback(
      MutationOnUpdateInitializingCallback callback) {
    _onUpdateInitializingList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnUpdateInitializingCallback(
      MutationOnUpdateInitializingCallback callback) {
    _onUpdateInitializingList.remove(callback);
    return this;
  }

  Mutation<R> addOnClearCallback(MutationOnClearCallback callback) {
    _onClearList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnClearCallback(MutationOnClearCallback callback) {
    _onClearList.remove(callback);
    return this;
  }

  void _setData(R? data, {bool append = false}) {
    if (data != null) {
      if (append) {
        dataList += [data];
      } else {
        dataList = [data];
      }
    } else {
      dataList = [];
    }
  }

  bool _updateData(R? data, {bool append = false}) {
    if (!append && data == this.data) {
      return false;
    }

    _initialized = true;
    R? before = this.data;
    _setData(data, append: append);
    for (var element in _onUpdateDataList) {
      element(data, before: before);
    }
    notifyListeners();
    return true;
  }

  bool _updateLoading(bool loading) {
    if (_loading == loading) {
      return false;
    }
    _loading = loading;
    for (var element in _onUpdateLoadingList) {
      element(loading);
    }
    notifyListeners();
    return true;
  }

  bool _updateError(Object? error) {
    if (_error == error) {
      return false;
    }
    Object? before = _error;
    _error = error;
    for (var element in _onUpdateErrorList) {
      element(error, before: before);
    }
    notifyListeners();
    return true;
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) async {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    _initialized = true;
    try {
      _updateLoading(true);
      final data = await future;
      _updateData(data, append: append);
      return data;
    } catch (e) {
      _updateError(e);
      rethrow;
    } finally {
      _updateLoading(false);
    }
  }

  void update(R? data, {bool append = false}) {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    _updateData(data, append: append);
  }

  void clearError() {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    _updateError(null);
  }

  bool _updateClear() {
    if (!hasData && !hasError && !isLoading) {
      return false;
    }
    _updateData(null);
    _updateError(null);
    for (var element in _onClearList) {
      element();
    }
    return true;
  }

  void clear() {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    _updateClear();
  }

  @override
  void dispose() {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    for (var element in _onDisposeList) {
      element(this);
    }
    dataList = [];
    _error = null;
    _loading = false;
    _onUpdateDataList.clear();
    _onUpdateErrorList.clear();
    _onUpdateLoadingList.clear();
    _onClearList.clear();
    _onDisposeList.clear();
    _disposed = true;
    _initialized = false;
    _getInitialValue = null;
    super.dispose();
  }
}
