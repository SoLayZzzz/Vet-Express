import 'dart:developer';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../api/resort.dart';
import '../models/resort/resort_response.dart';
import '../utils/image_cache_service.dart';

class ResortController extends GetxController {
  var isLoading = true.obs;
  var resortList = <ResortBody>[].obs;
  var _hasInitialized = false;

  late Box cacheBox;
  final String cacheKey = 'resortList';

  @override
  void onInit() {
    super.onInit();
    cacheBox = Hive.box('cacheBox');

    if (!_hasInitialized) {
      fetchResorts();
      _hasInitialized = true;
    } else {
      _loadFromCache();
      isLoading(false);
    }
  }

  /// Fetch resorts based on timestamp comparison
  void fetchResorts() async {
    try {
      isLoading(true);

      // STEP 1: Load cached resorts first (instant)
      _loadFromCache();

      // STEP 2: Await precache for cached data before showing
      await _preCacheResortImages();
    } catch (e, stackTrace) {
      log("❌ Error in fetchResorts: $e\nStackTrace: $stackTrace");
    } finally {
      isLoading(false);
    }
  }

  /// Load all data from cache first (instant)
  void _loadFromCache() {
    List<dynamic>? cached = cacheBox.get(cacheKey);

    if (cached != null && cached.isNotEmpty) {
      List<ResortBody> cachedList =
          cached.map((e) => ResortBody.fromJson(Map<String, dynamic>.from(e))).toList();
      resortList.assignAll(cachedList);
      log("✅ Resorts loaded from cache (${cachedList.length} items)");
    } else {
      _fetchFromServer();
      log("🔄 No cache found, will fetch from API");
    }
  }

  /// Fetch resorts from server and cache
  Future<void> _fetchFromServer() async {
    try {
      final response = await Resort().getResortList(Get.context);

      if (response.header != null &&
          response.header!.statusCode == 200 &&
          response.header!.result == true) {
        final newResorts = response.body ?? [];
        final imageUrls =
            newResorts
                .where((resort) => resort.photo != null && resort.photo!.isNotEmpty)
                .map((resort) => resort.photo!)
                .toList();

        if (imageUrls.isNotEmpty) {
          await ImageCacheService.preCacheAllImages(imageUrls);
          await ImageCacheService.precacheToMemory(imageUrls, Get.context!);
        }

        await cacheBox.put(cacheKey, newResorts.map((e) => e.toJson()).toList());
        resortList.assignAll(newResorts);

        await cacheBox.put('modifiedResort', DateTime.now().millisecondsSinceEpoch ~/ 1000);

        log("✅ Resorts fetched and cached (${newResorts.length} items)");
      } else {
        log("❌ API returned error: ${response.header?.statusCode}");
      }
    } catch (e, stackTrace) {
      log("❌ Resort fetch failed: $e\nStackTrace: $stackTrace");
    }
  }

  /// Pre-cache all resort images
  Future<void> _preCacheResortImages() async {
    final imageUrls =
        resortList
            .where((resort) => resort.photo != null && resort.photo!.isNotEmpty)
            .map((resort) => resort.photo!)
            .toList();

    if (imageUrls.isNotEmpty) {
      await ImageCacheService.preCacheAllImages(imageUrls);
      await ImageCacheService.precacheToMemory(imageUrls, Get.context!);
      log("🖼️ Pre-cached ${imageUrls.length} resort images");
    }
  }
}
