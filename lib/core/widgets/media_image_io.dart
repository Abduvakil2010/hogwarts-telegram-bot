import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'fullscreen_image_viewer.dart';

class MediaImage extends StatelessWidget {
  const MediaImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorBuilder,
    this.openFullscreenOnTap = true,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final bool openFullscreenOnTap;

  bool _isRemoteUrl(String value) {
    final normalized = value.trim();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  bool _isLocalFile(String value) {
    final normalized = value.trim();
    return normalized.startsWith('file://') || normalized.startsWith('/') || normalized.startsWith('\\');
  }

  bool _isDataUri(String value) {
    final v = value.trim();
    return v.startsWith('data:');
  }

  Widget _buildImage() {
    final value = imageUrl.trim();
    if (value.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    if (_isRemoteUrl(value)) {
      return Image.network(
        value,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ??
            (_, __, ___) => placeholder ?? const Center(child: Icon(Icons.image_not_supported_outlined)),
      );
    }

    if (_isLocalFile(value)) {
      try {
        final uri = Uri.parse(value);
        final file = File(uri.isAbsolute && uri.scheme == 'file' ? uri.toFilePath() : value);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: errorBuilder ??
                (_, __, ___) => placeholder ?? const Center(child: Icon(Icons.image_not_supported_outlined)),
          );
        }
      } catch (_) {
        // fallthrough to placeholder
      }
    }

    if (_isDataUri(value)) {
      try {
        final comma = value.indexOf(',');
        final payload = value.substring(comma + 1);
        final bytes = base64Decode(payload);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder ??
              (_, __, ___) => placeholder ?? const Center(child: Icon(Icons.image_not_supported_outlined)),
        );
      } catch (_) {
        return placeholder ?? const Center(child: Icon(Icons.image_not_supported_outlined));
      }
    }

    return placeholder ?? const Center(child: Icon(Icons.image_not_supported_outlined));
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    if (!openFullscreenOnTap) {
      return image;
    }

    return GestureDetector(
      onTap: () {
        if (imageUrl.trim().isEmpty) return;
        showDialog(
          context: context,
          builder: (_) => FullscreenImageViewer(
            imageUrl: imageUrl,
            title: 'Image preview',
          ),
        );
      },
      child: image,
    );
  }
}
