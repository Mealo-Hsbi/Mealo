import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/common/widgets/camera/capture_button.dart';
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

  // Liste zum Speichern der aufgenommenen Bilder
  final List<XFile> _capturedImages = [];

  // Define constants for the navbar dimensions (used for layout calculations)
  static const double _navbarHeight = 72.0;
  static const double _navbarBottomPadding = 32.0;
  static const double _thumbnailListHeight = 80.0; // Höhe für die Thumbnail-Liste

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
    }
  }

  void _disposeCamera() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> _initializeCamera() async {
    if (!mounted || !widget.isVisible) return;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      print("Kamera-Berechtigung nicht erteilt.");
      return;
    }

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
        _cameraOpacity = 0.0; // Kamera ist da, aber noch unsichtbar
      });

      // Nach kurzem Delay (z. B. 50ms), langsam sichtbar machen
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
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _cameraOpacity = 0.0; // Ausblenden für den Übergang
    });
    await Future.delayed(const Duration(milliseconds: 200)); // Fade-Out abwarten

    _disposeCamera(); // Dispose des alten Controllers

    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await _initializeCamera(); // Initialisiere die neue Kamera
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
        _capturedImages.add(picture); // Bild zur Liste hinzufügen
      });
    } catch (e) {
      print('Fehler beim Fotografieren: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      print('Bild aus Galerie: ${file.path}');
      // Optional: Bild aus Galerie auch zur Liste hinzufügen, wenn gewünscht
      // setState(() {
      //   _capturedImages.add(pickedFile);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size; // Die volle Bildschirmgröße

    final previewSize = _controller?.value.previewSize;

    // Skalierungsfaktor, um die Kamera-Vorschau den **gesamten Bildschirm** zu 'cover'n
    double scale = 1.0;
    if (_controller != null && _controller!.value.isInitialized && previewSize != null) {
      final double scaleX = mediaSize.width / previewSize.width;
      final double scaleY = mediaSize.height / previewSize.height;
      scale = math.max(scaleX, scaleY);
    }

    return GestureDetector(
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          // Schwarzer Hintergrund, wenn Kamera noch nicht da
          Container(color: Colors.black),

          // Kamera-Vorschau mit Fade
          // Positioniert die Vorschau über den gesamten Bildschirm
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _cameraOpacity,
            child: _controller != null && _controller!.value.isInitialized && previewSize != null
                ? ClipRect(
                    // Schneidet die Kamera-Vorschau auf die Bildschirmgröße zu
                    clipper: _MediaSizeClipper(mediaSize),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20.0),
                          bottom: Radius.circular(20.0)),
                      child: Transform.scale(
                        scale: scale,
                        // Zentriert die Kamera-Vorschau, um den 'cover'-Effekt zu erzielen
                        alignment: Alignment.center,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: _currentLensDirection == CameraLensDirection.front
                              ? Matrix4.rotationY(math.pi)
                              : Matrix4.identity(),
                          child: CameraPreview(_controller!, key: _previewKey),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // leer, solange nicht initialisiert
          ),

          // Thumbnail-Liste (angezeigt, wenn Bilder aufgenommen wurden)
          // Positioniert ÜBER der Navigationsleiste
          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: _navbarHeight + _navbarBottomPadding, // Über den Buttons positionieren
              left: 0,
              right: 0,
              height: _thumbnailListHeight,
              child: Container(
                color: Colors.black.withOpacity(0.5), // Leichter Hintergrund für Sichtbarkeit
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedImages.length,
                  itemBuilder: (context, index) {
                    final imageFile = _capturedImages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // Abgerundete Ecken für Thumbnails
                        child: Image.file(
                          File(imageFile.path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // UI (Navigationsleiste mit Buttons)
          // Positioniert am unteren Rand
          Positioned(
            bottom: _navbarBottomPadding,
            left: 0,
            right: 0,
            child: SizedBox(
              height: _navbarHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 24,
                    top: (_navbarHeight - 60) / 2,
                    child: GestureDetector(
                      onTap: _pickImageFromGallery,
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
                  AnimatedCaptureButton(onTap: _takePicture),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size clipSize;

  const _MediaSizeClipper(this.clipSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipSize.width, clipSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}