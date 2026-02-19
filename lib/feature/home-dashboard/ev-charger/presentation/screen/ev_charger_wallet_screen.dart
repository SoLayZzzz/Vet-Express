import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_wallet_list_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../controller/ev_wallet_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import 'ev_top_up_screen.dart';

class EvWalletScreen extends StatelessWidget {
  const EvWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EvWalletController walletController = Get.find<EvWalletController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Loading state (only for initial load)
        if (walletController.isLoading.value &&
            !walletController.hasWalletData) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // 1. The Header (Matches UI, Collapses as you scroll)
            _buildSliverHeader(context, walletController),

            // 2. The Filter Chips (Sticks to top)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                child: Container(
                  color: Colors.white,
                  child: _buildFilterChips(walletController),
                ),
                height: 80.0,
              ),
            ),

            // 3. The Transaction List (Scrollable)
            if (walletController.hasError.value)
              SliverFillRemaining(child: _buildErrorState(walletController))
            else if (!walletController.hasWalletData)
              SliverFillRemaining(child: _buildEmptyState())
            else if (walletController.searchQuery.value.isNotEmpty &&
                walletController
                    .searchTransactions(walletController.searchQuery.value)
                    .isEmpty)
              SliverFillRemaining(child: _buildNoResultsState(walletController))
            else
              _buildSliverTransactionList(walletController),
          ],
        );
      }),
    );
  }

  // --- 1. HEADER (Matches Screenshot) ---
  Widget _buildSliverHeader(
    BuildContext context,
    EvWalletController walletController,
  ) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: AppColors.whiteColor,
      leading: IconButton(
        icon: const Icon(Ionicons.chevron_back_outline, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'ev_wallet'.tr,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'total_balance'.tr,
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              walletController.isLoadingBalance.value
                  ? const CircularProgressIndicator()
                  : Text(
                    '${walletController.totalBalance.value.toStringAsFixed(2)} KHR',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleColor,
                    ),
                  ),
              const SizedBox(height: 30),
              // Top Up Button
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(
                    () => EvTopUpScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: Constrains.duration),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                icon: Image.asset(
                  "assets/icons/icon_ev_topUp.png",
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  'top_up'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. FILTER CHIPS ---
  Widget _buildFilterChips(EvWalletController walletController) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterChip(
            label: 'all'.tr,
            isSelected: walletController.selectedFilter.value == 'all',
            onSelected: (value) => walletController.applyFilter('all'),
          ),
          _buildFilterChip(
            label: 'income'.tr,
            isSelected: walletController.selectedFilter.value == 'income',
            onSelected: (value) => walletController.applyFilter('income'),
          ),
          _buildFilterChip(
            label: 'expense'.tr,
            isSelected: walletController.selectedFilter.value == 'expense',
            onSelected: (value) => walletController.applyFilter('expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  // --- 3. TRANSACTION LIST ---
  Widget _buildSliverTransactionList(EvWalletController walletController) {
    final transactionsToShow =
        walletController.searchQuery.value.isEmpty
            ? walletController.getGroupedTransactions()
            : walletController.searchTransactions(
              walletController.searchQuery.value,
            );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == transactionsToShow.length) {
            // Load more indicator
            if (walletController.hasMoreData.value &&
                !walletController.isLoading.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                walletController.loadMoreData();
              });
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox(height: 50);
          }

          final group = transactionsToShow[index];
          return _buildDayTransactionSection(group, walletController);
        },
        childCount:
            transactionsToShow.length +
            (walletController.hasMoreData.value ? 1 : 0),
      ),
    );
  }

  Widget _buildDayTransactionSection(
    Group group,
    EvWalletController walletController,
  ) {
    if (group.transactions == null || group.transactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            walletController.formatDate(group.date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Column(
          children:
              group.transactions!
                  .map(
                    (transaction) =>
                        _buildTransactionItem(transaction, walletController),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransactionItem(
    Transaction transaction,
    EvWalletController walletController,
  ) {
    final typeInfo = walletController.getTransactionTypeInfo(transaction);
    final displayAmount = walletController.getDisplayAmount(transaction.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeInfo['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(typeInfo['icon'], width: 28, height: 28),
          ),
          const SizedBox(width: 16),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'unknown_transaction'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (transaction.createdDate != null &&
                    transaction.createdDate!.isNotEmpty)
                  Text(
                    '${transaction.createdDate}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Amount and Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${typeInfo['prefix']}${displayAmount.toStringAsFixed(2)} KHR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: typeInfo['color'],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  typeInfo['text'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: typeInfo['color'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ERROR STATE ---
  Widget _buildErrorState(EvWalletController walletController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'failed_to_load_transactions'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              walletController.errorMessage.value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: walletController.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'no_transactions'.tr,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.to(() => EvTopUpScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('make_first_transaction'.tr),
          ),
        ],
      ),
    );
  }

  // --- NO RESULTS STATE ---
  Widget _buildNoResultsState(EvWalletController walletController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_transactions_found'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: walletController.clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('clear_filters'.tr),
          ),
        ],
      ),
    );
  }
}

// --- STICKY HEADER DELEGATE ---
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyFilterDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
