import 'dart:developer';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../base/base_url.dart';
import '../../api/slide_show.dart';
import '../utils/image_cache_service.dart';

class SlideController extends GetxController {
  var imgList = <String>[].obs;
  var imgListBus = <String>[].obs;
  var imgListBoat = <String>[].obs;
  var isLoading = true.obs;
  var currentIndex = 0.obs;
  var _hasInitialized = false;

  late Box cacheBox;

  // Cache keys
  final String cacheKeyImgList = 'slideShow';
  final String cacheKeyImgListBus = 'slideBus';
  final String cacheKeyImgListBoat = 'slideBoat';

  @override
  void onInit() {
    super.onInit();
    cacheBox = Hive.box('cacheBox');

    if (!_hasInitialized) {
      fetchSlides();
      _hasInitialized = true;
    } else {
      _loadFromCache();
      isLoading(false);
    }
  }

  Future<void> fetchSlides() async {
    try {
      isLoading(true);

      // STEP 1: Load from cache first (instant)
      _loadFromCache();

      // STEP 2: Await precache for cached data before showing
      await _preCacheAllImages();

      // STEP 3: Fetch from server only if cache is outdated or missing
      await _fetchIfNeeded();
    } catch (e, stackTrace) {
      log("Error fetching slides: $e\nStackTrace: $stackTrace");
    } finally {
      isLoading(false);
    }
  }

  /// Load all data from cache first (instant)
  void _loadFromCache() {
    // Load SlideShow from cache
    List<dynamic>? cachedSlideShow = cacheBox.get(cacheKeyImgList);
    if (cachedSlideShow != null && cachedSlideShow.isNotEmpty) {
      imgList.assignAll(cachedSlideShow.cast<String>());
      log("✅ SlideShow loaded from cache (${imgList.length} items)");
    }

    // Load SlideBus from cache
    List<dynamic>? cachedSlideBus = cacheBox.get(cacheKeyImgListBus);
    if (cachedSlideBus != null && cachedSlideBus.isNotEmpty) {
      imgListBus.assignAll(cachedSlideBus.cast<String>());
      log("✅ SlideBus loaded from cache (${imgListBus.length} items)");
    }

    // Load SlideBoat from cache
    List<dynamic>? cachedSlideBoat = cacheBox.get(cacheKeyImgListBoat);
    if (cachedSlideBoat != null && cachedSlideBoat.isNotEmpty) {
      imgListBoat.assignAll(cachedSlideBoat.cast<String>());
      log("✅ SlideBoat loaded from cache (${imgListBoat.length} items)");
    }
  }

  /// Fetch data from server only if cache is outdated or missing
  Future<void> _fetchIfNeeded() async {
    // Check SlideShow
    int localModifiedSlideShow = cacheBox.get(
      'modifiedSlideShow',
      defaultValue: 0,
    );
    if (localModifiedSlideShow == 0 || cacheBox.get(cacheKeyImgList) == null) {
      await _fetchSlideShow();
    } else {
      log("✅ SlideShow cache is up-to-date, no need to fetch");
    }

    // Check SlideBus
    int localModifiedSlideBus = cacheBox.get(
      'modifiedSlideBus',
      defaultValue: 0,
    );
    if (localModifiedSlideBus == 0 ||
        cacheBox.get(cacheKeyImgListBus) == null) {
      await _fetchSlideBus();
    } else {
      log("✅ SlideBus cache is up-to-date, no need to fetch");
    }

    // Check SlideBoat
    int localModifiedSlideBoat = cacheBox.get(
      'modifiedSlideBoat',
      defaultValue: 0,
    );
    if (localModifiedSlideBoat == 0 ||
        cacheBox.get(cacheKeyImgListBoat) == null) {
      await _fetchSlideBoat();
    } else {
      log("✅ SlideBoat cache is up-to-date, no need to fetch");
    }
  }

  /// Fetch SlideShow from server
  Future<void> _fetchSlideShow() async {
    try {
      final data = await SlideShow().slideShowMenu(Get.context, 1, 1, 100);

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        final List<String> slides =
            data.body?.data
                ?.where((e) => e.image != null)
                .map((e) => BaseUrl.BASE_URL_SLIDE_IMAGE + e.image!)
                .toList() ??
            [];

        if (slides.isNotEmpty) {
          await ImageCacheService.preCacheAllImages(slides);
          await ImageCacheService.precacheToMemory(slides, Get.context!);
          await cacheBox.put(cacheKeyImgList, slides);
          imgList.assignAll(slides);
          await cacheBox.put(
            'modifiedSlideShow',
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );

          log("✅ SlideShow fetched and cached (${slides.length} items)");
        }
      } else {
        log("❌ SlideShow API returned error: ${data.header?.statusCode}");
      }
    } catch (e, stackTrace) {
      log("❌ SlideShow fetch failed: $e\nStackTrace: $stackTrace");
    }
  }

  /// Fetch SlideBus from server
  Future<void> _fetchSlideBus() async {
    try {
      final data = await SlideShow().slideBus(Get.context, 1, 1, 100);

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        final List<String> slides =
            data.body?.data
                ?.where((e) => e.image != null)
                .map((e) => BaseUrl.BASE_URL_SLIDE_IMAGE + e.image!)
                .toList() ??
            [];

        if (slides.isNotEmpty) {
          await ImageCacheService.preCacheAllImages(slides);
          await ImageCacheService.precacheToMemory(slides, Get.context!);
          await cacheBox.put(cacheKeyImgListBus, slides);
          imgListBus.assignAll(slides);
          await cacheBox.put(
            'modifiedSlideBus',
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );

          log("✅ SlideBus fetched and cached (${slides.length} items)");
        }
      } else {
        log("❌ SlideBus API returned error: ${data.header?.statusCode}");
      }
    } catch (e, stackTrace) {
      log("❌ SlideBus fetch failed: $e\nStackTrace: $stackTrace");
    }
  }

  /// Fetch SlideBoat from server
  Future<void> _fetchSlideBoat() async {
    try {
      final data = await SlideShow().slideBuvaSea(Get.context, 1, 1, 100);

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        final List<String> slides =
            data.body?.data
                ?.where((e) => e.image != null)
                .map((e) => BaseUrl.BASE_URL_SLIDE_IMAGE + e.image!)
                .toList() ??
            [];

        if (slides.isNotEmpty) {
          await ImageCacheService.preCacheAllImages(slides);
          await ImageCacheService.precacheToMemory(slides, Get.context!);
          await cacheBox.put(cacheKeyImgListBoat, slides);
          imgListBoat.assignAll(slides);
          await cacheBox.put(
            'modifiedSlideBoat',
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );

          log("✅ SlideBoat fetched and cached (${slides.length} items)");
        }
      } else {
        log("❌ SlideBoat API returned error: ${data.header?.statusCode}");
      }
    } catch (e, stackTrace) {
      log("❌ SlideBoat fetch failed: $e\nStackTrace: $stackTrace");
    }
  }

  /// Pre-cache all images
  Future<void> _preCacheAllImages() async {
    final allImages = [...imgList, ...imgListBus, ...imgListBoat];
    if (allImages.isNotEmpty) {
      await ImageCacheService.preCacheAllImages(allImages);
      await ImageCacheService.precacheToMemory(allImages, Get.context!);
      log("🖼️ Pre-cached ${allImages.length} slide images");
    }
  }
}
