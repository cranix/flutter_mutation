import 'package:example/mutation_link/mutation_link_api.dart';
import 'package:flutter/material.dart';
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
    final mutationKey1 = useMutationKey<String>();
    final mutationKey2 = useMutationKey<String>();
    useEffect(() {
      mutationKey2.addObserve(onCreate: (mutation) {
        onUpdate(data, {before}) {
          MutationLinkApi.get2().mutate(mutation.key);
        }

        mutationKey1.addObserve(onUpdateData: onUpdate);
        return () {
          final res = mutationKey1.removeObserve(onUpdateData: onUpdate);
          print("onDispose:$res");
        };
      });
    }, [mutationKey2]);

    final onPressed = useCallback(() {
      MutationLinkApi.get1().mutate(mutationKey1);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("mutation link"),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            final data = useMutationData(key: mutationKey1);
            return Text(data ?? "-");
          }),
          HookBuilder(builder: (context) {
            final data = useMutationData(key: mutationKey2);
            return Text(data ?? "-");
          }),
          ElevatedButton(onPressed: onPressed, child: const Text("click"))
        ],
      ),
    );
  }
}
