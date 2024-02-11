import 'dart:async';

import 'package:flutter_mutation/mutation.dart';

typedef MutationOnDisposeCallback<R> = void Function(Mutation<R> mutation);
typedef MutationOnCreateCallback<R> = void Function()? Function(
    Mutation<R> mutation);
typedef MutationOnUpdateDataCallback<R> = void Function(R? data, {R? before});
typedef MutationOnUpdateErrorCallback = void Function(Object? error,
    {Object? before});
typedef MutationOnUpdateLoadingCallback = void Function(bool loading);
typedef MutationOnUpdateInitializedCallback = void Function(bool initialized);
typedef MutationOnClearCallback = void Function();
typedef MutationGetInitialValueCallback<R> = FutureOr<R?> Function();
