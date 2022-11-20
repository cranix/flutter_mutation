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
class AsyncGetPage extends HookWidget {
  const AsyncGetPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const AsyncGetPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = useMutation<int>();
    final onPressRequest = useCallback(() {
      AsyncGetApi.get()
          .mutate(mutation);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("async get page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(mutation);
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data = useMutationData(mutation);
                  return Text("result:$data");
                }),
                TextButton(
                    onPressed: onPressRequest, child: const Text("request"))
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
    final mutation =
        useMutation<PaginationResponse>(getInitialValue: PaginationApi.getList);
    final onPressMore = useCallback(() {
      PaginationApi.getList(mutation.data?.nextPageKey)
          .mutate(mutation, append: true);
    }, []);
    final onRefresh = useCallback(() async {
      return PaginationApi.getList().mutate(mutation);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: HookBuilder(builder: (context) {
          final dataList = useMutationDataList(mutation);
          final loading = useMutationLoading(mutation);
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

Mutation<CachingResponse> useCachingMutation() => useMutation<CachingResponse>(
    getInitialValue: CachingApi.get, retainKey: "CachingApi.get");

class CachingPage extends HookWidget {
  const CachingPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const CachingPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = useCachingMutation();
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(mutation);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(mutation);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(mutation);
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
    final mutation = useCachingMutation();
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(mutation);
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
              final loading = useMutationLoading(mutation);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(mutation);
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
  static final authToken = Mutation<String>(
      getInitialValue: () async {
        // load authToken
      },
      onUpdateData: (data) {
        // save authToken
      },
      onClear: () {
        // remove authToken
      }
  );
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
    final onPressLogin = useCallback(() {
      GlobalStateApi.postLogin().mutate(GlobalStateMutations.authToken);
    }, []);
    final onPressClear = useCallback(() {
      GlobalStateMutations.authToken.clear();
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
                  useMutationLoading(GlobalStateMutations.authToken);
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data = useMutationData(GlobalStateMutations.authToken);
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

## Additional information


