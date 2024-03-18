import 'dart:math';

import 'package:example/async_get3/async_get_api3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';

final mutationKey = MutationKey<bool>().retain(
    initialMutate: AsyncGetApi3.get,
    onUpdateData: (data, {before}) {
      print("onUpdateData:$data, $before");
    });

class AsyncGetPage3 extends HookWidget {
  const AsyncGetPage3({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const AsyncGetPage3();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    useEffect(() {
      print("onUpdateData2.observe");
      return mutationKey.observe(onUpdateData: (data, {before}) {
        print("onUpdateData2:$data, $before");
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("async get page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // HookBuilder(builder: (context) {
                //   final data = useMutationLoading(key: mutationKey);
                //   return Text("loading:$data");
                // }),
                // HookBuilder(builder: (context) {
                //   final data = useMutationData(key: mutationKey);
                //   return Text("data:$data");
                // }),
                // HookBuilder(builder: (context) {
                //   final data = useMutationInitialized(key: mutationKey);
                //   return Text("initialized:$data");
                // }),
                // HookBuilder(builder: (context) {
                //   final data = useMutationError(key: mutationKey);
                //   return Text("error:$data");
                // }),
                TextButton(
                    onPressed: () async {
                      mutationKey.observe(onUpdateData: (data, {before}) {
                        print("onUpdateData3:$data, $before");
                      });
                    },
                    child: const Text("observe + 1")),
                TextButton(
                    onPressed: () async {
                      mutationKey.mutateNow(Random().nextBool());
                    },
                    child: const Text("mutateNow")),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
