import 'package:example/global_state/global_state_api.dart';
import 'package:example/global_state/global_state_mutations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class GlobalStatePage extends HookWidget {
  const GlobalStatePage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const GlobalStatePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onPressLogin = useCallback(() {
      GlobalStateApi.postLogin().mutate(GlobalStateMutations.authToken);
    }, []);
    final onPressClear = useCallback(() {
      GlobalStateMutations.authToken.clear();
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("global state page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            HookBuilder(builder: (context) {
              final loading =
                  useMutationLoading(GlobalStateMutations.authToken);
              return Visibility(
                  visible: loading, child: const CircularProgressIndicator());
            }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(builder: (context) {
                  final data = useMutationData(GlobalStateMutations.authToken);
                  return Text("authToken:$data");
                }),
                TextButton(onPressed: onPressLogin, child: const Text("login")),
                TextButton(onPressed: onPressClear, child: const Text("clear"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
