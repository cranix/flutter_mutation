import 'package:example/lazy_mutate/lazy_mutate_api.dart';
import 'package:example/lazy_mutate/lazy_mutate_next_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

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
                  key: lazyMutateKey, initialMutate: LazyMutateApi.get);
              return Text("data:$data");
            }),
            TextButton(
                onPressed: () {
                  LazyMutateApi.get().mutateNow(lazyMutateKey);
                },
                child: const Text("refresh")),
            TextButton(
                onPressed: () {
                  lazyMutateNextKey.mutate(LazyMutateApi.get2);
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
