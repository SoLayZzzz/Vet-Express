import 'package:express_vet/asset_image.dart';
import 'package:express_vet/components/skeleton.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_wallet_list_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/ev_wallet_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../routes/app_routes.dart';

class EvWalletScreen extends GetView<EvWalletController> {
  const EvWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Loading state (only for initial load)
        if (controller.isLoading.value && !controller.hasWalletData) {
          return const EvWalletSkeleton();
        }

        return CustomScrollView(
          slivers: [
            // 1. The Header (Matches UI, Collapses as you scroll)
            _buildSliverHeader(context, controller),

            // 2. The Filter Chips (Sticks to top)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                child: Container(
                  color: Colors.white,
                  child: _buildFilterChips(controller),
                ),
                height: 80.0,
              ),
            ),

            // 3. The Transaction List (Scrollable)
            if (controller.hasError.value)
              SliverFillRemaining(child: _buildErrorState(controller))
            else if (!controller.hasWalletData)
              SliverFillRemaining(child: _buildEmptyState())
            else if (controller.searchQuery.value.isNotEmpty &&
                controller
                    .searchTransactions(controller.searchQuery.value)
                    .isEmpty)
              SliverFillRemaining(child: _buildNoResultsState(controller))
            else
              _buildSliverTransactionList(controller),
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
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 4,
                bottom: -2,
                child: Opacity(
                  opacity: 0.70,
                  child: SvgPicture.asset(
                    AssetImages.ic_money_backgroound,
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'total_balance'.tr,
                    style: TextStyle(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 160),
                    child: const Divider(height: 3,color: Colors.black,),
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
                ],
              ),
               _buildTopUpButton(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopUpButton() {
    return Padding(
               padding: const EdgeInsets.only(bottom: 20),
               child: Align(
                 alignment: Alignment.bottomCenter,
                 child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.evTopUp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      icon: Image.asset(AssetImages.ic_topUp, width: 20, height: 20),
                      label: Text(
                        'top_up'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
               ),
             );
  }

  // --- 2. FILTER CHIPS ---
  Widget _buildFilterChips(EvWalletController walletController) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return SizedBox(
      height: 30,
      width: 100,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => onSelected(true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.lightPrimaryColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
             
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Kantumruy Pro',
                color: isSelected ? AppColors.primaryColor : Colors.black54,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTransactionBottomSheet(transaction),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(typeInfo['icon'], width: 40, height: 40),
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
                    '${typeInfo['prefix']} ${displayAmount.toStringAsFixed(2)} KHR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: typeInfo['color'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTransactionBottomSheet(Transaction transaction) {
    final context = Get.context;
    if (context == null) return;

    final isTopUp = transaction.type == 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  isTopUp
                      ? _buildTopUpDetailSheet(transaction)
                      : _buildSpendDetailSheet(transaction),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetHeader(String title) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetRow({
    required String left,
    required String right,
    TextStyle? rightStyle,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left,
                style: const TextStyle(
                  color: Color(0xFF8B90A0),
                  fontSize: 16,
                ),
              ),
              Flexible(
                child: Text(
                  right,
                  textAlign: TextAlign.right,
                  style:
                      rightStyle ??
                      const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE8EAF1)),
      ],
    );
  }

  Widget _buildTopUpDetailSheet(Transaction transaction) {
    final amount = (transaction.amount ?? 0).toStringAsFixed(2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSheetHeader('Top-up Detail'),
        const SizedBox(height: 6),
        _buildSheetRow(
          left: 'Date',
          right: transaction.createdDate ?? '-',
        ),
        _buildSheetRow(
          left: 'Amont',
          right: '$amount KHR',
        ),
        _buildSheetRow(
          left: 'Top-up',
          right: '+ $amount KHR',
          rightStyle: const TextStyle(
            color: Color(0xFF16A34A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSpendDetailSheet(Transaction transaction) {
    final amount = (transaction.amount ?? 0).toStringAsFixed(2);
    final id = (transaction.id ?? 0).toString().padLeft(5, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSheetHeader('Transaction Detail'),
        const SizedBox(height: 6),
        _buildSheetRow(left: 'Transaction id', right: id),
        _buildSheetRow(
          left: 'Station Name',
          right: transaction.description ?? '-',
        ),
        _buildSheetRow(
          left: 'Order Date',
          right: transaction.createdDate ?? '-',
        ),
        _buildSheetRow(left: 'Total Amount', right: '$amount KHR'),
        _buildSheetRow(
          left: 'Amount',
          right: '- $amount KHR',
          rightStyle: const TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          showDivider: false,
        ),
      ],
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
            onPressed: () => Get.toNamed(AppRoutes.evTopUp),
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
