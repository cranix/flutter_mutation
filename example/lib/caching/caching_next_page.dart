import 'package:example/caching/caching_api.dart';
import 'package:example/caching/hooks/use_caching_mutation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class CachingNextPage extends HookWidget {
  const CachingNextPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const CachingNextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = useCachingMutation();
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(mutation);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching next page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading = useMutationLoading(mutation);
              return loading
                  ? const Text("Loading...")
                  : const Text("complete");
            }),
            HookBuilder(builder: (context) {
              final data = useMutationData(mutation);
              return Text(
                  "nickname: ${data?.nickname}\ncontents: ${data?.contents}");
            }),
            TextButton(onPressed: onPressRefresh, child: const Text("refresh"))
          ],
        ),
      ),
    );
  }
}
