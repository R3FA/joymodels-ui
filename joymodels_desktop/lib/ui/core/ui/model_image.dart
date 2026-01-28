import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';

class ModelImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;

  const ModelImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.network(
            imageUrl,
            fit: fit,
            alignment: alignment,
            headers: {'Authorization': 'Bearer ${snapshot.data}'},
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 42,
              color: Colors.grey,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
