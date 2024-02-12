import 'package:flutter_mutation/exception/mutation_exception.dart';

class MutationClosedException extends MutationException {
  const MutationClosedException() : super("mutation closed");
}
