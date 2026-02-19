import 'package:cached_network_image/cached_network_image.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_news_feed_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ev_charger_controller.dart';

import '../../../../../utils/app_bar.dart';

class NewsFeedScreen extends GetView<EvChargerController> {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'news_feed'.tr),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          return false;
        },
        child: Obx(() {
          if (controller.state.isLoadingNews && controller.newsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state.hasErrorNews) {
            return _buildErrorState(controller);
          }

          if (controller.newsList.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.refreshNewsFeed();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.newsList.length,
              itemBuilder: (context, index) {
                final item = controller.newsList[index];
                final title = controller.getLocalizedTitle(item);
                final description = controller.getLocalizedDescription(item);
                final date = controller.formatDate(item.created);
                final imageUrl = controller.getFeedImageUrl(
                  item,
                ); // Get full URL

                return _buildNewsItem(
                  imageUrl: imageUrl, // Pass full URL
                  title: title,
                  description: description,
                  date: date,
                  onTap: () {
                    NewsDetailBottomSheet.show(
                      context: context,
                      item: item,
                      controller: controller,
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(EvChargerController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('failed_to_load_news'.tr),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshNewsFeed,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rss_feed_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('no_news_available'.tr),
        ],
      ),
    );
  }

  Widget _buildNewsItem({
    required String imageUrl,
    required String title,
    required String description,
    required String date,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (_, __) => Container(
                      color: Colors.grey[200],
                      height: 180,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailBottomSheet {
  static void show({
    required BuildContext context,
    required EvNewsFeedDatum item,
    required EvChargerController controller,
  }) {
    final title = controller.getLocalizedTitle(item);
    final description = controller.getLocalizedDescription(item);
    final date = controller.formatDate(item.created);
    final imageUrl = controller.getFeedImageUrl(item);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'news_detail'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (_, __, ___) => Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
