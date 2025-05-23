// frontend/common/widgets/camera_screen/camera_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final double cameraOpacity;
  final GlobalKey previewKey;
  final CameraLensDirection currentLensDirection;
  final Size mediaSize;
  final double scale;
  final double borderRadius;

  const CameraView({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.cameraOpacity,
    required this.previewKey,
    required this.currentLensDirection,
    required this.mediaSize,
    required this.scale,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: cameraOpacity,
      child: controller != null && isInitialized
          ? ClipRRect( // Hier wird der ClipRRect angepasst!
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),     // <--- NEU: Obere linke Ecke
                topRight: Radius.circular(borderRadius),    // <--- NEU: Obere rechte Ecke
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: mediaSize.width,
                    height: mediaSize.width * controller!.value.aspectRatio,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: currentLensDirection == CameraLensDirection.front
                          ? Matrix4.rotationY(math.pi)
                          : Matrix4.identity(),
                      child: CameraPreview(controller!, key: previewKey),
                    ),
                  ),
                ),
              ),
            )
          : Container(color: Colors.black), // Beachte: Diese Farbe wird jetzt vom CameraScreen gesteuert
    );
  }
}