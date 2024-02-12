import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_subscription.dart';
import 'package:flutter_mutation/mutation_types.dart';

enum EventKey { DATA, ERROR, INITIALIZED, LOADING, OPEN, CLOSE }

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

  MutationSubscription<R> addObserve<R>(
    MutationKey<R> key, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
  }) {
    if (onUpdateData != null) {
      final list = _getOrNewMapList(EventKey.DATA, key);
      list.add(onUpdateData);
    }
    if (onUpdateError != null) {
      final list = _getOrNewMapList(EventKey.ERROR, key);
      list.add(onUpdateError);
    }
    if (onUpdateInitialized != null) {
      final list = _getOrNewMapList(EventKey.INITIALIZED, key);
      list.add(onUpdateInitialized);
    }
    if (onUpdateLoading != null) {
      final list = _getOrNewMapList(EventKey.LOADING, key);
      list.add(onUpdateLoading);
    }
    if (onOpen != null) {
      final list = _getOrNewMapList(EventKey.OPEN, key);
      list.add(onOpen);
    }
    if (onClose != null) {
      final list = _getOrNewMapList(EventKey.CLOSE, key);
      list.add(onClose);
    }

    return MutationSubscription(key,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose);
  }

  bool removeObserve<R>(
    MutationKey<R> key, {
    MutationOnUpdateDataCallback<R>? onUpdateData,
    MutationOnUpdateErrorCallback? onUpdateError,
    MutationOnUpdateInitializedCallback? onUpdateInitialized,
    MutationOnUpdateLoadingCallback? onUpdateLoading,
    MutationOnOpenCallback<R>? onOpen,
    MutationOnCloseCallback<R>? onClose,
  }) {
    if (onUpdateData != null) {
      return _removeMapList(EventKey.DATA, key, onUpdateData);
    }
    if (onUpdateError != null) {
      return _removeMapList(EventKey.ERROR, key, onUpdateError);
    }
    if (onUpdateInitialized != null) {
      return _removeMapList(EventKey.INITIALIZED, key, onUpdateInitialized);
    }
    if (onUpdateLoading != null) {
      return _removeMapList(EventKey.LOADING, key, onUpdateLoading);
    }
    if (onOpen != null) {
      return _removeMapList(EventKey.OPEN, key, onOpen);
    }
    if (onClose != null) {
      return _removeMapList(EventKey.CLOSE, key, onClose);
    }
    return false;
  }

  _onUpdateData(MutationKey retainKey, dynamic data, {dynamic before}) {
    _onEventMapListMap[EventKey.DATA]?[retainKey]
        ?.forEach((e) => e(data, before: before));
  }

  _onUpdateError(MutationKey retainKey, Object? error, {dynamic before}) {
    _onEventMapListMap[EventKey.ERROR]?[retainKey]
        ?.forEach((e) => e(error, before: before));
  }

  _onUpdateInitialized(MutationKey retainKey) {
    _onEventMapListMap[EventKey.INITIALIZED]?[retainKey]?.forEach((e) => e());
  }

  _onUpdateLoading(MutationKey retainKey, bool loading) {
    _onEventMapListMap[EventKey.LOADING]?[retainKey]
        ?.forEach((e) => e(loading));
  }

  _onClose(MutationKey retainKey, Mutation mutation) {
    _onEventMapListMap[EventKey.CLOSE]?[retainKey]?.forEach((e) => e(mutation));
  }

  Mutation<R> retain<R>(MutationKey<R> key,
      {R? initialValue,
      MutationGetInitialValueCallback<R>? getInitialValue,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []}) {
    var mutation = _data[key] as Mutation<R>?;
    if (mutation == null) {
      mutation = Mutation<R>(key,
          initialValue: initialValue,
          getInitialValue: getInitialValue,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitialized: onUpdateInitialized,
          onUpdateLoading: onUpdateLoading,
          onClose: onClose);

      _onEventMapListMap[EventKey.OPEN]?[key]?.forEach((e) {
        final res = e(mutation);
        mutation?.addOnCloseCallback((mutation) {
          if (res != null) {
            res();
          }
        });
      });
      for (var observeKey in observeKeys) {
        _onEventMapListMap[EventKey.OPEN]?[observeKey]?.forEach((e) {
          final res = e(mutation);
          mutation!.addOnCloseCallback((mutation) {
            if (res != null) {
              res();
            }
          });
        });
      }
      if (onOpen != null) {
        final res = onOpen(mutation);
        if (res != null) {
          mutation.addOnCloseCallback((mutation) {
            res();
          });
        }
      }
      mutation.addOnUpdateDataCallback((data, {before}) {
        _onUpdateData(key, data, before: before);
        for (var observeKey in observeKeys) {
          _onUpdateData(observeKey, data);
        }
      });
      mutation.addOnUpdateErrorCallback((error, {before}) {
        _onUpdateError(key, error, before: before);
        for (var observeKey in observeKeys) {
          _onUpdateError(observeKey, error);
        }
      });
      mutation.addOnUpdateInitializedCallback(() {
        _onUpdateInitialized(key);
        for (var observeKey in observeKeys) {
          _onUpdateInitialized(observeKey);
        }
      });
      mutation.addOnUpdateLoadingCallback((loading) {
        _onUpdateLoading(key, loading);
        for (var observeKey in observeKeys) {
          _onUpdateLoading(observeKey, loading);
        }
      });
      mutation.addOnCloseCallback((mutation) {
        _onClose(key, mutation);
        for (var observeKey in observeKeys) {
          _onClose(observeKey, mutation);
        }
      });
      _data[key] = mutation;
      if (key.static) {
        _staticKeys.add(key);
      }
    }
    if (!key.static) {
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
    return remove(key);
  }

  bool remove(MutationKey key) {
    if (key.static) {
      _staticKeys.remove(key);
    } else {
      _retainCount.remove(key);
    }
    return _data.remove(key) != null;
  }

  Mutation<R>? getMutation<R>(MutationKey<R> key) {
    return _data[key] as Mutation<R>?;
  }
}
