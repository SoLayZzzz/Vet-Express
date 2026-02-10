// import 'package:express_vet/utils/app_bar.dart';
// import 'package:express_vet/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../controller/ev/ev_policy_controller.dart';
//
// class EvPolicyScreen extends StatelessWidget {
//   EvPolicyScreen({super.key});
//
//   final EvPolicyController policyController = Get.put(EvPolicyController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBarVET().appBar(context, 'privacy_policy'.tr),
//       body: Obx(() {
//         if (policyController.isLoading.value && policyController.policyList.isEmpty) {
//           return _buildLoadingState();
//         }
//
//         if (policyController.hasError.value) {
//           return _buildErrorState();
//         }
//
//         if (policyController.policyList.isEmpty) {
//           return _buildEmptyState();
//         }
//
//         return _buildPolicyContent();
//       }),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return const Center(child: CircularProgressIndicator());
//   }
//
//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             'failed_to_load_policy'.tr,
//             style: const TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(onPressed: policyController.refreshData, child: Text('retry'.tr)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.privacy_tip_outlined, size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text('no_policy_available'.tr, style: const TextStyle(fontSize: 16, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPolicyContent() {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               Text(
//                 "privacy_policy".tr,
//                 style: TextStyle(
//                   color: AppColors.titleColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // Dynamic policy content from API
//               ...policyController.policyList.map(
//                 (policy) => _buildPolicySection(policyController.getLocalizedPolicyContent(policy)),
//               ),
//
//               // Load more indicator
//               if (policyController.isLoading.value && policyController.policyList.isNotEmpty)
//                 const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//
//               // Load more button
//               if (policyController.hasMore.value && !policyController.isLoading.value)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Center(
//                     child: ElevatedButton(
//                       onPressed: policyController.loadMore,
//                       child: Text('load_more'.tr),
//                     ),
//                   ),
//                 ),
//
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPolicySection(String content) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }

import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart'; // Add this package
import 'package:url_launcher/url_launcher.dart'; // For links in HTML

import '../../controller/ev/ev_policy_controller.dart';

class EvPolicyScreen extends StatelessWidget {
  EvPolicyScreen({super.key});

  final EvPolicyController policyController = Get.put(EvPolicyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'privacy_policy'.tr),
      body: Obx(() {
        if (policyController.isLoading.value && policyController.policyList.isEmpty) {
          return _buildLoadingState();
        }

        if (policyController.hasError.value) {
          return _buildErrorState();
        }

        if (policyController.policyList.isEmpty) {
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
          ElevatedButton(onPressed: policyController.refreshData, child: Text('retry'.tr)),
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
          Text('no_policy_available'.tr, style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
                if (policyController.isFetchingHtml.value) {
                  return _buildHtmlLoading();
                }

                if (policyController.htmlError.value.isNotEmpty) {
                  return _buildHtmlError();
                }

                if (policyController.htmlContent.value.isEmpty) {
                  return _buildNoHtmlContent();
                }

                return _buildHtmlContent();
              }),

              // Load more button (if applicable)
              if (policyController.hasMore.value && !policyController.isLoading.value)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: policyController.loadMore,
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
        Text('failed_to_load_html'.tr, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: policyController.fetchHtmlContent, child: Text('retry'.tr)),
      ],
    );
  }

  Widget _buildNoHtmlContent() {
    return Column(
      children: [
        const Icon(Icons.description, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        Text('no_content_available'.tr, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildHtmlContent() {
    return Html(
      data: policyController.htmlContent.value,
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


  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('error'.tr, 'cannot_launch_url'.tr);
    }
  }
}
