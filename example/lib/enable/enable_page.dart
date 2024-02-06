import 'package:example/enable/enable_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class EnablePage extends HookWidget {
  const EnablePage({super.key});


  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const EnablePage();
    });
  }
  @override
  Widget build(BuildContext context) {
    final enable = useState(false);
    final mutation = useMutation(getInitialValue: EnableApi.get, enable: enable.value);
    final data = useMutationData(mutation);
    return Scaffold(
      appBar: AppBar(
        title: const Text("async_get2"),
      ),
      body: Column(
        children: [
          Text("data:$data"),
          ElevatedButton(onPressed: () {
            enable.value = true;
          }, child: const Text("click"))
        ],
      ),
    );
  }
}
