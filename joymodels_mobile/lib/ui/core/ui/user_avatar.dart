import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class UserAvatar extends StatefulWidget {
  final String imageUrl;
  final double radius;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 20});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && !_hasError) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: NetworkImage(
              widget.imageUrl,
              headers: {'Authorization': 'Bearer ${snapshot.data}'},
            ),
            onBackgroundImageError: (_, _) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                });
              }
            },
          );
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.person,
            size: widget.radius,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      },
    );
  }
}
