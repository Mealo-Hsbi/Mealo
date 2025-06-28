import 'package:flutter/material.dart';

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
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(
        child: url != null
            ? Image.network(
                url!,
                key: UniqueKey(), // 🔥 zwingt komplettes Neuladen des Bildes
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                headers: {
                  'Cache-Control': 'no-cache',
                  'Pragma': 'no-cache',
                  'Expires': '0',
                },
              )
            : const Icon(Icons.person, size: 48),
      ),
    );
  }
}
