library flutter_mutation;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef MutationOnDisposeCallback<R> = void Function(Mutation<R> mutation);
typedef MutationOnCreateCallback<R> = void Function()? Function(
    Mutation<R> mutation);
typedef MutationOnUpdateDataCallback<R> = void Function(R? data, {R? before});
typedef MutationOnUpdateErrorCallback = void Function(Object? error,
    {Object? before});
typedef MutationOnUpdateLoadingCallback = void Function(bool loading);
typedef MutationOnUpdateInitializingCallback = void Function(bool initializing);
typedef MutationOnClearCallback = void Function();
typedef MutationGetInitialValueCallback<R> = FutureOr<R?> Function();

class Mutation<R> extends ChangeNotifier {
  Object? _error;
  bool _loading = false;

  final bool autoInitialize;

  List<R> _dataList = [];

  Object? get error => _error;

  R? get data => _dataList.isEmpty ? null : _dataList.last;

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

  Mutation(
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateInitializingCallback? onUpdateInitializing,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnClearCallback? onClear,
      MutationOnCreateCallback<R>? onCreate,
      MutationOnDisposeCallback<R>? onDispose,
      this.autoInitialize = true}) {
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

  initialize() {
    if (_initialized) {
      return false;
    }
    _initialized = true;
    _runInitializeFuture();
    return true;
  }

  _runInitializeFuture() async {
    if (_getInitialValue == null) {
      return;
    }
    try {
      for (var element in _onUpdateInitializingList) {
        element(true);
      }
      _updateLoading(true);
      R? value = await _getInitialValue!();
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
    _dataList = [];
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


extension MutationsFutureOrExtension<R> on FutureOr<R> {
  FutureOr<R> mutate(Mutation<R> mutation, {bool append = false}) {
    return mutation.mutate(this, append: append);
  }
}

class MutationException implements Exception {
  final String message;

  const MutationException(this.message);

  @override
  String toString() {
    return "MutationException($message)";
  }
}

Object? useMutationError<R>(Mutation<R> mutation) {
  final state = useState<Object?>(mutation.error);
  useEffect(() {
    void listener(Object? error, {Object? before}) {
      state.value = error;
    }

    mutation.addOnUpdateErrorCallback(listener);
    return () {
      mutation.removeOnUpdateErrorCallback(listener);
    };
  }, [mutation]);
  return state.value;
}

List<R> useMutationDataList<R>(Mutation<R> mutation) {
  final state = useState<List<R>>(mutation._dataList);
  useEffect(() {
    void listener(R? data, {R? before}) {
      state.value = mutation._dataList;
    }

    mutation.addOnUpdateDataCallback(listener);
    return () {
      mutation.removeOnUpdateDataCallback(listener);
    };
  }, [mutation]);
  return state.value;
}

R? useMutationData<R>(Mutation<R> mutation) {
  final state = useState<R?>(mutation.data);
  useEffect(() {
    void listener(R? data, {R? before}) {
      state.value = data;
    }

    mutation.addOnUpdateDataCallback(listener);
    return () {
      mutation.removeOnUpdateDataCallback(listener);
    };
  }, [mutation]);
  return state.value;
}

bool useMutationLoading<R>(Mutation<R> mutation) {
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

enum EventKey { DATA, ERROR, INITIALIZING, LOADING, CLEAR, CREATE, DISPOSE }

class MutationCache {
  static final instance = MutationCache._();
  final _data = <String, Mutation>{};
  final _retainCount = <String, int>{};
  final _staticKeys = <String>{};

  final _onEventMapListMap = <EventKey, Map<String, List>>{};

  MutationCache._();

  List _getOrNewMapList(EventKey event, String key) {
    var map = _onEventMapListMap[event];
    if (map == null) {
      map = <String, List>{};
      _onEventMapListMap[event] = map;
    }
    var list = map[key];
    if (list == null) {
      list = [];
      map[key] = list;
    }
    return list;
  }

  bool _removeMapList(EventKey event, String key, dynamic value) {
    final map = _onEventMapListMap[event];
    if (map == null) {
      return false;
    }
    final list = map[key];
    if (list == null) {
      return false;
    }
    final res = list.remove(value);
    if (list.isEmpty) {
      map.remove(event);
    }
    return res;
  }

  void addObserve<R>(
    String key, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    if (onUpdateData != null) {
      final list = _getOrNewMapList(EventKey.DATA, key);
      list.add(onUpdateData);
    }
    if (onUpdateError != null) {
      final list = _getOrNewMapList(EventKey.ERROR, key);
      list.add(onUpdateError);
    }
    if (onUpdateInitializing != null) {
      final list = _getOrNewMapList(EventKey.INITIALIZING, key);
      list.add(onUpdateInitializing);
    }
    if (onUpdateLoading != null) {
      final list = _getOrNewMapList(EventKey.LOADING, key);
      list.add(onUpdateLoading);
    }
    if (onClear != null) {
      final list = _getOrNewMapList(EventKey.CLEAR, key);
      list.add(onClear);
    }
    if (onCreate != null) {
      final list = _getOrNewMapList(EventKey.CREATE, key);
      list.add(onCreate);
    }
    if (onDispose != null) {
      final list = _getOrNewMapList(EventKey.DISPOSE, key);
      list.add(onDispose);
    }
  }

  bool removeObserve<R>(
    String key, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    if (onUpdateData != null) {
      return _removeMapList(EventKey.DATA, key, onUpdateData);
    }
    if (onUpdateError != null) {
      return _removeMapList(EventKey.ERROR, key, onUpdateData);
    }
    if (onUpdateInitializing != null) {
      return _removeMapList(EventKey.INITIALIZING, key, onUpdateData);
    }
    if (onUpdateLoading != null) {
      return _removeMapList(EventKey.LOADING, key, onUpdateData);
    }
    if (onClear != null) {
      return _removeMapList(EventKey.CLEAR, key, onUpdateData);
    }
    if (onCreate != null) {
      return _removeMapList(EventKey.CREATE, key, onUpdateData);
    }
    if (onDispose != null) {
      return _removeMapList(EventKey.DISPOSE, key, onUpdateData);
    }
    return false;
  }

  _onUpdateData(String retainKey, dynamic data) {
    _onEventMapListMap[EventKey.DATA]?[retainKey]?.forEach((e) => e(data));
  }

  _onUpdateError(String retainKey, Object? error) {
    _onEventMapListMap[EventKey.ERROR]?[retainKey]?.forEach((e) => e(error));
  }

  _onUpdateInitializing(String retainKey, bool initializing) {
    _onEventMapListMap[EventKey.INITIALIZING]?[retainKey]
        ?.forEach((e) => e(initializing));
  }

  _onUpdateLoading(String retainKey, bool loading) {
    _onEventMapListMap[EventKey.LOADING]?[retainKey]
        ?.forEach((e) => e(loading));
  }

  _onClear(String retainKey) {
    _onEventMapListMap[EventKey.CLEAR]?[retainKey]?.forEach((e) => e());
  }

  _onDispose(String retainKey, Mutation mutation) {
    _onEventMapListMap[EventKey.DISPOSE]?[retainKey]
        ?.forEach((e) => e(mutation));
  }

  Mutation<R> retain<R>(String retainKey,
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializingCallback? onUpdateInitializing,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnClearCallback? onClear,
      MutationOnCreateCallback<R>? onCreate,
      MutationOnDisposeCallback<R>? onDispose,
      bool isStatic = false,
      List<String> observeKeys = const [],
      bool autoInitialize = true}) {
    var mutation = _data[retainKey] as Mutation<R>?;
    if (mutation == null) {
      mutation = Mutation<R>(
          initialValue: initialValue,
          getInitialValue: getInitialValue,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitializing: onUpdateInitializing,
          onUpdateLoading: onUpdateLoading,
          onClear: onClear,
          onCreate: onCreate,
          onDispose: onDispose,
          autoInitialize: autoInitialize);
      _onEventMapListMap[EventKey.CREATE]?[retainKey]
          ?.forEach((e) => e(mutation));
      for (var key in observeKeys) {
        _onEventMapListMap[EventKey.CREATE]?[key]?.forEach((e) => e(mutation));
      }
      mutation.addOnUpdateDataCallback((data, {before}) {
        _onUpdateData(retainKey, data);
        for (var key in observeKeys) {
          _onUpdateData(key, data);
        }
      });
      mutation.addOnUpdateErrorCallback((error, {before}) {
        _onUpdateError(retainKey, error);
        for (var key in observeKeys) {
          _onUpdateError(key, error);
        }
      });
      mutation.addOnUpdateInitializingCallback((initializing) {
        _onUpdateInitializing(retainKey, initializing);
        for (var key in observeKeys) {
          _onUpdateInitializing(key, initializing);
        }
      });
      mutation.addOnUpdateLoadingCallback((loading) {
        _onUpdateLoading(retainKey, loading);
        for (var key in observeKeys) {
          _onUpdateLoading(key, loading);
        }
      });
      mutation.addOnClearCallback(() {
        _onClear(retainKey);
        for (var key in observeKeys) {
          _onClear(key);
        }
      });
      mutation.addOnDisposeCallback((mutation) {
        _onDispose(retainKey, mutation);
        for (var key in observeKeys) {
          _onDispose(key, mutation);
        }
      });
      _data[retainKey] = mutation;
    }
    if (isStatic) {
      _staticKeys.add(retainKey);
    } else {
      _retainCount[retainKey] = (_retainCount[retainKey] ?? 0) + 1;
    }
    return mutation;
  }

  bool release(String retainKey) {
    if (_staticKeys.contains(retainKey)) {
      return false;
    }
    int? count = _retainCount[retainKey];
    if (count == null) {
      return false;
    }
    if (count > 1) {
      _retainCount[retainKey] = count - 1;
      return false;
    }
    _retainCount.remove(retainKey);
    final mutation = _data.remove(retainKey);
    mutation?.dispose();
    return true;
  }
}

Mutation<R> useMutation<R>(
    {R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
    String? retainKey,
    bool isStatic = false,
    List<String> observeKeys = const [],
    bool enable = true}) {
  if (isStatic && retainKey == null) {
    throw const MutationException("static must have retainKey");
  }
  String key = useMemoized(() => retainKey ?? UniqueKey().toString());
  final mutation = useMemoized(() {
    return MutationCache.instance.retain<R>(key,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitializing: onUpdateInitializing,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear,
        onCreate: onCreate,
        onDispose: onDispose,
        isStatic: isStatic,
        observeKeys: observeKeys,
        autoInitialize: enable);
  }, [key]);

  useEffect(() {
    if (!enable) {
      return;
    }
    mutation.initialize();
  }, [enable, mutation]);

  useEffect(() {
    return () {
      MutationCache.instance.release(key);
    };
  }, [mutation]);
  return mutation;
}
