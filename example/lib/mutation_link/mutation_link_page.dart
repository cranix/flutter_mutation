import 'package:example/mutation_link/mutation_link_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';

class MutationLinkPage extends HookWidget {
  const MutationLinkPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const MutationLinkPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    final mutationKey1 = useMutationKey<String>();
    final mutationKey2 = useMutationKey<String>();
    useEffect(() {
      return mutationKey2.observe(onOpen: (mutation) {
        print("onOpen:$mutation");
        return mutationKey1.observe(onUpdateData: (data, {before}) {
          MutationLinkApi.get2().mutateNow(mutationKey2);
        });
      });
    }, [mutationKey2]);

    final onPressed = useCallback(() {
      MutationLinkApi.get1().mutateNow(mutationKey1);
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
