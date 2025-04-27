import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../services/compute_service.dart';

/// A service for handling image-related operations in isolates
class ImageService {
  /// Prefetch an image from a URL in an isolate
  /// This can be used to warm up the cache before displaying images
  static Future<Uint8List?> prefetchImage(String imageUrl) async {
    try {
      // Fetch the image data in an isolate
      return await ComputeService.compute<String, Uint8List?>(
        _fetchImageData,
        imageUrl,
      );
    } catch (e) {
      debugPrint('Error prefetching image: $e');
      return null;
    }
  }

  /// Fetch image data from a URL
  /// This is a static method that can be run in an isolate
  static Future<Uint8List?> _fetchImageData(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Batch prefetch multiple images
  /// This can be used to warm up the cache for a list of images
  static Future<void> prefetchImages(List<String> imageUrls) async {
    try {
      // Process in batches to avoid overloading the device
      const int batchSize = 3; // Reduced batch size to lower memory pressure

      for (int i = 0; i < imageUrls.length; i += batchSize) {
        final end =
            (i + batchSize < imageUrls.length)
                ? i + batchSize
                : imageUrls.length;
        final batch = imageUrls.sublist(i, end);

        // Process batch in parallel
        await Future.wait(batch.map((url) => prefetchImage(url)));

        // Add a small delay between batches to avoid UI jank
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint('Error batch prefetching images: $e');
    }
  }

  /// Optimize CachedNetworkImage settings
  static void optimizeCacheSettings() {
    try {
      // Set global cache settings for CachedNetworkImage
      final cache = PaintingBinding.instance.imageCache;
      cache.maximumSizeBytes = 100 * 1024 * 1024; // 100 MB

      // Clear the cache if it's getting too large
      if (cache.currentSizeBytes > 80 * 1024 * 1024) {
        debugPrint('IMAGE SERVICE: Clearing image cache to free memory');
        cache.clear();
        cache.clearLiveImages();
      }
    } catch (e) {
      debugPrint('Error optimizing cache settings: $e');
    }
  }

  /// Evict an image from cache
  static void evictImage(String imageUrl) {
    try {
      CachedNetworkImage.evictFromCache(imageUrl);
    } catch (e) {
      debugPrint('Error evicting image from cache: $e');
    }
  }

  /// Clear all cached images
  static void clearCache() {
    try {
      // Clear Flutter's image cache
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();

      // Clear CachedNetworkImage cache
      DefaultCacheManager().emptyCache();

      debugPrint('IMAGE SERVICE: Image cache cleared');
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }
}
