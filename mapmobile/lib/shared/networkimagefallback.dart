import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    required this.fallbackWidget,
  });

  final String imageUrl;
  final Widget fallbackWidget;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return fallbackWidget; // Display the fallback widget if an error occurs
      },
    );
  }
}
