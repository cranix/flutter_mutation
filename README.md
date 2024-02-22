<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Flutter Mutation

## Features

easy to use flutter async state with hook

## Getting started

add pubspec.yml
```yaml
dependencies:
  flutter_mutation: ^latest
```

## Usage

- async get
```dart

class GettingStartedPage extends HookWidget {
  const GettingStartedPage({super.key});
  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const GettingStartedPage();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("getting started page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(keyOf: "get");
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data = useMutationLoading(keyOf: "get");
                  return Text("loading:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationData(keyOf: "get");
                  return Text("data:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationInitialized(keyOf: "get");
                  return Text("initialized:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationError(keyOf: "get");
                  return Text("error:$data");
                }),
                TextButton(
                    onPressed: () async {
                      MutationKey.of("get").mutate(GettingStartedApi.get());
                    },
                    child: const Text("mutate")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


```


- pagination
```dart

class PaginationPage extends HookWidget {
  const PaginationPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const PaginationPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    final mutationKey = useMutationKey<PaginationResponse>();
    final onPressMore = useCallback(() {
      PaginationApi.getList(mutationKey.data?.nextPageKey)
          .mutate(mutationKey, append: true);
    }, []);
    final onRefresh = useCallback(() async {
      return PaginationApi.getList().mutate(mutationKey);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("pagination page"),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: HookBuilder(builder: (context) {
          final dataList = useMutationDataList(key: mutationKey);
          final loading = useMutationLoading(
              key: mutationKey, lazyInitialData: PaginationApi.getList);
          final list = useMemoized(
                  () => dataList.expand((element) => element.list).toList(),
              [dataList]);
          return ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return TextButton(
                    onPressed: loading ? null : onPressMore,
                    child: loading
                        ? const Text("Loading...")
                        : const Text("More"));
              }
              final item = list[index];
              return ListTile(
                title: Text(item),
              );
            },
          );
        }),
      ),
    );
  }
}



```


- caching
```dart

final MutationKey<CachingResponse> cacheKey = MutationKey.of("aa");

class CachingPage extends HookWidget {
  const CachingPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const CachingPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    useEffect(() {
      return cacheKey.observe(onClose: (mutation) {
        print("closed:$mutation");
      });
    }, [cacheKey]);
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(cacheKey);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(
                key: UniqueKey(),
                builder: (context) {
                  final loading = useMutationLoading(key: cacheKey);
                  return loading
                      ? const Text("Loading...")
                      : const Text("complete");
                }),
            HookBuilder(builder: (context) {
              final data = useMutationData(
                  key: cacheKey, lazyInitialData: CachingApi.get);
              return Text("title:${data?.title}");
            }),
            TextButton(onPressed: onPressRefresh, child: const Text("refresh")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(CachingNextPage.createRoute());
                },
                child: const Text("next"))
          ],
        ),
      ),
    );
  }
}


class CachingNextPage extends HookWidget {
  const CachingNextPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const CachingNextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(cacheKey);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching next page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(key: cacheKey);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(
                  lazyInitialData: CachingApi.get, key: cacheKey);
              return Text(
                  "nickname: ${data?.nickname}\ncontents: ${data?.contents}");
            }),
            TextButton(onPressed: onPressRefresh, child: const Text("refresh"))
          ],
        ),
      ),
    );
  }
}

```


- global state
```dart

class GlobalStateMutations {
  static final authTokenKey = MutationKey<String>().retain(onOpen: (mutation) {
    print("onOpen:$mutation");
  }, onUpdateData: (data, {before}) {
    print("onUpdateData:$data, $before");
  });
}

class GlobalStatePage extends HookWidget {
  const GlobalStatePage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const GlobalStatePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    final onPressLogin = useCallback(() {
      GlobalStateApi.postLogin().mutate(GlobalStateMutations.authTokenKey);
    }, []);
    final onPressClear = useCallback(() {
      GlobalStateMutations.authTokenKey.clear();
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("global state page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading =
              useMutationLoading(key: GlobalStateMutations.authTokenKey);
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data =
                  useMutationData(key: GlobalStateMutations.authTokenKey);
                  return Text("authToken:$data");
                }),
                TextButton(onPressed: onPressLogin, child: const Text("login")),
                TextButton(onPressed: onPressClear, child: const Text("clear"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

```

- lazy mutate
```dart

final MutationKey<String> lazyMutateKey =
    MutationKey<String>().retain(onUpdateData: (data, {before}) {
  print("onUpdateData:$data");
}, onUpdateLoading: (loading) {
  print("onUpdateLoading:$loading");
});

class LazyMutatePage extends HookWidget {
  const LazyMutatePage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const LazyMutatePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("lazy mutate page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading<String>(key: lazyMutateKey);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(
                  key: lazyMutateKey, lazyInitialData: LazyMutateApi.get);
              return Text("data:$data");
            }),
            TextButton(
                onPressed: () {
                  LazyMutateApi.get().mutate(lazyMutateKey);
                },
                child: const Text("refresh")),
            TextButton(
                onPressed: () {
                  lazyMutateNextKey.lazyMutate(LazyMutateApi.get2);
                },
                child: const Text("lazyMutateNext")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(LazyMutateNextPage.createRoute());
                },
                child: const Text("next"))
          ],
        ),
      ),
    );
  }
}



final MutationKey<String> lazyMutateNextKey =
MutationKey<String>().retain(onUpdateData: (data, {before}) {
  print("onUpdateData:$data");
}, onUpdateLoading: (loading) {
  print("onUpdateLoading:$loading");
});

class LazyMutateNextPage extends HookWidget {
  const LazyMutateNextPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const LazyMutateNextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("lazy mutate next page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(key: lazyMutateNextKey);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(key: lazyMutateNextKey);
              return Text("data: $data");
            }),
            TextButton(
                onPressed: () {
                  lazyMutateNextKey.lazyMutate(LazyMutateApi.get2);
                },
                child: const Text("lazyMutate")),
            TextButton(
                onPressed: () {
                  lazyMutateKey.lazyMutate(LazyMutateApi.get);
                },
                child: const Text("lazyMutateBefore"))
          ],
        ),
      ),
    );
  }
}


```

## Additional information


