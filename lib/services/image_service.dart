import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
      const int batchSize = 5;
      
      for (int i = 0; i < imageUrls.length; i += batchSize) {
        final end = (i + batchSize < imageUrls.length) ? i + batchSize : imageUrls.length;
        final batch = imageUrls.sublist(i, end);
        
        // Process batch in parallel
        await Future.wait(
          batch.map((url) => prefetchImage(url)),
        );
      }
    } catch (e) {
      debugPrint('Error batch prefetching images: $e');
    }
  }
}
