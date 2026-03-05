import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ev_faq_controller.dart';

class EvFaqScreen extends GetView<EvFaqController> {
  const EvFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarVET().appBar(context, 'faq'.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.faqList.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.faqList.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFaqList();
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'failed_to_load_faq'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshData,
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
          const Icon(Icons.help_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_faq_available'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ...controller.faqList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;
                  return _buildExpansionItem(
                    title: controller.getLocalizedQuestion(faq),
                    content: controller.getLocalizedAnswer(faq),
                    isInitiallyExpanded:
                        index == 0, // First item expanded by default
                  );
                }),

                // Load more indicator
                if (controller.isLoading.value && controller.faqList.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),

        // Load more button
        if (controller.hasMore.value && !controller.isLoading.value)
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.loadMore,
              child: Text('load_more'.tr),
            ),
          ),
      ],
    );
  }

  Widget _buildExpansionItem({
    required String title,
    required String content,
    bool isInitiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: isInitiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconColor: Colors.black87,
            collapsedIconColor: Colors.black87,
            children: [_buildAnswerContainer(content: content)],
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _buildAnswerContainer({required String content}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F4F8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}
