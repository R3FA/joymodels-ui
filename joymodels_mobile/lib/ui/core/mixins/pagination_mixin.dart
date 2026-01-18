import 'package:flutter/foundation.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';

mixin PaginationMixin<T> on ChangeNotifier {
  PaginationResponseApiModel<T>? get paginationData;

  Future<void> loadPage(int pageNumber);

  bool get isLoadingPage => false;

  int get currentPage => paginationData?.pageNumber ?? 1;
  int get totalPages => paginationData?.totalPages ?? 1;
  bool get hasPreviousPage => paginationData?.hasPreviousPage ?? false;
  bool get hasNextPage => paginationData?.hasNextPage ?? false;
  int get totalRecords => paginationData?.totalRecords ?? 0;
  List<T> get items => paginationData?.data ?? [];

  Future<void> onNextPage() async {
    if (hasNextPage && !isLoadingPage) {
      await loadPage(currentPage + 1);
    }
  }

  Future<void> onPreviousPage() async {
    if (hasPreviousPage && !isLoadingPage) {
      await loadPage(currentPage - 1);
    }
  }

  Future<void> goToPage(int pageNumber) async {
    if (pageNumber >= 1 &&
        pageNumber <= totalPages &&
        pageNumber != currentPage &&
        !isLoadingPage) {
      await loadPage(pageNumber);
    }
  }

  Future<void> reloadCurrentPage() async {
    if (!isLoadingPage) {
      await loadPage(currentPage);
    }
  }
}
