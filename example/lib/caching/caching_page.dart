import 'package:example/caching/caching_api.dart';
import 'package:example/caching/caching_next_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

final MutationKey<CachingResponse> cacheKey = MutationKey.autoCloseOf("aa");

class CachingPage extends HookWidget {
  const CachingPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const CachingPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final subscription = cacheKey.observe(onClose: (mutation) {
        print("closed:$mutation");
      });
      return () {
        subscription.cancel();
        print("disposed:$cacheKey");
      };
    }, [cacheKey]);
    final onPressRefresh = useCallback(() async {
      await CachingApi.get().mutate(cacheKey);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HookBuilder(
                key: UniqueKey(),
                builder: (context) {
                  final loading = useMutationLoading(key: cacheKey);
                  return loading
                      ? const Text("Loading...")
                      : const Text("complete");
                }),
            HookBuilder(builder: (context) {
              final data = useMutationData(
                  key: cacheKey, lazyInitialValue: CachingApi.get);
              return Text("title:${data?.title}");
            }),
            TextButton(onPressed: onPressRefresh, child: const Text("refresh")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(CachingNextPage.createRoute());
                },
                child: const Text("next"))
          ],
        ),
      ),
    );
  }
}
