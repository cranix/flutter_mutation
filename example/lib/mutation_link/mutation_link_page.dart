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
    final mutation1 = useMutation<String>();
    final mutation2 = useMutation<String>(onCreate: (mutation) {
      onUpdate(data, {before}) {
        MutationLinkApi.get2().mutate(mutation.key);
      }

      observeMutation(mutation1.key, onUpdateData: onUpdate);
      return () {
        final res =
            removeObserveMutation(mutation1.key, onUpdateData: onUpdate);
        print("onDispose:$res");
      };
    });

    final onPressed = useCallback(() {
      MutationLinkApi.get1().mutate(mutation1.key);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("mutation link"),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            final data = useMutationData(key: mutation1.key);
            return Text(data ?? "-");
          }),
          HookBuilder(builder: (context) {
            final data = useMutationData(key: mutation2.key);
            return Text(data ?? "-");
          }),
          ElevatedButton(onPressed: onPressed, child: const Text("click"))
        ],
      ),
    );
  }
}
