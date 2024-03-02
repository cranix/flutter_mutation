import 'package:example/lazy_mutate/lazy_mutate_api.dart';
import 'package:example/lazy_mutate/lazy_mutate_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

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
    useOnAppLifecycleStateChange((previous, current) {
      print("lazy_mutate_next_page:$current");
    });
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
