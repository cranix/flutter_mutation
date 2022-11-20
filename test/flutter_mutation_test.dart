
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_mutation/flutter_mutation.dart';

void main() {
  test('mutation test', () {
    final mutation = Mutation();
    expect(mutation.isEmpty, true);

    mutation.update(1);
    expect(mutation.data, 1);
  });
}
