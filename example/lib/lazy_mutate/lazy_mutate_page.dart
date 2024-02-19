import 'package:example/lazy_mutate/lazy_mutate_api.dart';
import 'package:example/lazy_mutate/lazy_mutate_next_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';


class LazyMutatePage extends HookWidget {
  const LazyMutatePage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const LazyMutatePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("lazy mutate page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading<String>(keyOf: "lazyMutate");
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(
                  keyOf: "lazyMutate", lazyInitialData: LazyMutateApi.get);
              return Text("data:$data");
            }),
            TextButton(
                onPressed: () {
                  LazyMutateApi.get().mutate(MutationKey.of("lazyMutate"));
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