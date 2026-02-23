import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/image_cache_service.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ImageCacheService.getImage(imageUrl), // disk cache -> memory
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildPlaceholder();

        final path = snapshot.data!;
        if (path.startsWith('http')) {
          return Image.network(
            path,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          );
        } else {
          return Image.file(
            File(path),
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          );
        }
      },
    );
  }

  Widget _buildPlaceholder() => Container(
    width: width,
    height: height,
    color: Colors.grey[200],
    child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
  );
}
