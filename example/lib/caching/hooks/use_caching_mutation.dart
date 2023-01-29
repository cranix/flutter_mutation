import 'package:example/caching/caching_api.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

Mutation<CachingResponse> useCachingMutation() => useMutation<CachingResponse>(
    getInitialValue: CachingApi.get,
    retainKey: "CachingApi.get");
