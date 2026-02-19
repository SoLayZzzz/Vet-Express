import 'dart:convert';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_policy_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../base/base_url.dart';
import '../../domain/uscase/ev_charger_usecase.dart';

class EvPolicyController extends GetxController {
  final EvChargerUseCase useCase;

  EvPolicyController(this.useCase);

  var evPolicyResponse = Rxn<EvPolicyResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;

  // HTML content handling
  var htmlContent = ''.obs;
  var isFetchingHtml = false.obs;
  var htmlError = ''.obs;
  var htmlUrl = ''.obs;

  @override
  void onInit() {
    fetchEvPolicy(1, 10);
    super.onInit();
  }

  Future<void> fetchEvPolicy(int page, int rowPerPage) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';
      htmlContent.value = ''; // Clear previous HTML content
      htmlUrl.value = ''; // Clear previous URL

      final response = await useCase.fetchEvPolicy(
        context: Get.context!,
        page: page,
        rowsPerPage: rowPerPage,
      );
      evPolicyResponse.value = response;

      // If we have policy data, fetch the HTML content
      if (policyList.isNotEmpty) {
        await fetchHtmlContent();
      }

      // Update pagination info
      final pagination = response.body?.pagination;
      if (pagination != null) {
        currentPage.value = pagination.page ?? 0;
        hasMore.value =
            (pagination.page ?? 0) * (pagination.rowsPerPage ?? 10) <
            (pagination.total ?? 0);
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
      _showErrorDialog(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchHtmlContent() async {
    try {
      isFetchingHtml(true);
      htmlError.value = '';
      htmlContent.value = '';

      // Get the appropriate HTML URL based on language
      final url = getLocalizedHtmlUrl();

      if (url.isNotEmpty) {
        htmlUrl.value = url;

        // Fetch the HTML content
        final response = await http.get(
          Uri.parse(url),
          headers: {'Content-Type': 'text/html; charset=utf-8'},
        );

        if (response.statusCode == 200) {
          // Try to decode with UTF-8
          htmlContent.value = utf8.decode(response.bodyBytes);
        } else {
          throw Exception(
            'Failed to load HTML content. Status code: ${response.statusCode}',
          );
        }
      } else {
        htmlError.value = 'No HTML URL available for the current language';
      }
    } catch (e) {
      htmlError.value = e.toString();
      print('Error fetching HTML content: $e');

      // If fetching fails, try to show a fallback message
      htmlContent.value = _getFallbackHtmlContent();
    } finally {
      isFetchingHtml(false);
    }
  }

  /// Get the HTML URL based on current language
  String getLocalizedHtmlUrl() {
    if (policyList.isEmpty) return '';

    final policy = policyList.first;
    final locale = Get.locale?.languageCode;

    String? htmlPath;
    switch (locale) {
      case 'km':
        htmlPath = policy.descriptionKh;
        break;
      case 'cn':
        htmlPath = policy.descriptionCh;
        break;
      default:
        htmlPath = policy.descriptionEn;
    }

    // Fallback to English if localized version is not available
    if (htmlPath == null || htmlPath.isEmpty) {
      htmlPath = policy.descriptionEn;
    }

    if (htmlPath == null || htmlPath.isEmpty) {
      return '';
    }

    // Construct full URL (similar to slideshow)
    return _constructFullUrl(htmlPath);
  }

  /// Construct full URL from relative path
  String _constructFullUrl(String relativePath) {
    // Remove leading slash to avoid double slashes
    String cleanPath =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    // BASE_URL_EV already has trailing slash
    return "${BaseUrl.BASE_URL_EV}$cleanPath";
  }

  /// Fallback HTML content if fetching fails
  String _getFallbackHtmlContent() {
    if (policyList.isEmpty) return '';

    final locale = Get.locale?.languageCode;

    String title = "Privacy Policy";
    String content = "The policy content is currently unavailable.";

    switch (locale) {
      case 'km':
        title = "គោលការណ៍ភាពឯកជន";
        content = "មាតិកានៃគោលការណ៍នេះពុំមានស្រាប់នៅពេលនេះទេ។";
        break;
      case 'cn':
        title = "隐私政策";
        content = "政策内容暂时不可用。";
        break;
    }

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            padding: 16px;
            margin: 0;
          }
          h1 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 24px;
          }
          p {
            margin-bottom: 16px;
          }
          .error-message {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 16px;
            margin: 16px 0;
          }
        </style>
      </head>
      <body>
        <h1>$title</h1>
        <div class="error-message">
          <p><strong>⚠️ Note:</strong> $content</p>
          <p>Please try again later or contact support if the issue persists.</p>
        </div>
      </body>
      </html>
    ''';
  }

  void _showErrorDialog(dynamic error) {
    Get.dialog(
      AlertDialog(
        title: Text('error'.tr),
        content: Text(error.toString()),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              refreshData();
            },
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper getters to access Policy info easily
  List<EvPolicyDatum> get policyList =>
      evPolicyResponse.value?.body?.data ?? [];
  bool get hasPolicies => policyList.isNotEmpty;
  String get message => evPolicyResponse.value?.body?.message ?? '';
  bool get status => evPolicyResponse.value?.body?.status ?? false;

  /// Check if HTML content is available
  bool get hasHtmlContent => htmlContent.value.isNotEmpty;

  /// Get HTML loading status
  bool get isHtmlLoading => isFetchingHtml.value;

  /// Get HTML error status
  bool get hasHtmlError => htmlError.value.isNotEmpty;

  /// For backward compatibility - returns HTML URL
  String getLocalizedPolicyContent(EvPolicyDatum policy) {
    final locale = Get.locale?.languageCode;
    String? htmlPath;

    switch (locale) {
      case 'km':
        htmlPath = policy.descriptionKh ?? policy.descriptionEn;
        break;
      case 'cn':
        htmlPath = policy.descriptionCh ?? policy.descriptionEn;
        break;
      default:
        htmlPath = policy.descriptionEn;
    }

    if (htmlPath == null || htmlPath.isEmpty) {
      return '';
    }

    return _constructFullUrl(htmlPath);
  }

  /// Get all policy content URLs (for multiple policies)
  List<String> getAllPolicyUrls() {
    if (policyList.isEmpty) return [];

    final locale = Get.locale?.languageCode;
    List<String> urls = [];

    for (var policy in policyList) {
      String? htmlPath;

      switch (locale) {
        case 'km':
          htmlPath = policy.descriptionKh ?? policy.descriptionEn;
          break;
        case 'cn':
          htmlPath = policy.descriptionCh ?? policy.descriptionEn;
          break;
        default:
          htmlPath = policy.descriptionEn;
      }

      if (htmlPath != null && htmlPath.isNotEmpty) {
        urls.add(_constructFullUrl(htmlPath));
      }
    }

    return urls;
  }

  /// Load more data for pagination
  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      fetchEvPolicy(currentPage.value + 1, 10);
    }
  }

  /// Refresh data (including HTML content)
  void refreshData() {
    fetchEvPolicy(1, 10);
  }

  /// Refresh only HTML content
  void refreshHtmlContent() {
    if (policyList.isNotEmpty) {
      fetchHtmlContent();
    }
  }

  /// Clear all data
  void clearData() {
    evPolicyResponse.value = null;
    currentPage.value = 0;
    hasMore.value = true;
    htmlContent.value = '';
    htmlUrl.value = '';
    htmlError.value = '';
  }

  /// Get current HTML URL for debugging
  String get currentHtmlUrl => htmlUrl.value;

  /// Check if we should show HTML content
  bool get shouldShowHtml {
    return hasHtmlContent && !hasHtmlError && !isHtmlLoading;
  }

  /// Get a summary of the controller state for debugging
  Map<String, dynamic> get debugInfo {
    return {
      'hasPolicies': hasPolicies,
      'policyCount': policyList.length,
      'hasHtmlContent': hasHtmlContent,
      'htmlContentLength': htmlContent.value.length,
      'hasHtmlError': hasHtmlError,
      'htmlError': htmlError.value,
      'isLoading': isLoading.value,
      'isHtmlLoading': isHtmlLoading,
      'currentPage': currentPage.value,
      'hasMore': hasMore.value,
      'htmlUrl': htmlUrl.value,
    };
  }

  /// Print debug info to console
  void printDebugInfo() {
    print('=== EvPolicyController Debug Info ===');
    print(jsonEncode(debugInfo));
    print('====================================');
  }
}
