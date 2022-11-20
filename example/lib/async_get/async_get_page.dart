import 'package:example/async_get/async_get_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

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
