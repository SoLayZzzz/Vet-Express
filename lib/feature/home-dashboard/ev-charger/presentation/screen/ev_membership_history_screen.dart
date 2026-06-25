import 'package:express_vet/asset_image.dart';
import 'package:express_vet/components/skeleton.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_wallet_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/controller/ev_wallet_controller.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EvMembershipHistoryScreen extends GetView<EvWalletController> {
  const EvMembershipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          if (controller.isLoading.value && !controller.hasWalletData) {
            return const EvWalletSkeleton();
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    backgroundColor: AppColors.whiteColor,
                    leading: IconButton(
                      icon: const Icon(
                        Ionicons.chevron_back_outline,
                        color: Colors.black,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    title: const Text(
                      'History',
                      style: TextStyle(
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
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
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
                                const SizedBox(height: 55),
                                Text(
                                  'total_balance'.tr,
                                  style: TextStyle(
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 160,
                                  ),
                                  child: const Divider(
                                    height: 3,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                controller.isLoadingBalance.value
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        '${controller.totalBalance.value.toStringAsFixed(2)} KHR',
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
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Container(
                        color: Colors.white,
                        child: TabBar(
                          indicatorColor: AppColors.primaryColor,
                          labelColor: AppColors.primaryColor,
                          unselectedLabelColor: Colors.black54,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Top-up'),
                            Tab(text: 'Charging'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _TransactionTab(type: 1),
                _TransactionTab(type: 2),
              ],
            ),
          );
        }),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
}

class _TransactionTab extends GetView<EvWalletController> {
  const _TransactionTab({required this.type});

  final int type;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value) {
        return _buildErrorState();
      }

      if (!controller.hasWalletData) {
        return _buildEmptyState();
      }

      final groups = _filterGroupsByType(controller.walletTransactions, type);

      if (groups.isEmpty) {
        return _buildEmptyState();
      }

      return CustomScrollView(
        key: PageStorageKey<String>('membership-history-$type'),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == groups.length) {
                  if (controller.hasMoreData.value &&
                      !controller.isLoading.value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.loadMoreData();
                    });
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox(height: 50);
                }

                final group = groups[index];
                return _buildDayTransactionSection(group);
              },
              childCount:
                  groups.length + (controller.hasMoreData.value ? 1 : 0),
            ),
          ),
        ],
      );
    });
  }

  List<Group> _filterGroupsByType(List<Group> source, int type) {
    final List<Group> result = [];

    for (final group in source) {
      final transactions = group.transactions;
      if (transactions == null || transactions.isEmpty) continue;

      final filtered = transactions.where((t) => t.type == type).toList();
      if (filtered.isEmpty) continue;

      result.add(Group(date: group.date, transactions: filtered));
    }

    return result;
  }

  Widget _buildDayTransactionSection(Group group) {
    if (group.transactions == null || group.transactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            controller.formatDate(group.date),
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
                  .map((transaction) => _buildTransactionItem(transaction))
                  .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final typeInfo = controller.getTransactionTypeInfo(transaction);
    final displayAmount = controller.getDisplayAmount(transaction.amount);

    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(typeInfo['icon'], width: 40, height: 40),
          ),
          const SizedBox(width: 16),
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
    );
  }

  Widget _buildErrorState() {
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
              controller.errorMessage.value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.refreshData,
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
}
