import 'package:example/async_get2/async_get2_api.dart';
import 'package:example/async_get2/async_get2_widget.dart';
import 'package:example/async_get2/async_get3_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class AsyncGet2Page extends HookWidget {
  const AsyncGet2Page({super.key});
  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const AsyncGet2Page();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = useMutation(
      getInitialValue: AsyncGet2Api.get
    );
    useListenable(mutation);
    return Scaffold(
      appBar: AppBar(
        title: const Text("async_get2"),
      ),
      body: Column(
        children: [
          Text(mutation.data ?? "loading"),
          const AsyncGet2Widget(),
          const AsyncGet3Widget(),
        ],
      ),
    );
  }
}
