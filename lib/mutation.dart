import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mutation/exception/mutation_closed_exception.dart';
import 'package:flutter_mutation/exception/mutation_exception.dart';
import 'package:flutter_mutation/mutation_key.dart';

import 'mutation_types.dart';

class Mutation<R> {
  final MutationKey<R> key;

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

  bool _lazyInitializeStarted = false;

  bool get isAttached => _attachCount > 0;

  final List<MutationOnUpdateDataCallback<R>> _onUpdateDataList = [];
  final List<MutationOnUpdateErrorCallback> _onUpdateErrorList = [];
  final List<MutationOnUpdateInitializedCallback> _onUpdateInitializedList = [];
  final List<MutationOnUpdateLoadingCallback> _onUpdateLoadingList = [];
  final List<MutationOnCloseCallback<R>> _onCloseList = [];

  MutationLazyInitialDataCallback<R>? _lazyInitialData;
  MutationLazyMutateCallback<R>? _lazyMutateCallback;
  MutationLazyMutateCallback<R>? _lazyMutateAppendCallback;
  int _attachCount = 0;

  @override
  String toString() {
    return "${shortHash(this)}\nupdateData:${_onUpdateDataList.length}\nupdateError:${_onUpdateErrorList.length}\nupdateInitialized:${_onUpdateInitializedList.length}\nupdateLoading:${_onUpdateLoadingList.length}\nclose:${_onCloseList.length}";
  }

  Mutation(this.key,
      {MutationInitialDataCallback<R>? initialData,
      MutationLazyInitialDataCallback<R>? lazyInitialData,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnCloseCallback<R>? onClose}) {
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
    if (initialData != null && lazyInitialData != null) {
      throw const MutationException("initialData and lazyInitialData set!");
    }
    if (initialData != null) {
      _updateData(initialData());
      _updateInitialized();
    } else {
      _lazyInitialData = lazyInitialData;
    }
  }

  MutationCancelFunction observe({
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnCloseCallback<R>? onClose,
    bool attach = true,
  }) {
    if (onUpdateInitialized != null) {
      _onUpdateInitializedList.add(onUpdateInitialized);
    }
    if (onUpdateData != null) {
      _onUpdateDataList.add(onUpdateData);
    }
    if (onUpdateError != null) {
      _onUpdateErrorList.add(onUpdateError);
    }
    if (onUpdateLoading != null) {
      _onUpdateLoadingList.add(onUpdateLoading);
    }
    if (onClose != null) {
      _onCloseList.add(onClose);
    }

    if (attach) {
      _attachCount++;
    }

    if (isAttached) {
      if (_lazyMutateCallback != null) {
        final data = _lazyMutateCallback!();
        tryMutate(data);
      } else if (_lazyMutateAppendCallback != null) {
        final data = _lazyMutateAppendCallback!();
        tryMutate(data, append: true);
      } else {
        lazyInitialize();
      }
    }

    return () {
      _removeObserve(
          onUpdateInitialized: onUpdateInitialized,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateLoading: onUpdateLoading,
          onClose: onClose);

      if (attach) {
        _attachCount--;
      }
    };
  }

  void _removeObserve({
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnCloseCallback<R>? onClose,
  }) {
    if (onUpdateInitialized != null) {
      _onUpdateInitializedList.remove(onUpdateInitialized);
    }
    if (onUpdateData != null) {
      _onUpdateDataList.remove(onUpdateData);
    }
    if (onUpdateError != null) {
      _onUpdateErrorList.remove(onUpdateError);
    }
    if (onUpdateLoading != null) {
      _onUpdateLoadingList.remove(onUpdateLoading);
    }
    if (onClose != null) {
      _onCloseList.remove(onClose);
    }
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

  Future<bool> lazyMutate(MutationLazyMutateCallback<R> callback,
      {bool append = false}) async {
    if (_attachCount > 0) {
      final data = callback();
      await tryMutate(data, append: append);
      return true;
    } else {
      if (append) {
        _lazyMutateCallback = null;
        _lazyMutateAppendCallback = callback;
      } else {
        _lazyMutateCallback = callback;
        _lazyMutateAppendCallback = null;
      }
    }
    return false;
  }

  Future<R> mutate(FutureOr<R> future, {bool append = false}) async {
    return (await tryMutate(future, append: append))!;
  }

  Future<R?> tryMutate(FutureOr<R?> future, {bool append = false}) async {
    if (_closed) {
      throw const MutationClosedException();
    }
    try {
      _lazyMutateCallback = null;
      _lazyMutateAppendCallback = null;
      _updateLoading(true);
      final data = await future;
      _updateData(data, append: append);
      _updateInitialized();
      return data;
    } catch (e) {
      _updateError(e);
      rethrow;
    } finally {
      _updateLoading(false);
    }
  }

  Future<bool> updateInitialize(
      MutationLazyInitialDataCallback<R> callback) async {
    if (_closed) {
      throw const MutationClosedException();
    }
    if (_lazyInitializeStarted || _initialized) {
      return false;
    }
    _lazyInitializeStarted = true;
    _lazyInitialData = callback;
    await tryMutate(_lazyInitialData!());
    return true;
  }

  Future<bool> lazyInitialize() async {
    if (_closed) {
      throw const MutationClosedException();
    }
    if (_initialized || _lazyInitializeStarted || _lazyInitialData == null) {
      return false;
    }
    _lazyInitializeStarted = true;
    await tryMutate(_lazyInitialData!());
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
    bool updated = false;
    updated |= _updateData(null);
    updated |= _updateInitialized();
    return updated;
  }

  bool clear() {
    if (_closed) {
      throw const MutationClosedException();
    }
    bool updated = false;
    updated |= _updateData(null);
    updated |= _updateInitialized();
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
