import 'package:example/async_get2/async_get2_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';
import 'package:flutter_mutation/mutation_cache.dart';

class AsyncGet2Widget extends HookWidget {
  const AsyncGet2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    print("cache:${MutationCache.instance}");
    final data = useMutationData(
        initialMutate: AsyncGet2Api.get2
    );
    return Text(data ?? "loading");
  }
}