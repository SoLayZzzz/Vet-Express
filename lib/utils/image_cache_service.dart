import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';

class ImageCacheService {
  static final _cacheDir = 'cached_images';
  static final Map<String, String> _memoryCache = {};
  static final Map<String, bool> _preloadedImages = {};
  static final Map<String, Future<String>> _pathFutures = {}; // Shared future cache

  // IMAGE OPTIMIZATION SETTINGS
  static const int _maxWidth = 800;
  static const int _maxHeight = 800;
  static const int _quality = 75;

  /// Get image - returns local path if cached, otherwise downloads and optimizes
  static Future<String> getImage(String imageUrl, [String category = 'default']) {
    final key = '$category::$imageUrl';
    _pathFutures.putIfAbsent(key, () => _getImageInternal(imageUrl, category));
    return _pathFutures[key]!;
  }

  static Future<String> _getImageInternal(String imageUrl, String category) async {
    final key = '$category::$imageUrl';

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final cachedPath = _memoryCache[key]!;
      if (await File(cachedPath).exists()) return cachedPath;
      _memoryCache.remove(key);
    }

    // Check disk cache
    final cachedPath = await _getCachedImagePath(imageUrl, category);
    if (cachedPath != null) {
      _memoryCache[key] = cachedPath;
      return cachedPath;
    }

    // Wait if image is being preloaded
    if (_preloadedImages.containsKey(key)) {
      await Future.delayed(const Duration(milliseconds: 100));
      final preloadedPath = await _getCachedImagePath(imageUrl, category);
      if (preloadedPath != null) {
        _memoryCache[key] = preloadedPath;
        return preloadedPath;
      }
    }

    // Download, optimize, and cache
    final optimizedPath = await _downloadOptimizeAndCacheImage(imageUrl, category);
    _memoryCache[key] = optimizedPath;
    return optimizedPath;
  }

  /// Pre-cache all images to disk
  static Future<void> preCacheAllImages(
    List<String> imageUrls, [
    String category = 'default',
  ]) async {
    log('🚀 Pre-caching ${imageUrls.length} images for category "$category" to disk...');

    for (final url in imageUrls) {
      _preloadedImages['$category::$url'] = true;
    }

    Future.microtask(() async {
      try {
        for (final imageUrl in imageUrls) {
          try {
            final cachedPath = await _getCachedImagePath(imageUrl, category);
            if (cachedPath == null) {
              await _downloadOptimizeAndCacheImage(imageUrl, category);
              log('✅ Pre-loaded: $imageUrl');
            }
          } catch (e) {
            log('❌ Failed to pre-load $imageUrl: $e');
          }
        }
        log('🎉 Background pre-caching completed');
      } catch (e) {
        log('❌ Background pre-caching failed: $e');
      } finally {
        _preloadedImages.clear();
      }
    });
  }

  /// Pre-cache images to Flutter's memory for instant rendering
  static Future<void> precacheToMemory(
    List<String> imageUrls,
    BuildContext context, [
    String category = 'default',
  ]) async {
    log('🚀 Pre-caching ${imageUrls.length} images to memory for "$category"...');
    await Future.wait(
      imageUrls.map((url) async {
        try {
          final path = await getImage(url, category);
          ImageProvider provider;
          if (path.startsWith('http')) {
            provider = NetworkImage(path);
          } else {
            provider = FileImage(File(path));
          }
          await precacheImage(
            provider,
            context,
            onError: (exception, stackTrace) {
              log('❌ Memory precache error for $url: $exception');
            },
          );
        } catch (e) {
          log('❌ Memory precache failed for $url: $e');
        }
      }),
    );
    log('🎉 Memory pre-caching completed for "$category"');
  }

  /// Pre-load a specific image urgently
  static Future<void> preloadImageUrgently(String imageUrl, [String category = 'default']) async {
    try {
      final cachedPath = await _getCachedImagePath(imageUrl, category);
      if (cachedPath == null) {
        log('🚀 Urgent pre-load: $imageUrl');
        await _downloadOptimizeAndCacheImage(imageUrl, category);
      }
    } catch (e) {
      log('❌ Urgent pre-load failed: $e');
    }
  }

  /// Download, optimize, and cache image
  static Future<String> _downloadOptimizeAndCacheImage(String imageUrl, String category) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/$_cacheDir/$category');
      if (!await cacheDir.exists()) await cacheDir.create(recursive: true);

      final filename = _generateFileName(imageUrl);
      final file = File('${cacheDir.path}/$filename');

      if (await file.exists()) return file.path;

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final originalBytes = response.bodyBytes;
        final optimizedBytes = await _optimizeImage(originalBytes);
        await file.writeAsBytes(optimizedBytes);
        return file.path;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error caching image $imageUrl: $e');
      return imageUrl;
    }
  }

  /// Optimize image
  static Future<Uint8List> _optimizeImage(Uint8List originalBytes) async {
    try {
      return await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: _maxWidth,
        minHeight: _maxHeight,
        quality: _quality,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      log('❌ Image optimization failed: $e');
      return originalBytes;
    }
  }

  /// Get cached image path
  static Future<String?> _getCachedImagePath(String imageUrl, String category) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = _generateFileName(imageUrl);
      final file = File('${directory.path}/$_cacheDir/$category/$filename');
      return await file.exists() ? file.path : null;
    } catch (_) {
      return null;
    }
  }

  /// Generate unique filename
  static String _generateFileName(String url) {
    return '${md5.convert(utf8.encode(url))}.jpg';
  }

  /// Clear cached images, optionally by category
  static Future<void> clearImageCache([String? category]) async {
    try {
      _memoryCache.clear();
      _preloadedImages.clear();

      final directory = await getApplicationDocumentsDirectory();

      if (category == null) {
        final cacheDir = Directory('${directory.path}/$_cacheDir');
        if (await cacheDir.exists()) await cacheDir.delete(recursive: true);
        log('🧹 Cleared all cached images');
      } else {
        final sectionDir = Directory('${directory.path}/$_cacheDir/$category');
        if (await sectionDir.exists()) {
          await sectionDir.delete(recursive: true);
          log('🧹 Cleared cached images for "$category"');
        }
      }
    } catch (e) {
      log('❌ Error clearing image cache: $e');
    }
  }

  /// Get cache size info
  static Future<int> getCacheSize([String? category]) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      Directory cacheDir;
      if (category == null) {
        cacheDir = Directory('${directory.path}/$_cacheDir');
      } else {
        cacheDir = Directory('${directory.path}/$_cacheDir/$category');
      }

      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      final files = cacheDir.listSync(recursive: true);
      for (final file in files) {
        if (file is File) totalSize += await file.length();
      }

      return totalSize;
    } catch (e) {
      log('❌ Error getting cache size: $e');
      return 0;
    }
  }
}
