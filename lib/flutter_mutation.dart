library flutter_mutation;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
  final List<MutationOnUpdateInitializingCallback> _onUpdateInitializingList = [];
  final List<MutationOnUpdateLoadingCallback> _onUpdateLoadingList = [];
  final List<MutationOnClearCallback> _onClearList = [];

  Mutation(
      {R? initialValue,
        MutationGetInitialValueCallback<R>? getInitialValue,
        MutationOnUpdateInitializingCallback? onUpdateInitializing,
        MutationOnUpdateDataCallback<R>? onUpdateData,
        MutationOnUpdateErrorCallback? onUpdateError,
        MutationOnUpdateLoadingCallback? onUpdateLoading,
        MutationOnClearCallback? onClear}) {
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
    if (initialValue != null) {
      _setData(initialValue);
    }
    if (getInitialValue != null) {
      _initMutate(getInitialValue());
    }
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
    }
    else {
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
    dataList = [];
    _error = null;
    _loading = false;
    _onUpdateDataList.clear();
    _onUpdateErrorList.clear();
    _onUpdateLoadingList.clear();
    _onClearList.clear();
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

class MutationCache {
  static final instance = MutationCache._();
  final _data = <String, Mutation>{};
  final _retainCount = <String, int>{};

  MutationCache._();

  Mutation<R> retain<R>(String retainKey,
      {R? initialValue,
        MutationGetInitialValueCallback<R>? getInitialValue,
        MutationOnUpdateDataCallback<R>? onUpdateData,
        MutationOnUpdateErrorCallback? onUpdateError,
        MutationOnUpdateInitializingCallback? onUpdateInitializing,
        MutationOnUpdateLoadingCallback? onUpdateLoading,
        MutationOnClearCallback? onClear}) {
    var mutation = _data[retainKey] as Mutation<R>?;
    if (mutation == null) {
      mutation = Mutation<R>(
          initialValue: initialValue,
          getInitialValue: getInitialValue,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitializing: onUpdateInitializing,
          onUpdateLoading: onUpdateLoading,
          onClear: onClear);
      _data[retainKey] = mutation;
    }
    _retainCount[retainKey] = (_retainCount[retainKey] ?? 0) + 1;
    return mutation;
  }

  bool release(String retainKey) {
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
      String? retainKey}) {
  String key = retainKey ?? UniqueKey().toString();
  final mutation = useMemoized(() {
    return MutationCache.instance.retain<R>(key,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitializing: onUpdateInitializing,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear);
  }, [key]);
  useEffect(() {
    return () {
      MutationCache.instance.release(key);
    };
  }, [mutation]);
  return mutation;
}