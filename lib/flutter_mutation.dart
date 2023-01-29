library flutter_mutation;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef MutationOnDisposeCallback<R> = void Function(Mutation<R> mutation);
typedef MutationOnCreateCallback<R> = void Function()? Function(Mutation<R> mutation);
typedef MutationOnUpdateDataCallback<R> = void Function(R? data);
typedef MutationOnUpdateErrorCallback = void Function(Object error);
typedef MutationOnUpdateLoadingCallback = void Function(bool loading);
typedef MutationOnUpdateInitializingCallback = void Function(bool initializing);
typedef MutationOnClearCallback = void Function();
typedef MutationGetInitialValueCallback<R> = Future<R?> Function();

class Mutation<R> extends ChangeNotifier {
  Object? _error;
  bool _loading = false;

  List<R> dataList = [];

  Object? get error => _error;

  R? get data => dataList.isEmpty ? null : dataList.last;

  bool get isLoading => _loading;

  bool get hasData => data != null;

  bool get isEmpty => data == null;

  bool get isInitializing => _loading && isEmpty;

  bool _disposed = false;

  bool get isDisposed => _disposed;

  final List<MutationOnUpdateDataCallback<R>> _onUpdateDataList = [];
  final List<MutationOnUpdateErrorCallback> _onUpdateErrorList = [];
  final List<MutationOnUpdateInitializingCallback> _onUpdateInitializingList =
      [];
  final List<MutationOnUpdateLoadingCallback> _onUpdateLoadingList = [];
  final List<MutationOnClearCallback> _onClearList = [];

  final List<MutationOnDisposeCallback<R>> _onDisposeList = [];

  Mutation(
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateInitializingCallback? onUpdateInitializing,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnClearCallback? onClear,
      MutationOnCreateCallback<R>? onCreate,
      MutationOnDisposeCallback<R>? onDispose}) {
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
    if (getInitialValue != null) {
      _initMutate(getInitialValue());
    }
    if (onCreate != null) {
      final res = onCreate(this);
      if (res != null) {
        _onDisposeList.add((mutation) {
           res();
        });
      }
    }
  }

  Mutation<R> addOnDisposeCallback(MutationOnDisposeCallback<R> callback) {
    _onDisposeList.add(callback);
    return this;
  }

  Mutation<R> removeOnDisposeCallback(MutationOnDisposeCallback<R> callback) {
    _onDisposeList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateDataCallback(
      MutationOnUpdateDataCallback<R> callback) {
    _onUpdateDataList.add(callback);
    return this;
  }

  Mutation<R> removeOnUpdateDataCallback(
      MutationOnUpdateDataCallback<R> callback) {
    _onUpdateDataList.remove(callback);
    return this;
  }

  Mutation<R> addOnUpdateErrorCallback(MutationOnUpdateErrorCallback callback) {
    _onUpdateErrorList.add(callback);
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
    return this;
  }

  Mutation<R> removeOnUpdateInitializingCallback(
      MutationOnUpdateInitializingCallback callback) {
    _onUpdateInitializingList.remove(callback);
    return this;
  }

  Mutation<R> addOnClearCallback(MutationOnClearCallback callback) {
    _onClearList.add(callback);
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
      if (!append) {
        dataList = [];
      }
    }
  }

  void _updateData(R? data, {bool append = false}) {
    if (!append && data == this.data) {
      return;
    }
    bool beforeInitializing = isInitializing;
    _setData(data, append: append);
    for (var element in _onUpdateDataList) {
      element(data);
    }
    if (beforeInitializing != isInitializing) {
      for (var element in _onUpdateInitializingList) {
        element(isInitializing);
      }
    }
    notifyListeners();
  }

  void _updateLoading(bool loading) {
    if (_loading == loading) {
      return;
    }
    bool beforeInitializing = isInitializing;
    _loading = loading;
    for (var element in _onUpdateLoadingList) {
      element(loading);
    }
    if (beforeInitializing != isInitializing) {
      for (var element in _onUpdateInitializingList) {
        element(isInitializing);
      }
    }
    notifyListeners();
  }

  void _updateError(Object error) {
    _error = error;
    for (var element in _onUpdateErrorList) {
      element(error);
    }
    notifyListeners();
  }

  _initMutate(Future<R?> future) async {
    try {
      _updateLoading(true);
      R? value = await future;
      if (value == null) {
        return;
      }
      _updateData(value);
    } catch (e) {
      _updateError(e);
      rethrow;
    } finally {
      _updateLoading(false);
    }
  }

  Future<R> _mutate(Future<R> future, {bool append = false}) async {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    try {
      _updateLoading(true);
      final data = await future;
      update(data, append: append);
      return data;
    } catch (e) {
      _updateError(e);
      rethrow;
    } finally {
      _updateLoading(false);
    }
  }

  void update(R data, {bool append = false}) {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    _updateData(data, append: append);
  }

  void clear() {
    if (_disposed) {
      throw const MutationException("mutation disposed");
    }
    bool beforeInitializing = isInitializing;
    dataList = [];
    _error = null;
    for (var element in _onClearList) {
      element();
    }
    for (var element in _onUpdateDataList) {
      element(data);
    }
    if (beforeInitializing != isInitializing) {
      for (var element in _onUpdateInitializingList) {
        element(isInitializing);
      }
    }
    notifyListeners();
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
    super.dispose();
  }
}

extension MutationsExtension<R> on Future<R> {
  Future<R> mutate(Mutation<R> mutation, {bool append = false}) {
    return mutation._mutate(this, append: append);
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
    void listener(Object error) {
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
  final state = useState<List<R>>(mutation.dataList);
  useEffect(() {
    void listener(R? data) {
      state.value = mutation.dataList;
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
    void listener(R? data) {
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

List _getOrNewMapList(Map<String, List> map, String key) {
  var list = map[key];
  if (list == null) {
    list = [];
    map[key] = list;
  }
  return list;
}

bool _removeMapList(Map<String, List> map, String key, dynamic value) {
  final list = map[key];
  if (list == null) {
    return false;
  }
  return list.remove(value);
}

class MutationCache {
  static final instance = MutationCache._();
  final _data = <String, Mutation>{};
  final _retainCount = <String, int>{};
  final _staticKeys = <String>{};

  final _onUpdateDataListMap = <String, List>{};
  final _onUpdateErrorListMap = <String, List>{};
  final _onUpdateInitializingListMap = <String, List>{};
  final _onUpdateLoadingListMap = <String, List>{};
  final _onClearListMap = <String, List>{};
  final _onCreateListMap = <String, List>{};
  final _onDisposeListMap = <String, List>{};

  MutationCache._();

  void addObserve<R>(
    String retainKey, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    if (onUpdateData != null) {
      final list = _getOrNewMapList(_onUpdateDataListMap, retainKey);
      list.add(onUpdateData);
    }
    if (onUpdateError != null) {
      final list = _getOrNewMapList(_onUpdateErrorListMap, retainKey);
      list.add(onUpdateError);
    }
    if (onUpdateInitializing != null) {
      final list = _getOrNewMapList(_onUpdateInitializingListMap, retainKey);
      list.add(onUpdateInitializing);
    }
    if (onUpdateLoading != null) {
      final list = _getOrNewMapList(_onUpdateLoadingListMap, retainKey);
      list.add(onUpdateLoading);
    }
    if (onClear != null) {
      final list = _getOrNewMapList(_onClearListMap, retainKey);
      list.add(onClear);
    }
    if (onCreate != null) {
      final list = _getOrNewMapList(_onCreateListMap, retainKey);
      list.add(onCreate);
    }
    if (onDispose != null) {
      final list = _getOrNewMapList(_onDisposeListMap, retainKey);
      list.add(onDispose);
    }
  }

  bool removeObserve<R>(
    String retainKey, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
  }) {
    if (onUpdateData != null) {
      return _removeMapList(_onUpdateDataListMap, retainKey, onUpdateData);
    }
    if (onUpdateError != null) {
      return _removeMapList(_onUpdateErrorListMap, retainKey, onUpdateData);
    }
    if (onUpdateInitializing != null) {
      return _removeMapList(_onUpdateInitializingListMap, retainKey, onUpdateData);
    }
    if (onUpdateLoading != null) {
      return _removeMapList(_onUpdateLoadingListMap, retainKey, onUpdateData);
    }
    if (onClear != null) {
      return _removeMapList(_onClearListMap, retainKey, onUpdateData);
    }
    if (onCreate != null) {
      return _removeMapList(_onCreateListMap, retainKey, onUpdateData);
    }
    if (onDispose != null) {
      return _removeMapList(_onDisposeListMap, retainKey, onUpdateData);
    }
    return false;
  }

  Mutation<R> retain<R>(
    String retainKey, {
    R? initialValue,
    MutationGetInitialValueCallback<R>? getInitialValue,
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializingCallback? onUpdateInitializing,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnClearCallback? onClear,
    MutationOnCreateCallback<R>? onCreate,
    MutationOnDisposeCallback<R>? onDispose,
    bool isStatic = false,
  }) {
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
          onDispose: onDispose);
      _onCreateListMap[retainKey]?.forEach((e) => e(mutation!));
      _onUpdateDataListMap[retainKey]
          ?.forEach((e) => mutation!.addOnUpdateDataCallback(e));
      _onUpdateErrorListMap[retainKey]
          ?.forEach((e) => mutation!.addOnUpdateErrorCallback(e));
      _onUpdateInitializingListMap[retainKey]
          ?.forEach((e) => mutation!.addOnUpdateInitializingCallback(e));
      _onUpdateLoadingListMap[retainKey]
          ?.forEach((e) => mutation!.addOnUpdateLoadingCallback(e));
      _onClearListMap[retainKey]
          ?.forEach((e) => mutation!.addOnClearCallback(e));
      _onDisposeListMap[retainKey]
          ?.forEach((e) => mutation!.addOnDisposeCallback(e));

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
    _onUpdateDataListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnUpdateDataCallback(e));
    _onUpdateErrorListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnUpdateErrorCallback(e));
    _onUpdateInitializingListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnUpdateInitializingCallback(e));
    _onUpdateLoadingListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnUpdateLoadingCallback(e));
    _onClearListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnClearCallback(e));
    _onDisposeListMap[retainKey]
        ?.forEach((e) => mutation!.removeOnDisposeCallback(e));
    return true;
  }
}

Mutation<R> useMutation<R>({
  R? initialValue,
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
}) {
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
        isStatic: isStatic);
  }, [key]);
  useEffect(() {
    return () {
      MutationCache.instance.release(key);
    };
  }, [mutation]);
  return mutation;
}
