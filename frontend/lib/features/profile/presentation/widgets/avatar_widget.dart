import 'package:flutter/material.dart';

/// Widget, das Lade-Status, Image und onTap für den Avatar kapselt
class AvatarWidget extends StatelessWidget {
  final String? url;
  final bool loading;

  const AvatarWidget({
    Key? key,
    required this.url,
    required this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CircularProgressIndicator();
    }
    return CircleAvatar(
      radius: 48,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null ? const Icon(Icons.person) : null,
    );
  }
}