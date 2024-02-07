import 'package:flutter/foundation.dart';

class MutationKey<R> {
  MutationKey();

  @override
  String toString() {
    return shortHash(this);
  }
}
