import 'package:example/pagination/pagination_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mutation/flutter_mutation.dart';

class PaginationPage extends HookWidget {
  const PaginationPage({super.key});

  static MaterialPageRoute createRoute() {
    return MaterialPageRoute(builder: (context) {
      return const PaginationPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation =
        useMutation<PaginationResponse>(getInitialValue: PaginationApi.getList);
    final onPressMore = useCallback(() {
      PaginationApi.getList(mutation.data?.nextPageKey)
          .mutate(mutation, append: true);
    }, []);
    final onRefresh = useCallback(() async {
      return PaginationApi.getList().mutate(mutation);
    }, []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("caching page"),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: HookBuilder(builder: (context) {
          final dataList = useMutationDataList(mutation);
          final loading = useMutationLoading(mutation);
          final list = useMemoized(
              () => dataList.expand((element) => element.list).toList(),
              [dataList]);
          return ListView.builder(
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return TextButton(
                    onPressed: loading ? null : onPressMore,
                    child: loading
                        ? const Text("Loading...")
                        : const Text("More"));
              }
              final item = list[index];
              return ListTile(
                title: Text(item),
              );
            },
          );
        }),
      ),
    );
  }
}
