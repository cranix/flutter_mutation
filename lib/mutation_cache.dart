import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

enum EventKey { DATA, ERROR, INITIALIZING, LOADING, CLEAR, CREATE, DISPOSE }

class MutationCache {
  static final instance = MutationCache._();
  final _data = <MutationKey, Mutation>{};
  final _retainCount = <MutationKey, int>{};
  final _staticKeys = <MutationKey>{};

  final _onEventMapListMap = <EventKey, Map<MutationKey, List>>{};

  MutationCache._();

  List _getOrNewMapList(EventKey event, MutationKey key) {
    var map = _onEventMapListMap[event];
    if (map == null) {
      map = <MutationKey, List>{};
      _onEventMapListMap[event] = map;
    }
    var list = map[key];
    if (list == null) {
      list = [];
      map[key] = list;
    }
    return list;
  }

  bool _removeMapList(EventKey event, MutationKey key, dynamic value) {
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
    MutationKey<R> key, {
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
    MutationKey<R> key, {
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

  _onUpdateData(MutationKey retainKey, dynamic data) {
    _onEventMapListMap[EventKey.DATA]?[retainKey]?.forEach((e) => e(data));
  }

  _onUpdateError(MutationKey retainKey, Object? error) {
    _onEventMapListMap[EventKey.ERROR]?[retainKey]?.forEach((e) => e(error));
  }

  _onUpdateInitializing(MutationKey retainKey, bool initializing) {
    _onEventMapListMap[EventKey.INITIALIZING]?[retainKey]
        ?.forEach((e) => e(initializing));
  }

  _onUpdateLoading(MutationKey retainKey, bool loading) {
    _onEventMapListMap[EventKey.LOADING]?[retainKey]
        ?.forEach((e) => e(loading));
  }

  _onClear(MutationKey retainKey) {
    _onEventMapListMap[EventKey.CLEAR]?[retainKey]?.forEach((e) => e());
  }

  _onDispose(MutationKey retainKey, Mutation mutation) {
    _onEventMapListMap[EventKey.DISPOSE]?[retainKey]
        ?.forEach((e) => e(mutation));
  }

  Mutation<R> retain<R>(MutationKey<R> key,
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializingCallback? onUpdateInitializing,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnClearCallback? onClear,
      MutationOnCreateCallback<R>? onCreate,
      MutationOnDisposeCallback<R>? onDispose,
      bool static = false,
      List<MutationKey<R>> observeKeys = const []}) {
    var mutation = _data[key] as Mutation<R>?;
    if (mutation == null) {
      mutation = Mutation<R>(
        key,
        initialValue: initialValue,
        getInitialValue: getInitialValue,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitializing: onUpdateInitializing,
        onUpdateLoading: onUpdateLoading,
        onClear: onClear,
        onCreate: onCreate,
        onDispose: onDispose
      );
      _onEventMapListMap[EventKey.CREATE]?[key]?.forEach((e) => e(mutation));
      for (var observeKey in observeKeys) {
        _onEventMapListMap[EventKey.CREATE]?[observeKey]
            ?.forEach((e) => e(mutation));
      }
      mutation.addOnUpdateDataCallback((data, {before}) {
        _onUpdateData(key, data);
        for (var observeKey in observeKeys) {
          _onUpdateData(observeKey, data);
        }
      });
      mutation.addOnUpdateErrorCallback((error, {before}) {
        _onUpdateError(key, error);
        for (var observeKey in observeKeys) {
          _onUpdateError(observeKey, error);
        }
      });
      mutation.addOnUpdateInitializingCallback((initializing) {
        _onUpdateInitializing(key, initializing);
        for (var observeKey in observeKeys) {
          _onUpdateInitializing(observeKey, initializing);
        }
      });
      mutation.addOnUpdateLoadingCallback((loading) {
        _onUpdateLoading(key, loading);
        for (var observeKey in observeKeys) {
          _onUpdateLoading(observeKey, loading);
        }
      });
      mutation.addOnClearCallback(() {
        _onClear(key);
        for (var observeKey in observeKeys) {
          _onClear(observeKey);
        }
      });
      mutation.addOnDisposeCallback((mutation) {
        _onDispose(key, mutation);
        for (var observeKey in observeKeys) {
          _onDispose(observeKey, mutation);
        }
      });
      _data[key] = mutation;
      if (static) {
        _staticKeys.add(key);
      }
    }
    if (!static) {
      _retainCount[key] = (_retainCount[key] ?? 0) + 1;
    }
    return mutation;
  }

  bool release(MutationKey key) {
    if (_staticKeys.contains(key)) {
      return false;
    }
    int? count = _retainCount[key];
    if (count == null) {
      return false;
    }
    if (count > 1) {
      _retainCount[key] = count - 1;
      return false;
    }
    _retainCount.remove(key);
    final mutation = _data.remove(key);
    mutation?.dispose();
    return true;
  }

  bool removeStatic(MutationKey key) {
    _data.remove(key)?.dispose();
    return _staticKeys.remove(key);
  }

  Mutation<R>? getMutation<R>(MutationKey<R> key) {
    return _data[key] as Mutation<R>?;
  }
}
