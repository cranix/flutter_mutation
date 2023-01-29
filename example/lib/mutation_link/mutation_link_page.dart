import 'package:example/mutation_link/mutation_link_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class MutationLinkPage extends HookWidget {
  const MutationLinkPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const MutationLinkPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation1 = useMutation<String>(retainKey: "mutation_link_1");

    final mutation2 = useMutation<String>(onCreate: (mutation) {
      onUpdate(data) {
        MutationLinkApi.get2().mutate(mutation);
      }

      MutationCache.instance
          .addObserve("mutation_link_1", onUpdateData: onUpdate);
      return () {
        final res = MutationCache.instance
            .removeObserve("mutation_link_1", onUpdateData: onUpdate);
        print("onDispose:$res");
      };
    });

    final onPressed = useCallback(() {
      MutationLinkApi.get1().mutate(mutation1);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            final data = useMutationData(mutation1);
            return Text(data ?? "-");
          }),
          HookBuilder(builder: (context) {
            final data = useMutationData(mutation2);
            return Text(data ?? "-");
          }),
          ElevatedButton(onPressed: onPressed, child: const Text("click"))
        ],
      ),
    );
  }
}
