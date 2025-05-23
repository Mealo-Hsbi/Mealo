// frontend/common/widgets/camera_screen/camera_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Hilfs-Clipper (kann entweder hierher oder im CameraScreen bleiben,
// da es nur für CameraPreview verwendet wird. Ich lasse es hier.)
class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class CameraView extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final double cameraOpacity;
  final GlobalKey previewKey;
  final CameraLensDirection currentLensDirection;
  final Size mediaSize;
  final double scale;

  const CameraView({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.cameraOpacity,
    required this.previewKey,
    required this.currentLensDirection,
    required this.mediaSize,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Schwarzer Hintergrund, wenn Kamera noch nicht da
        Container(color: Colors.black),

        // Kamera-Vorschau mit Fade-Animation
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: cameraOpacity,
          child: controller != null && isInitialized
              ? ClipRect(
                  clipper: _MediaSizeClipper(mediaSize),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: currentLensDirection == CameraLensDirection.front
                          ? Matrix4.rotationY(math.pi)
                          : Matrix4.identity(),
                      child: CameraPreview(controller!, key: previewKey),
                    ),
                  ),
                )
              : const SizedBox.shrink(), // Leer, solange nicht initialisiert
        ),
      ],
    );
  }
}