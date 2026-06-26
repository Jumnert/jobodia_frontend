import 'package:flutter/material.dart';

/// A wrapper around [Image.network] that only loads images from allowlisted
/// domains. Prevents content injection if URLs become user-controlled.
class SafeImageLoader extends StatelessWidget {
  const SafeImageLoader({
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  static const _allowedDomains = [
    'images.unsplash.com',
    'upload.wikimedia.org',
    'via.placeholder.com',
  ];

  /// Returns true if [url] is HTTPS and from an allowlisted domain.
  static bool isAllowedUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          uri.scheme == 'https' &&
          _allowedDomains.any((d) => uri.host == d || uri.host.endsWith('.$d'));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAllowedUrl(url)) {
      return errorBuilder?.call(context, 'Domain not allowed', null) ??
          const Icon(Icons.broken_image, size: 48);
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder:
          errorBuilder ?? (_, _, _) => const Icon(Icons.broken_image, size: 48),
    );
  }
}
