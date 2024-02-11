import 'package:flutter_mutation/flutter_mutation.dart';

class GlobalStateMutations {
  static final instance = GlobalStateMutations._internal();
  final authTokenKey = MutationKey<String>();

  GlobalStateMutations._internal() {
    authTokenKey.addObserve(
      onUpdateData: (data, {before}) {
        print("onUpdateData:$data, $before");
      },
      onClear: () {
        print("onClear");
      },
    );
  }
}
