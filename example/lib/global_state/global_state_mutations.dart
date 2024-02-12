import 'package:flutter_mutation/flutter_mutation.dart';

class GlobalStateMutations {
  static final authTokenKey = MutationKey<String>(
    onOpen: (mutation) {
      print("onOpen:$mutation");
    },
    onUpdateData: (data, {before}) {
      print("onUpdateData:$data, $before");
    },
  );
}
