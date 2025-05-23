// frontend/common/widgets/camera_screen/camera_controls.dart

import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/camera/capture_button.dart'; // Pfad zum CaptureButton

class CameraControls extends StatelessWidget {
  final double navbarHeight;
  final VoidCallback onTakePicture;
  final VoidCallback onPickImageFromGallery;
  final VoidCallback onContinueButtonPressed;
  final bool showContinueButton;

  const CameraControls({
    super.key,
    required this.navbarHeight,
    required this.onTakePicture,
    required this.onPickImageFromGallery,
    required this.onContinueButtonPressed,
    this.showContinueButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme abrufen

    return SizedBox(
      height: navbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            top: (navbarHeight - 60) / 2, // Vertikal zentrieren, wenn 60x60 Button
            child: GestureDetector(
              onTap: onPickImageFromGallery,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo, color: Colors.white, size: 28),
              ),
            ),
          ),
          // Der Aufnahme-Button
          AnimatedCaptureButton(onTap: onTakePicture),

          // Der "Weiter"-Knopf als Icon
          if (showContinueButton)
            Positioned(
              right: 24,
              child: ElevatedButton(
                onPressed: onContinueButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 60),
                  fixedSize: const Size(60, 60),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}