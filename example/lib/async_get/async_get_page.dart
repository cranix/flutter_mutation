import 'package:example/async_get/async_get_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/hooks/use_mutation_initialized.dart';
import 'package:flutter_mutation/mutation_cache.dart';

class AsyncGetPage extends HookWidget {
  const AsyncGetPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const AsyncGetPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    final mutationKey = useMutationKey<int>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("async get page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(key: mutationKey);
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data = useMutationLoading(key: mutationKey);
                  return Text("loading:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationData(key: mutationKey);
                  return Text("data:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationInitialized(key: mutationKey);
                  return Text("initialized:$data");
                }),
                HookBuilder(builder: (context) {
                  final data = useMutationError(key: mutationKey);
                  return Text("error:$data");
                }),
                TextButton(
                    onPressed: () async {
                      AsyncGetApi.get().mutateNow(mutationKey);
                    },
                    child: const Text("mutate")),
                TextButton(
                    onPressed: () {
                      AsyncGetApi.getError().mutateNow(mutationKey);
                    },
                    child: const Text("mutateError")),
                TextButton(
                    onPressed: () {
                      mutationKey.updateInitialMutate(AsyncGetApi.get);
                    },
                    child: const Text("updateInitialMutate")),
                TextButton(
                    onPressed: () {
                      mutationKey.forceInitialMutate();
                    },
                    child: const Text("forceInitialMutate")),
                TextButton(
                    onPressed: () {
                      mutationKey.clear();
                    },
                    child: const Text("clear")),
                TextButton(
                    onPressed: () {
                      mutationKey.clearData();
                    },
                    child: const Text("clearData")),
                TextButton(
                    onPressed: () {
                      mutationKey.clearError();
                    },
                    child: const Text("clearError")),
                TextButton(
                    onPressed: () {
                      mutationKey.close();
                    },
                    child: const Text("close"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
