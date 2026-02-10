import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../api/ev.dart';
import '../../models/ev/ev_wallet_list_response.dart';

class EvWalletController extends GetxController {
  final EV _evApi = EV();

  // Transaction data
  final RxList<Group> walletTransactions = <Group>[].obs;
  final RxList<Group> filteredTransactions = <Group>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingBalance = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Balance
  final RxDouble totalBalance = 0.0.obs;

  // Filters
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int rowsPerPage = 10;
  final RxInt totalTransactions = 0.obs;

  // Helper getters
  bool get hasWalletData => walletTransactions.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    await Future.wait([fetchBalance(), fetchWalletTransactions()]);
  }

  // Fetch wallet balance
  Future<void> fetchBalance() async {
    try {
      isLoadingBalance.value = true;
      final response = await _evApi.getEvWalletAmount(Get.context!);

      if (response.body?.status == true) {
        totalBalance.value = (response.body?.data ?? 0).toDouble();
      } else {
        errorMessage.value = response.body?.message ?? 'Failed to fetch balance';
        hasError.value = true;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      hasError.value = true;
    } finally {
      isLoadingBalance.value = false;
    }
  }

  // Fetch wallet transactions
  Future<void> fetchWalletTransactions({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
      } else {
        if (!hasMoreData.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      }

      hasError.value = false;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _evApi.getEvWalletList(Get.context!, currentPage.value, rowsPerPage);

      if (response.body?.status == true) {
        final walletData = response.body?.data;

        // Update balance from wallet data if available
        if (walletData?.totalBalance != null) {
          totalBalance.value = walletData!.totalBalance!;
        }

        final newGroups = walletData?.groups ?? [];

        if (!loadMore) {
          walletTransactions.clear();
        }

        // Process and add new groups
        for (var newGroup in newGroups) {
          if (newGroup.date != null &&
              newGroup.transactions != null &&
              newGroup.transactions!.isNotEmpty) {
            // Check if we already have this date
            final existingIndex = walletTransactions.indexWhere(
              (group) => group.date == newGroup.date,
            );

            if (existingIndex >= 0) {
              // Merge transactions for the same date
              final existingGroup = walletTransactions[existingIndex];
              // FIX: Explicitly type the list
              final List<Transaction> mergedTransactions = <Transaction>[
                ...(existingGroup.transactions ?? []),
                ...(newGroup.transactions ?? []),
              ];
              walletTransactions[existingIndex] = Group(
                date: newGroup.date,
                transactions: mergedTransactions,
              );
            } else {
              walletTransactions.add(newGroup);
            }
          }
        }

        // Sort by date (newest first)
        walletTransactions.sort((a, b) {
          if (a.date == null || b.date == null) return 0;
          final dateA = _parseDateString(a.date!);
          final dateB = _parseDateString(b.date!);
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });

        // Sort transactions within each group by createdDate (newest first)
        for (var group in walletTransactions) {
          if (group.transactions != null) {
            group.transactions!.sort((a, b) {
              final dateA = _parseDateTimeString(a.createdDate);
              final dateB = _parseDateTimeString(b.createdDate);
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA);
            });
          }
        }

        totalTransactions.value = response.body?.pagination?.total ?? 0;

        // Update pagination status
        final currentItemCount = _countAllTransactions();
        hasMoreData.value = currentItemCount < totalTransactions.value && newGroups.isNotEmpty;

        // Apply current filters
        applyFilter(selectedFilter.value);
      } else {
        hasError.value = true;
        errorMessage.value = response.body?.message ?? 'Failed to load transactions';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      log('Error fetching wallet transactions: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Helper to parse date string
  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e2) {
        return null;
      }
    }
  }

  // Helper to parse date-time string
  DateTime? _parseDateTimeString(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  // Count all transactions
  int _countAllTransactions() {
    return walletTransactions.fold(0, (sum, group) => sum + (group.transactions?.length ?? 0));
  }

  // Load more data
  Future<void> loadMoreData() async {
    await fetchWalletTransactions(loadMore: true);
  }

  // Refresh all data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await Future.wait([fetchBalance(), fetchWalletTransactions()]);
  }

  // Apply filter
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    filteredTransactions.clear();

    if (walletTransactions.isEmpty) return;

    for (var group in walletTransactions) {
      final transactions = group.transactions;
      if (transactions == null || transactions.isEmpty) continue;

      List<Transaction> filteredGroupTransactions;

      switch (filter) {
        case 'income':
          filteredGroupTransactions = transactions.where((t) => t.type == 1).toList();
          break;
        case 'expense':
          filteredGroupTransactions = transactions.where((t) => t.type == 2).toList();
          break;
        default: // 'all'
          filteredGroupTransactions = transactions;
      }

      if (filteredGroupTransactions.isNotEmpty) {
        filteredTransactions.add(Group(date: group.date, transactions: filteredGroupTransactions));
      }
    }
  }

  // Search transactions
  List<Group> searchTransactions(String query) {
    if (query.isEmpty) return getGroupedTransactions();

    searchQuery.value = query;
    final List<Group> results = [];
    final searchLower = query.toLowerCase();

    for (var group in getGroupedTransactions()) {
      if (group.transactions == null) continue;

      final matching =
          group.transactions!.where((transaction) {
            final description = transaction.description?.toLowerCase() ?? '';
            final code = transaction.code?.toLowerCase() ?? '';
            final amount = (transaction.amount ?? 0).toString();
            return description.contains(searchLower) ||
                code.contains(searchLower) ||
                amount.contains(searchLower);
          }).toList();

      if (matching.isNotEmpty) {
        results.add(Group(date: group.date, transactions: matching));
      }
    }

    return results;
  }

  // Clear all filters
  void clearAllFilters() {
    selectedFilter.value = 'all';
    searchQuery.value = '';
    applyFilter('all');
  }

  // Get grouped transactions based on current filter
  List<Group> getGroupedTransactions() {
    return selectedFilter.value == 'all' ? walletTransactions : filteredTransactions;
  }

  // Format date for display
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    final date = _parseDateString(dateStr);
    if (date == null) return dateStr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  // Get transaction type info
  Map<String, dynamic> getTransactionTypeInfo(Transaction transaction) {
    final isIncome = transaction.type == 1;

    return {
      'text': isIncome ? 'Top-up' : 'Charging',
      'prefix': isIncome ? '+' : '-',
      'color': isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
      'icon': isIncome ? 'assets/icons/icon_ev_topUpOk.png' : 'assets/icons/icon_ev_topUpNo.png',
    };
  }

  // Get display amount
  double getDisplayAmount(double? amount) {
    return amount ?? 0.0;
  }

  // Update balance after top-up - Fetch from backend instead
  Future<void> updateBalanceAfterTopUp() async {
    await fetchBalance();
    await refreshData();
  }

  // Update balance after charging - Fetch from backend instead
  Future<void> updateBalanceAfterCharging() async {
    await fetchBalance();
    await refreshData();
  }
}
