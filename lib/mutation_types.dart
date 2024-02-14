import 'dart:async';

import 'package:flutter_mutation/mutation_key.dart';

typedef MutationOnCloseCallback<R> = void Function(MutationKey<R> mutation);
typedef MutationOnOpenCallback<R> = void Function()? Function(
    MutationKey<R> mutation);
typedef MutationOnUpdateDataCallback<R> = void Function(R? data, {R? before});
typedef MutationOnUpdateErrorCallback = void Function(Object? error,
    {Object? before});
typedef MutationOnUpdateLoadingCallback = void Function(bool loading);
typedef MutationOnUpdateInitializedCallback = void Function();
typedef MutationLazyInitialValueCallback<R> = FutureOr<R> Function();
typedef MutationInitialValueCallback<R> = R Function();
