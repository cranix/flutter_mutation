import 'package:flutter_mutation/mutation.dart';
import 'package:flutter_mutation/mutation_key.dart';
import 'package:flutter_mutation/mutation_types.dart';

enum EventKey { DATA, ERROR, INITIALIZED, LOADING, OPEN, CLOSE }

class MutationCache {
  static final instance = MutationCache._();
  final _data = <MutationKey, Mutation>{};
  final _retainCount = <MutationKey, int>{};

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

  MutationCancelFunction addObserve<R>(MutationKey<R> key,
      {MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      initialCall = false}) {
    if (onUpdateData != null) {
      if (initialCall) {
        onUpdateData(key.data, before: key.data);
      }
      final list = _getOrNewMapList(EventKey.DATA, key);
      list.add(onUpdateData);
    }
    if (onUpdateError != null) {
      if (initialCall) {
        onUpdateError(key.error, before: key.error);
      }
      final list = _getOrNewMapList(EventKey.ERROR, key);
      list.add(onUpdateError);
    }
    if (onUpdateInitialized != null) {
      if (initialCall) {
        if (key.isInitialized) {
          onUpdateInitialized();
        }
      }
      final list = _getOrNewMapList(EventKey.INITIALIZED, key);
      list.add(onUpdateInitialized);
    }
    if (onUpdateLoading != null) {
      if (initialCall) {
        onUpdateLoading(key.isLoading);
      }
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
    return () {
      removeObserve(key,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitialized: onUpdateInitialized,
          onUpdateLoading: onUpdateLoading,
          onOpen: onOpen,
          onClose: onClose);
    };
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

  _onClose(MutationKey key, Mutation mutation) {
    _onEventMapListMap[EventKey.CLOSE]?[key]?.forEach((e) => e(mutation));
  }

  Mutation<R> getOrOpen<R>(MutationKey<R> key,
      {MutationInitialDataCallback<R>? initialData,
      MutationLazyInitialDataCallback<R>? lazyInitialData,
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
          initialData: initialData,
          lazyInitialData: lazyInitialData,
          onUpdateData: onUpdateData,
          onUpdateError: onUpdateError,
          onUpdateInitialized: onUpdateInitialized,
          onUpdateLoading: onUpdateLoading,
          onClose: onClose);

      _onEventMapListMap[EventKey.OPEN]?[key]?.forEach((e) {
        final res = e(mutation);
        if (res != null) {
          mutation?.addObserve(
              onClose: (mutation) {
                res();
              },
              autoDisposable: false);
        }
      });
      for (var observeKey in observeKeys) {
        _onEventMapListMap[EventKey.OPEN]?[observeKey]?.forEach((e) {
          final res = e(mutation);
          if (res != null) {
            mutation?.addObserve(
                onClose: (mutation) {
                  res();
                },
                autoDisposable: false);
          }
        });
      }
      if (onOpen != null) {
        final res = onOpen(mutation);
        if (res != null) {
          mutation.addObserve(
              onClose: (mutation) {
                res();
              },
              autoDisposable: false);
        }
      }
      mutation.addObserve(
          onUpdateData: (data, {before}) {
            _onUpdateData(key, data, before: before);
            for (var observeKey in observeKeys) {
              _onUpdateData(observeKey, data, before: before);
            }
          },
          onUpdateError: (error, {before}) {
            _onUpdateError(key, error, before: before);
            for (var observeKey in observeKeys) {
              _onUpdateError(observeKey, error, before: before);
            }
          },
          onUpdateInitialized: () {
            _onUpdateInitialized(key);
            for (var observeKey in observeKeys) {
              _onUpdateInitialized(observeKey);
            }
          },
          onUpdateLoading: (loading) {
            _onUpdateLoading(key, loading);
            for (var observeKey in observeKeys) {
              _onUpdateLoading(observeKey, loading);
            }
          },
          onClose: (mutation) {
            _onClose(key, mutation);
            for (var observeKey in observeKeys) {
              _onClose(observeKey, mutation);
            }
          },
          autoDisposable: false);
      _data[key] = mutation;
      _retainCount[key] = 0;
    }
    return mutation;
  }

  Mutation<R> retain<R>(MutationKey<R> key,
      {MutationInitialDataCallback<R>? initialData,
      MutationLazyInitialDataCallback<R>? lazyInitialData,
      MutationOnUpdateDataCallback<R>? onUpdateData,
      MutationOnUpdateErrorCallback? onUpdateError,
      MutationOnUpdateInitializedCallback? onUpdateInitialized,
      MutationOnUpdateLoadingCallback? onUpdateLoading,
      MutationOnOpenCallback<R>? onOpen,
      MutationOnCloseCallback<R>? onClose,
      List<MutationKey<R>> observeKeys = const []}) {
    final mutation = getOrOpen(key,
        initialData: initialData,
        lazyInitialData: lazyInitialData,
        onUpdateData: onUpdateData,
        onUpdateError: onUpdateError,
        onUpdateInitialized: onUpdateInitialized,
        onUpdateLoading: onUpdateLoading,
        onOpen: onOpen,
        onClose: onClose,
        observeKeys: observeKeys);
    _retainCount[key] = (_retainCount[key] ?? 0) + 1;
    return mutation;
  }

  bool release(MutationKey key) {
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
    _retainCount.remove(key);
    return _data.remove(key) != null;
  }

  Mutation<R>? getMutation<R>(MutationKey<R> key) {
    return _data[key] as Mutation<R>?;
  }
}
