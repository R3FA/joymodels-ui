import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: NetworkImage(
              imageUrl,
              headers: {'Authorization': 'Bearer ${snapshot.data}'},
            ),
            onBackgroundImageError: (_, _) {},
            child: Icon(
              Icons.person,
              size: radius,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          );
        }
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.person,
            size: radius,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      },
    );
  }
}
