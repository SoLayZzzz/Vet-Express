import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import '../controller/ev_policy_controller.dart';

class EvPolicyScreen extends GetView<EvPolicyController> {
  const EvPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'privacy_policy'.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.policyList.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.policyList.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPolicyContent();
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
            'failed_to_load_policy'.tr,
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
          const Icon(Icons.privacy_tip_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_policy_available'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // HTML Content Section
              Obx(() {
                if (controller.isFetchingHtml.value) {
                  return _buildHtmlLoading();
                }

                if (controller.htmlError.value.isNotEmpty) {
                  return _buildHtmlError();
                }

                if (controller.htmlContent.value.isEmpty) {
                  return _buildNoHtmlContent();
                }

                return _buildHtmlContent();
              }),

              // Load more button (if applicable)
              if (controller.hasMore.value && !controller.isLoading.value)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: controller.loadMore,
                      child: Text('load_more'.tr),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHtmlLoading() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildHtmlError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'failed_to_load_html'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.fetchHtmlContent,
          child: Text('retry'.tr),
        ),
      ],
    );
  }

  Widget _buildNoHtmlContent() {
    return Column(
      children: [
        const Icon(Icons.description, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'no_content_available'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHtmlContent() {
    return Html(
      data: controller.htmlContent.value,
      style: {
        'body': Style(
          margin: Margins.zero,
          fontSize: FontSize(14.0),
          lineHeight: const LineHeight(1.6),
          color: Colors.black87,
        ),
        'h1': Style(
          fontSize: FontSize(20.0),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 12),
        ),
        'h2': Style(
          fontSize: FontSize(18.0),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 10),
        ),
        'h3': Style(
          fontSize: FontSize(16.0),
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
        ),
        'p': Style(margin: Margins.only(bottom: 8)),
        'ul': Style(margin: Margins.only(bottom: 8)),
        'li': Style(margin: Margins.only(bottom: 4)),
      },
    );
  }
}
