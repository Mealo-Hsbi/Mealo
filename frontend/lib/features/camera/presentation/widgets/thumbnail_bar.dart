// frontend/common/widgets/camera_screen/thumbnail_bar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Für XFile

class ThumbnailBar extends StatelessWidget {
  final List<XFile> capturedImages;
  final double thumbnailSize;
  final Function(int index, String? imagePath) onDeleteImage;

  const ThumbnailBar({
    super.key,
    required this.capturedImages,
    required this.thumbnailSize,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: capturedImages.length,
        clipBehavior: Clip.none, // WICHTIG: Erlaubt dem Dismissible, sich außerhalb der ListView zu bewegen
        itemBuilder: (context, index) {
          final imageFile = capturedImages[index];
          return _ImageThumbnail(
            key: ValueKey(imageFile.path), // Wichtig für Dismissible
            imageFile: imageFile,
            thumbnailSize: thumbnailSize,
            onDeleteConfirmed: () => onDeleteImage(index, imageFile.path),
          );
        },
      ),
    );
  }
}

// Internes Widget für das einzelne Thumbnail (bleibt hier, da es eng an ThumbnailBar gekoppelt ist)
class _ImageThumbnail extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onDeleteConfirmed;
  final double thumbnailSize;

  const _ImageThumbnail({
    required Key key,
    required this.imageFile,
    required this.onDeleteConfirmed,
    required this.thumbnailSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double deleteBackgroundSize = thumbnailSize * 0.8; // Lösch-Hintergrund 80% der Thumbnail-Größe

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Dismissible(
        key: key!,
        direction: DismissDirection.up,
        onDismissed: (direction) {
          onDeleteConfirmed();
        },
        background: Center(
          child: Container(
            width: deleteBackgroundSize,
            height: deleteBackgroundSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            File(imageFile.path),
            width: thumbnailSize,
            height: thumbnailSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}