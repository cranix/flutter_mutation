import 'package:flutter_mutation/flutter_mutation.dart';

class GlobalStateMutations {
  static final authToken = Mutation<String>(
    getInitialValue: () async {
      // load authToken
    },
    onUpdateData: (data, {before}) {
      // save authToken
    },
    onClear: () {
      // remove authToken
    }
  );
}
