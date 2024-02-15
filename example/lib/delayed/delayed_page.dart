import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class DelayedPage extends HookWidget {
  const DelayedPage({super.key});


  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const DelayedPage();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("async get page"),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HookBuilder(
                    builder: (context) {
                      final key = useMutationKey<bool>(of: "aa_1");
                      final data = useMutationData(
                          key: key,
                          onUpdateData: (data, {before}) {
                            print("onUpdateData:$data");
                          },
                          initialValue: () {
                            Future.delayed(Duration(milliseconds: 5000), () {
                              print("mutationDelayed:$key");
                              key.mutate(false);
                            });
                            return false;
                          });
                      print("data1:$data");
                      return Text("data1:$data");
                    }
                ),
                HookBuilder(
                    builder: (context) {
                      final key = useMutationKey<bool>(of: "aa_2");
                      final data = useMutationData(
                          key: key,
                          onUpdateData: (data, {before}) {
                            print("onUpdateData:$data");
                          },
                          initialValue: () {
                            Future.delayed(Duration(milliseconds: 5000), () {
                              print("mutationDelayed:$key");
                              key.mutate(false);
                            });
                            return true;
                          });
                      print("data2:${data!}");
                      return Text("data2:$data");
                    }
                ),
                HookBuilder(
                  builder: (context) {
                    final key = useMutationKey<bool>(of: "aa_3");
                    final data = useMutationData(
                        key: key,
                        onUpdateData: (data, {before}) {
                          print("onUpdateData:$data");
                        },
                        initialValue: () {
                          Future.delayed(Duration(milliseconds: 5000), () {
                            print("mutationDelayed:$key");
                            key.mutate(false);
                          });
                          return true;
                        });
                    print("data3:$data");
                    return Text("data3:$data");
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
