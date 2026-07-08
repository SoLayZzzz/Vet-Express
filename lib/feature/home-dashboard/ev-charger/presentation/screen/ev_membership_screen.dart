import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_info_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/controller/ev_charger_controller.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_wallet_list_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class EvMembershipScreen extends StatefulWidget {
  const EvMembershipScreen({super.key});

  @override
  State<EvMembershipScreen> createState() => _EvMembershipScreenState();
}

class _EvMembershipScreenState extends State<EvMembershipScreen> {
  String _section = 'menu';
  String _selectedFilter = 'all';
  Data? _membershipInfo;

  final EvChargerController _evController = Get.find<EvChargerController>();

  int _apiTypeFromFilter() {
    if (_selectedFilter == 'income') return 1;
    if (_selectedFilter == 'expense') return 2;
    return 0;
  }

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args is Map && args['section'] is String) {
      _section = args['section'] as String;
    }

    if (args is Map && args['membershipInfo'] is Data) {
      _membershipInfo = args['membershipInfo'] as Data;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_section == 'history') {
        _evController.fetchMembershipTransactionList(type: _apiTypeFromFilter());
      }
    });
  }

  List<Group> get _staticGroups {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return [
      Group(
        date: DateFormat('yyyy-MM-dd').format(today),
        transactions: [
          Transaction(
            id: 1,
            type: 1,
            description: 'Top-up',
            amount: 50,
            createdDate: DateFormat('dd MMM yyyy, h:mm a').format(now),
          ),
          Transaction(
            id: 2,
            type: 2,
            description: 'Station 1',
            amount: 2000,
            createdDate: DateFormat('dd MMM yyyy, h:mm a').format(now),
          ),
        ],
      ),
      Group(
        date: DateFormat('yyyy-MM-dd').format(yesterday),
        transactions: [
          Transaction(
            id: 3,
            type: 2,
            description: 'Station 1',
            amount: 2000,
            createdDate: DateFormat('dd MMM yyyy, h:mm a').format(
              yesterday.add(const Duration(hours: 16)),
            ),
          ),
        ],
      ),
    ];
  }

  List<Group> get _filteredGroups {
    if (_selectedFilter == 'all') return _staticGroups;

    final int type = _selectedFilter == 'income' ? 1 : 2;
    final List<Group> result = [];

    for (final group in _staticGroups) {
      final transactions = group.transactions;
      if (transactions == null || transactions.isEmpty) continue;

      final filtered = transactions.where((t) => t.type == type).toList();
      if (filtered.isEmpty) continue;

      result.add(Group(date: group.date, transactions: filtered));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),

          if (_section == 'menu')
            SliverToBoxAdapter(child: _buildMenuOptions())
          else ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                height: 70.0,
                child: Container(
                  color: Colors.white,
                  child: _buildFilterChips(),
                ),
              ),
            ),
            _buildSliverTransactionList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMemberOptions(
          onTap: () => Get.toNamed(AppRoutes.evMembershipBenefit),
          iconPath: AssetImages.ic_membership,
          title: 'membership_benefit'.tr,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, color: Colors.black),
        ),
        _buildMemberOptions(
          onTap: () {
            setState(() => _section = 'history');
            _evController.fetchMembershipTransactionList(
              type: _apiTypeFromFilter(),
            );
          },
          iconPath: AssetImages.ic_history_membership,
          title: 'history'.tr,
        ),
      ],
    );
  }

  Widget _buildMemberOptions({
    required VoidCallback onTap,
    required String iconPath,
    required String title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(iconPath),
                const SizedBox(width: 15),
                Text(title),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterChip(
            label: 'all'.tr,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() => _selectedFilter = 'all');
              _evController.fetchMembershipTransactionList(
                type: _apiTypeFromFilter(),
              );
            },
          ),
          _buildFilterChip(
            label: 'earned'.tr,
            isSelected: _selectedFilter == 'income',
            onTap: () {
              setState(() => _selectedFilter = 'income');
              _evController.fetchMembershipTransactionList(
                type: _apiTypeFromFilter(),
              );
            },
          ),
          _buildFilterChip(
            label: 'spend'.tr,
            isSelected: _selectedFilter == 'expense',
            onTap: () {
              setState(() => _selectedFilter = 'expense');
              _evController.fetchMembershipTransactionList(
                type: _apiTypeFromFilter(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 34,
      width: 105,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverTransactionList() {
    return Obx(() {
      if (_evController.state.hasErrorMembershipTransactionList) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => _evController.fetchMembershipTransactionList(
                  type: _apiTypeFromFilter(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text('retry'.tr),
              ),
            ),
          ),
        );
      }

      if (_evController.state.isLoadingMembershipTransactionList &&
          _evController.state.membershipTransactionGroups.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final transactionsToShow = _evController.state.membershipTransactionGroups;
      if (transactionsToShow.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('no_data'.tr)),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == transactionsToShow.length) {
              if (_evController.state.membershipTransactionHasMore &&
                  !_evController.state.isLoadingMoreMembershipTransactionList) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _evController.fetchMembershipTransactionList(
                    loadMore: true,
                    type: _apiTypeFromFilter(),
                  );
                });
              }

              if (_evController.state.isLoadingMoreMembershipTransactionList) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }

              return const SizedBox(height: 50);
            }

            final group = transactionsToShow[index];
            return _buildDayTransactionSection(group);
          },
          childCount: transactionsToShow.length + 1,
        ),
      );
    });
  }

  Widget _buildDayTransactionSection(Group group) {
    if (group.transactions == null || group.transactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _formatDate(group.date),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
    final typeInfo = _getPointTypeInfo(transaction);
    final displayAmount = transaction.amount ?? 0.0;

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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: typeInfo['color'],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 24,
                ),
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
                    "${typeInfo['prefix']} ${displayAmount.toStringAsFixed(0)} ${'points'.tr}",
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

    final id = transaction.id;
    if (id == null) return;

    _evController.fetchMembershipTransactionDetail(id: id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (_evController.state.isLoadingMembershipTransactionDetail) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }
        
              if (_evController.state.hasErrorMembershipTransactionDetail) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHeader('transaction_detail'.tr),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () =>
                            _evController.fetchMembershipTransactionDetail(
                          id: id,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text('retry'.tr),
                      ),
                    ),
                  ],
                );
              }
        
              final detail = _evController
                  .state
                  .membershipTransactionDetailResponse
                  ?.body
                  ?.data;
              if (detail == null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSheetHeader('transaction_detail'.tr),
                    const SizedBox(height: 12),
                    Text('no_detail'.tr),
                  ],
                );
              }
        
              final nf = NumberFormat('#,###');
              final isEarned = transaction.type == 1;
        
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSheetHeader('transaction_detail'.tr),
                  const SizedBox(height: 6),
                  _buildSheetRow(
                    left: 'transaction_id'.tr,
                    right: detail.transactionId ?? '-',
                  ),
                  _buildSheetRow(
                    left: 'station_name'.tr,
                    right: detail.stationName ?? '-',
                  ),
                  _buildSheetRow(
                    left: 'order_date'.tr,
                    right: detail.orderDate ?? '-',
                  ),
                  _buildSheetRow(
                    left: 'ev_sub_total'.tr,
                    right: 'KHR (៛) ${nf.format(detail.subTotal ?? 0)}',
                  ),
                  _buildSheetRow(
                    left: "${'discount'.tr} (${detail.discountPercent ?? 0}%)",
                    right:
                        '-KHR (៛) ${nf.format(detail.discountAmount ?? 0)}',
                  ),
                  _buildSheetRow(
                    left: 'total_amount'.tr,
                    right: 'KHR (៛) ${nf.format(detail.totalAmount ?? 0)}',
                    rightStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _buildSheetRow(
                    left: 'total_kwh'.tr,
                    right: '${detail.totalKwh ?? 0} kWh',
                  ),
                  _buildSheetRow(
                    left: isEarned ? 'point_earned'.tr : 'point_spend'.tr,
                    right: isEarned
                        ? "+ ${(transaction.amount ?? 0).toStringAsFixed(0)} ${'points'.tr}"
                        : "- ${detail.pointSpend ?? 0} ${'points'.tr}",
                    rightStyle: TextStyle(
                      color:
                          isEarned
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    showDivider: false,
                  ),
                ],
              );
            }),
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

  Map<String, dynamic> _getPointTypeInfo(Transaction transaction) {
    final isEarned = transaction.type == 1;
    return {
      'prefix': isEarned ? '+' : '-',
      'color': isEarned ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
    };
  }

  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    final date = _parseDateString(dateStr);
    if (date == null) return dateStr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'today'.tr;
    } else if (inputDate == yesterday) {
      return 'yesterday'.tr;
    } else {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  Widget _buildSliverHeader(
    BuildContext context,
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
        'membership'.tr,
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
                    AssetImages.ic_history_background,
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              Positioned(
                left: 20,
                bottom: 50,
                child: Row(
                  children: [
                    PlanCardComponent(
                      current: _membershipInfo?.currentPoint ?? 0,
                      full: _membershipInfo?.requirePoint ?? 0
                    ),
                   const SizedBox(width: 20),
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _membershipInfo?.membershipLevelName ?? "-",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kantumruy Pro',
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Id
                       Text(
                        "ID: ${_membershipInfo?.cardId ?? "-"}",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kantumruy Pro',
                        ),
                      ),
                      //
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "${_membershipInfo?.currentPoint ?? 0} ${'points'.tr} ",
                              style: TextStyle(color: Colors.green, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'will_expire_in'.tr,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: " ${_membershipInfo?.expiringInDays ?? 0} ${'days'.tr}",
                                  style: TextStyle(color: Colors.green, fontSize: 14),
                                ),
                              ],
                      ))
                    ],
                   )])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

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
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}


class PlanCardComponent extends StatefulWidget {
  final int current;
  final int full;

  const PlanCardComponent({
    super.key,
    this.current = 190,
    this.full = 500,
  });

  @override
  State<PlanCardComponent> createState() => _PlanCardComponentState();
}

class RadialPainter extends CustomPainter {
  double progressInDegrees;

  RadialPainter(this.progressInDegrees);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.lightPrimaryColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);

    Paint progressPaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(progressInDegrees),
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _PlanCardComponentState extends State<PlanCardComponent>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _radialProgressAnimationController;
  late Animation<double> _progressAnimation;
  final Duration fadeInDuration = const Duration(milliseconds: 500);
  final Duration fillDuration = const Duration(seconds: 2);
  double progressDegrees = 0;
  double goalCompleted = 0;
  var count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
        CustomPaint(
          painter: RadialPainter(progressDegrees),
          child: Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: fadeInDuration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.current.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: const Divider(height: 2, thickness: 1.5, color: Colors.black),
                  ),
                  Text(widget.full.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyColor,
                          )),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    goalCompleted = widget.full <= 0
        ? 0
        : (widget.current / widget.full).clamp(0.0, 1.0);
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: fillDuration);
    _progressAnimation =
        Tween(begin: 0.0, end: 360.0).animate(CurvedAnimation(
        parent: _radialProgressAnimationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {
          progressDegrees = goalCompleted * _progressAnimation.value;
        });
      });

    _radialProgressAnimationController.forward();
  }

  @override
  void didUpdateWidget(covariant PlanCardComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.full != widget.full) {
      goalCompleted = widget.full <= 0
          ? 0
          : (widget.current / widget.full).clamp(0.0, 1.0);
      _radialProgressAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _radialProgressAnimationController.dispose();
    super.dispose();
  }
}
