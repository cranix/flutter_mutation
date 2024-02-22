import 'package:example/getting_started/getting_started_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

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
