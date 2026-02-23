import 'package:get/get.dart';

class PaginationConfig {
  static const int defaultRowsPerPage = 50;
  static const int stockRowsPerPage = 10;
  static const int largeRowsPerPage = 100;
  // Alias for backwards compatibility: use rowsPerPage across controllers
  static const int rowsPerPage = defaultRowsPerPage;
}

class PaginationInfo {
  final int page;
  final int rowsPerPage;
  final int total;

  const PaginationInfo({
    required this.page,
    required this.rowsPerPage,
    required this.total,
  });
}

class Paginator {
  final int pageSize;

  final RxInt currentPage = 1.obs;
  final RxInt total = 0.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  Paginator({required this.pageSize});

  void start(bool append) {
    if (append) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
    }
  }

  void finish(bool append) {
    if (append) {
      isLoadingMore.value = false;
    } else {
      isLoading.value = false;
    }
  }

  void applyServer(PaginationInfo info, int accumulatedCount) {
    currentPage.value = info.page;
    total.value = info.total;
    hasMore.value = accumulatedCount < info.total;
  }

  int nextPage() => currentPage.value + 1;
}
