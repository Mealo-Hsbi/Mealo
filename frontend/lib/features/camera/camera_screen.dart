// frontend/screens/camera_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- HIER: services.dart importieren
import 'package:camera/camera.dart';
import 'package:frontend/common/widgets/camera/camera_controls.dart';
import 'package:frontend/common/widgets/camera/camera_view.dart';
import 'package:frontend/common/widgets/camera/thumbnail_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final bool isVisible;

  const CameraScreen({super.key, required this.isVisible});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  CameraLensDirection _currentLensDirection = CameraLensDirection.back;
  final GlobalKey _previewKey = GlobalKey();
  double _cameraOpacity = 0.0;

  final List<XFile> _capturedImages = [];

  static const double _navbarHeight = 72.0;
  static const double _navbarBottomPadding = 32.0;
  static const double _thumbnailListHeight = 80.0;
  static const double _thumbnailSize = 60.0;
  static const double _borderRadius = 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isVisible) _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didUpdateWidget(CameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_isInitialized) {
      _initializeCamera();
    } else if (!widget.isVisible && _isInitialized) {
      _disposeCamera();
      _resetScannedImages();
    }
  }

  void _resetScannedImages() {
    setState(() {
      _capturedImages.clear();
    });
  }

  void _disposeCamera() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> _initializeCamera() async {
    if (!mounted || !widget.isVisible) return;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) return;

    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == _currentLensDirection,
        orElse: () => cameras.first,
      );

      final controller = CameraController(camera, ResolutionPreset.max);

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isInitialized = true;
        _cameraOpacity = 0.0;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _cameraOpacity = 1.0;
          });
        }
      });
    } catch (e) {
      print("Fehler bei Kamera-Initialisierung: $e");
    }
  }

  Future<void> _switchCamera() async {
    _disposeCamera();

    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    setState(() {
      _cameraOpacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 200));

    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isVisible) return;

    if (state == AppLifecycleState.resumed && !_isInitialized) {
      _initializeCamera();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (!(_controller?.value.isInitialized ?? false)) return;

    try {
      final picture = await _controller!.takePicture();
      print('Bild aufgenommen: ${picture.path}');
      setState(() {
        _capturedImages.add(picture);
      });
    } catch (e) {
      print('Fehler beim Fotografieren: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _cameraOpacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 50));

    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (final file in pickedFiles) {
        print('Bild aus Galerie: ${file.path}');
      }
      setState(() {
        _capturedImages.addAll(pickedFiles);
      });
    }

    if (widget.isVisible && mounted) {
      setState(() {
        _cameraOpacity = 1.0;
      });
    } else {
      _disposeCamera();
    }
  }

  void _onContinueButtonPressed() {
    print('Weiter-Button gedrückt! Anzahl der Bilder: ${_capturedImages.length}');
    // Hier würde die Logik für den nächsten Schritt implementiert werden.
  }

  void _deleteImage(int index, String? imagePath) {
    setState(() {
      if (index >= 0 && index < _capturedImages.length) {
        _capturedImages.removeAt(index);

        if (imagePath != null) {
          final file = File(imagePath);
          if (file.existsSync()) {
            try {
              file.deleteSync();
              print('Bild von Festplatte gelöscht: $imagePath');
            } catch (e) {
              print('Fehler beim Löschen des Bildes von Festplatte: $e');
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final mediaSize = mediaQuery.size;
    final theme = Theme.of(context);

    final double topSafeAreaPadding = mediaQuery.padding.top;

    final cameraPreviewHeight = mediaSize.height - _navbarHeight - topSafeAreaPadding;

    final scale = _controller != null && _controller!.value.isInitialized
        ? 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height))
        : 1.0;

    return AnnotatedRegion<SystemUiOverlayStyle>( // <--- HIER DAS ANNOTATEDREGION HINZUFÜGEN
      value: SystemUiOverlayStyle.dark, // Oder .light, je nach gewünschter Farbe der Symbole
      child: GestureDetector(
        onDoubleTap: _switchCamera,
        child: Stack(
          children: [
            // Hintergrundfarbe für den gesamten Screen
            Container(color: theme.colorScheme.surface),

            // 1. Kamera-Vorschau
            Positioned(
              top: topSafeAreaPadding,
              left: 0,
              right: 0,
              height: cameraPreviewHeight,
              child: CameraView(
                controller: _controller,
                isInitialized: _isInitialized,
                cameraOpacity: _cameraOpacity,
                previewKey: _previewKey,
                currentLensDirection: _currentLensDirection,
                mediaSize: mediaSize,
                scale: scale,
                borderRadius: _borderRadius,
              ),
            ),

            // 2. Thumbnail-Liste (falls Bilder vorhanden)
            if (_capturedImages.isNotEmpty)
              Positioned(
                bottom: _navbarHeight + _navbarBottomPadding,
                left: 0,
                right: 0,
                height: _thumbnailListHeight,
                child: ThumbnailBar(
                  capturedImages: _capturedImages,
                  thumbnailSize: _thumbnailSize,
                  onDeleteImage: _deleteImage,
                ),
              ),

            // 3. Kamera-Steuerung (Capture, Galerie, Weiter)
            Positioned(
              bottom: _navbarBottomPadding,
              left: 0,
              right: 0,
              child: CameraControls(
                navbarHeight: _navbarHeight,
                onTakePicture: _takePicture,
                onPickImageFromGallery: _pickImageFromGallery,
                onContinueButtonPressed: _onContinueButtonPressed,
                showContinueButton: _capturedImages.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hilfs-Clipper (bleibt hier, da es stark an CameraScreen gebunden ist)
class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}