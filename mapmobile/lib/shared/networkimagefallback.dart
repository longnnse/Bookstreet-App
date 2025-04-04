import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    required this.fallbackWidget,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String imageUrl;
  final Widget fallbackWidget;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return fallbackWidget; // Display the fallback widget if an error occurs
      },
    );
  }
}
