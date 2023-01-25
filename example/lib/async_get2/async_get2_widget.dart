import 'package:example/async_get2/async_get2_api.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class AsyncGet2Widget extends HookWidget {
  const AsyncGet2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    final mutation = useMutation(
        getInitialValue: AsyncGet2Api.get2
    );
    useListenable(mutation);
    return Text(mutation.data ?? "loading");
  }
}