
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/image_cache_service.dart';

class CachedDiskImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CachedDiskImage({super.key, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ImageCacheService.getImage(imageUrl),
      builder: (context, snapshot) {
        // Show placeholder during loading or if no data
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          return _buildPlaceholder();
        }

        // Handle resolved path
        final path = snapshot.data!;

        if (path.startsWith('http')) {
          return Image.network(
            path,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        } else {
          return Image.file(
            File(path),
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
