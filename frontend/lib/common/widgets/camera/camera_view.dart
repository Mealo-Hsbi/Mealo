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
  final Size mediaSize; // Bleibt, da es für die Skalierung wichtig ist
  final double scale;
  final double borderRadius; // Neuer Parameter für die Eckenrundung

  const CameraView({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.cameraOpacity,
    required this.previewKey,
    required this.currentLensDirection,
    required this.mediaSize,
    required this.scale,
    this.borderRadius = 0.0, // Standardwert, falls nicht übergeben
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: cameraOpacity,
      child: controller != null && isInitialized
          ? ClipRRect( // Hier kommt der ClipRRect ins Spiel!
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              child: SizedBox.expand( // Wichtig: Füllt den verfügbaren Platz im Positioned-Container
                child: FittedBox( // Sorgt dafür, dass CameraPreview den verfügbaren Platz ausfüllt
                  fit: BoxFit.cover, // Wichtig für das Seitenverhältnis
                  child: SizedBox(
                    width: mediaSize.width, // Originalbreite der Kamera
                    height: mediaSize.width * controller!.value.aspectRatio, // Originalhöhe der Kamera
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
          : Container(color: Colors.white), // Schwarzer Hintergrund, wenn nicht initialisiert
    );
  }
}