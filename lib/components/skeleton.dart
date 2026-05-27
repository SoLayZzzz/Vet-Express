import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';


// =============================
// Destination
// =============================
class SkeletonLoadingList extends StatelessWidget {
  final int itemCount;

  const SkeletonLoadingList({
    super.key, 
    this.itemCount = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

// =============================
// Schedule
// =============================

class ScheduleSkeleton extends StatelessWidget {
  const ScheduleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double? width, required double height, double radius = 4}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget scheduleCardSkeleton() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 0.2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 30, height: 30, radius: 6),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            box(width: double.infinity, height: 14),
                            const SizedBox(height: 8),
                            box(width: 180, height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      box(width: 70, height: 14),
                    ],
                  ),
                  const SizedBox(height: 20),
                  box(width: double.infinity, height: 14),
               
                  const SizedBox(height: 5),
                ],
              ),
            ),
            SizedBox(
              height: 10,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 80, height: 14),
                      const SizedBox(height: 4),
                      box(width: 60, height: 12),
                    ],
                  ),
                  box(width: 60, height: 14),
                 
                  box(width: 70, height: 16),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                box(width: 24, height: 24, radius: 6),
                const SizedBox(width: 10),
                box(width: 180, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) => scheduleCardSkeleton(),
          ),
        ],
      ),
    );
  }

}

// =============================
// Seat
// =============================

class SeatSkeleton extends StatelessWidget {
  const SeatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({
      double? width,
      required double height,
      double radius = 4,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final availableWidth = maxWidth;

        const columns = 4;
        double imageSize = availableWidth / columns;
        imageSize = imageSize.clamp(24.0, 44.0);
        final childAspectRatio = (1 / (imageSize > 30 ? 1.2 : 2));

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: availableWidth),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              children: List.generate(48, (index) {
                final row = index ~/ columns;
                final col = index % columns;

                final bool gap = (row % 4 == 1) && (col == 1);
                if (gap) return const SizedBox.shrink();
                return Center(
                  child: box(width: imageSize * 0.9, height: imageSize, radius: 10),
                );
              }),
            ),
          ),
        );
      },
    );
  }
  
}

// =============================
// Passenger
// =============================

class PassengerSkeleton extends StatelessWidget {
  const PassengerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({
      double? width,
      required double height,
      double radius = 6,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget section({required Widget child, double top = 15}) {
      return Container(
        margin: EdgeInsets.only(top: top),
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: child,
      );
    }

    Widget fieldRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: box(width: double.infinity, height: 12, radius: 4),
          ),
          const SizedBox(width: 50),
          Expanded(
            flex: 7,
            child: box(width: double.infinity, height: 44, radius: 10),
          ),
        ],
      );
    }

    Widget passengerItem() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              box(width: 150, height: 12, radius: 4),
              box(width: 50, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 15),
         
          box(width: double.infinity, height: 100, radius: 9),
          const SizedBox(height: 15),
               Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              box(width: 150, height: 12, radius: 4),
              box(width: 50, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 15),
         
          box(width: double.infinity, height: 100, radius: 9),
          const SizedBox(height: 15),
          box(width: 80, height: 12, radius: 4),
          const SizedBox(height: 15),
          box(width: 60, height: 12, radius: 4),
          const SizedBox(height: 15),
          Row(
            children: [
              box(width: 10, height: 10, radius: 10),
              const SizedBox(width: 10),
              box(width: 40, height: 12, radius: 4),
              const SizedBox(width: 10),
              box(width: 10, height: 10, radius: 10),
              const SizedBox(width: 10),
              box(width: 40, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 15),
          fieldRow(),
          const SizedBox(height: 15),
          box(width: 80, height: 12, radius: 4),
          const SizedBox(height: 15),
          box(width: 60, height: 12, radius: 4),
          const SizedBox(height: 15),
          Row(
            children: [
              box(width: 10, height: 10, radius: 10),
              const SizedBox(width: 10),
              box(width: 40, height: 12, radius: 4),
              const SizedBox(width: 10),
              box(width: 10, height: 10, radius: 10),
              const SizedBox(width: 10),
              box(width: 40, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 15),
          fieldRow(),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: section(
                  top: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 180, height: 14, radius: 4),
                      const SizedBox(height: 20),
                      box(width: double.infinity, height: 48, radius: 12),
                      const SizedBox(height: 10),
                      box(width: double.infinity, height: 48, radius: 12),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 220, height: 14, radius: 4),
                      const SizedBox(height: 20),
                      passengerItem(),
                      const SizedBox(height: 20),
                      box(width: double.infinity, height: 2, radius: 2),
                      const SizedBox(height: 20),
                      passengerItem(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          box(width: 110, height: 14, radius: 4),
                          box(width: 70, height: 14, radius: 4),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          box(width: 140, height: 12, radius: 4),
                          box(width: 80, height: 12, radius: 4),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          box(width: 160, height: 12, radius: 4),
                          box(width: 70, height: 12, radius: 4),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          box(width: 120, height: 12, radius: 4),
                          box(width: 90, height: 12, radius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: box(width: double.infinity, height: 48, radius: 12),
        ),
      ],
    );
  }

  
}

// =============================
// EV
// =============================

class EVSkeleton extends StatelessWidget {
  const EVSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({
      double? width,
      required double height,
      double radius = 12,
      EdgeInsetsGeometry? margin,
    }) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget newsItem() {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            box(width: 80, height: 80, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  box(width: double.infinity, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  box(width: 160, height: 12, radius: 4),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                box(width: double.infinity, height: 180, radius: 12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      box(width: 120, height: 14, radius: 4),
                      box(width: 16, height: 16, radius: 4),
                    ],
                  ),
                  const SizedBox(height: 10),
                  box(width: 200, height: 28, radius: 6),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: box(width: 120, height: 40, radius: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: box(width: double.infinity, height: 72, radius: 12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: box(width: double.infinity, height: 72, radius: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    box(width: 120, height: 18, radius: 4),
                    box(width: 80, height: 18, radius: 4),
                  ],
                ),
                const SizedBox(height: 12),
                newsItem(),
                newsItem(),
                newsItem(),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

// =============================
// EV Wallet
// =============================

class EvWalletSkeleton extends StatelessWidget {
  const EvWalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({
      double? width,
      required double height,
      double radius = 12,
      EdgeInsetsGeometry? margin,
    }) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget transactionItem() {
      return Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey, width: 0.15),
        ),
        child: Row(
          children: [
            box(width: 44, height: 44, radius: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  box(width: 140, height: 12, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                box(width: 90, height: 14, radius: 4),
                const SizedBox(height: 8),
                box(width: 50, height: 14, radius: 10),
              ],
            ),
          ],
        ),
      );
    }

    Widget dayHeader() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: box(width: 120, height: 12, radius: 4),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      box(width: 40, height: 40, radius: 20),
                      const Spacer(),
                      box(width: 120, height: 16, radius: 6),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 50),
                  box(width: 140, height: 14, radius: 6),
                  const SizedBox(height: 10),
                  box(width: 220, height: 30, radius: 8),
                  const SizedBox(height: 30),
                  box(width: 160, height: 42, radius: 21),
                ],
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _EvWalletStickyHeaderDelegate(
            height: 80,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  box(width: 80, height: 32, radius: 16),
                  box(width: 80, height: 32, radius: 16),
                  box(width: 80, height: 32, radius: 16),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dayHeader(),
              transactionItem(),
              transactionItem(),
              const SizedBox(height: 16),
              dayHeader(),
              transactionItem(),
              transactionItem(),
              transactionItem(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _EvWalletStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const _EvWalletStickyHeaderDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _EvWalletStickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

// =============================
// Travel Package
// =============================

class PackageListContentSkeleton extends StatelessWidget {
  const PackageListContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double? width, required double height, double radius = 4}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(width: 220, height: 16),
        const SizedBox(height: 10),
        box(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        box(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        box(width: 200, height: 14),
      ],
    );
  }

  @Preview()
  static Widget preview() => const PackageListContentSkeleton();
}

class PackageListItemsSkeleton extends StatelessWidget {
  const PackageListItemsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double? width, required double height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget card() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 140, height: 130, radius: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(width: double.infinity, height: 14, radius: 4),
                        const SizedBox(height: 10),
                        box(width: double.infinity, height: 12, radius: 4),
                        const SizedBox(height: 6),
                        box(width: double.infinity, height: 12, radius: 4),
                        const SizedBox(height: 6),
                        box(width: 140, height: 12, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(width: 120, height: 36, radius: 50),
                  box(width: 120, height: 36, radius: 50),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, index) => card(),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }

  @Preview()
  static Widget preview() => const PackageListItemsSkeleton();

}

class PackageInfoSkeleton extends StatelessWidget {
  const PackageInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double? width, required double height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          box(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.26,
            radius: 15,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              box(width: 60, height: 16, radius: 4),
              const SizedBox(width: 10),
              box(width: 80, height: 16, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          box(width: 260, height: 16, radius: 4),
          const SizedBox(height: 12),
          box(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          box(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          box(width: 220, height: 14, radius: 4),
          const SizedBox(height: 16),
          box(width: 140, height: 17, radius: 4),
          const SizedBox(height: 8),
          box(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          box(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          box(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 8),
          box(width: 240, height: 14, radius: 4),
        ],
      ),
    );
  }

  // @Preview()
  // static Widget preview() => const PackageInfoSkeleton();
}