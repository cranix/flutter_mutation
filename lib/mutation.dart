import 'dart:async';

import 'package:flutter_mutation/exception/mutation_closed_exception.dart';
import 'package:flutter_mutation/mutation_key.dart';

import 'mutation_types.dart';

class Mutation<R> {
  final MutationKey<R> key;
  final bool autoInitialize;

  Object? _error;

  Object? get error => _error;

  bool get hasError => error != null;

  List<R> _dataList = [];

  List<R> get dataList => List.of(_dataList, growable: false);

  R? get data => _dataList.isEmpty ? null : _dataList.last;

  bool get hasData => data != null;

  bool get isEmpty => data == null;

  bool _loading = false;

  bool get isLoading => _loading;

  bool _initialized = false;

  bool get isInitilized => _initialized;

  bool _closed = false;

  bool get isClosed => _closed;

  bool _initializeStarted = false;

  final List<MutationOnUpdateDataCallback<R>> _onUpdateDataList = [];
  final List<MutationOnUpdateErrorCallback> _onUpdateErrorList = [];
  final List<MutationOnUpdateInitializedCallback> _onUpdateInitializedList = [];
  final List<MutationOnUpdateLoadingCallback> _onUpdateLoadingList = [];
  final List<MutationOnCloseCallback<R>> _onCloseList = [];

  MutationGetInitialValueCallback<R>? _getInitialValue;

  Mutation(this.key,
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnCloseCallback<R>? onClose,
      this.autoInitialize = true,
      bool enableInitialize = true}) {
    if (onUpdateData != null) {
      _onUpdateDataList.add(onUpdateData);
    }
    if (onUpdateError != null) {
      _onUpdateErrorList.add(onUpdateError);
    }
    if (onUpdateInitialized != null) {
      _onUpdateInitializedList.add(onUpdateInitialized);
    }
    if (onUpdateLoading != null) {
      _onUpdateLoadingList.add(onUpdateLoading);
    }
    if (onClose != null) {
      _onCloseList.add(onClose);
    }
    if (initialValue != null) {
      _setData(initialValue);
    }
    _getInitialValue = getInitialValue;
  }

  Mutation<R> addOnCloseCallback(MutationOnCloseCallback<R> callback) {
    _onCloseList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnCloseCallback(MutationOnCloseCallback<R> callback) {
    _onCloseList.remove(callback);
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

  Mutation<R> addOnUpdateInitializedCallback(
      MutationOnUpdateInitializedCallback callback) {
    _onUpdateInitializedList.add(callback);
    if (autoInitialize) {
      initialize();
    }
    return this;
  }

  Mutation<R> removeOnUpdateInitializedCallback(
      MutationOnUpdateInitializedCallback callback) {
    _onUpdateInitializedList.remove(callback);
    return this;
  }

  void _setData(R? data, {bool append = false}) {
    if (data != null) {
      if (append) {
        _dataList += [data];
      } else {
        _dataList = [data];
      }
    } else {
      _dataList = [];
    }
  }

  bool _updateData(R? data, {bool append = false}) {
    if (!append && data == this.data) {
      return false;
    }
    R? before = this.data;
    _setData(data, append: append);
    for (var element in _onUpdateDataList) {
      element(data, before: before);
    }
    return true;
  }

  bool _updateInitialized() {
    if (_initialized) {
      return false;
    }
    _initialized = true;
    for (var element in _onUpdateInitializedList) {
      element();
    }
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
    return true;
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) async {
    if (_closed) {
      throw const MutationClosedException();
    }
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
      _updateInitialized();
    }
  }

  Future<bool> updateInitialize(
      MutationGetInitialValueCallback<R> callback) async {
    if (_closed) {
      throw const MutationClosedException();
    }
    if (_initializeStarted || _initialized) {
      return false;
    }
    _initializeStarted = true;
    _getInitialValue = callback;
    await mutate(_getInitialValue!());
    return true;
  }

  Future<bool> initialize() async {
    if (_closed) {
      throw const MutationClosedException();
    }
    if (_initializeStarted || _initialized || _getInitialValue == null) {
      return false;
    }
    _initializeStarted = true;
    await mutate(_getInitialValue!());
    return true;
  }

  bool clearError() {
    if (_closed) {
      throw const MutationClosedException();
    }
    return _updateError(null);
  }

  bool clearData() {
    if (_closed) {
      throw const MutationClosedException();
    }
    return _updateData(null);
  }

  bool clear() {
    if (_closed) {
      throw const MutationClosedException();
    }
    bool updated = false;
    updated |= _updateData(null);
    updated |= _updateError(null);
    return updated;
  }

  // immutable data
  void close() {
    if (_closed) {
      throw const MutationClosedException();
    }
    _closed = true;
    for (var element in _onCloseList) {
      element(this);
    }
  }
}
