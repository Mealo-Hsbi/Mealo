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

  // NEU: Liste zum Speichern der aufgenommenen Bilder
  final List<XFile> _capturedImages = [];

  // Konstanten für die UI-Elemente
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
    _disposeCamera();

    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    setState(() {
      _cameraOpacity = 0.0; // ausblenden
    });
    await Future.delayed(const Duration(milliseconds: 200)); // Fade-Out abwarten

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

  // NEU: Bild aufnehmen und zur Liste hinzufügen
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
    final mediaSize = MediaQuery.of(context).size;
    // Der Skalierungsfaktor aus deinem Originalcode
    final scale = _controller != null && _controller!.value.isInitialized
        ? 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height))
        : 1.0;

    return GestureDetector(
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          // Schwarzer Hintergrund, wenn Kamera noch nicht da
          Container(color: Colors.black),

          // Kamera-Vorschau mit Fade
          // Diese Sektion bleibt so wie im Original, die Größe wird nicht beeinflusst.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _cameraOpacity,
            child: _controller != null && _controller!.value.isInitialized
                ? ClipRect(
                    clipper: _MediaSizeClipper(mediaSize),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: _currentLensDirection == CameraLensDirection.front
                            ? Matrix4.rotationY(math.pi)
                            : Matrix4.identity(),
                        child: CameraPreview(_controller!, key: _previewKey),
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // leer, solange nicht initialisiert
          ),

          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: _navbarHeight + _navbarBottomPadding, // Platzierung über den Buttons
              left: 0,
              right: 0,
              height: _thumbnailListHeight,
              child: Container(
                color: Colors.black.withOpacity(0), // Leichter Hintergrund für Sichtbarkeit
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Horizontal scrollbar
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
          // Diese Sektion bleibt ebenfalls so wie im Original.
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
                  // Der Aufnahme-Button
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
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}