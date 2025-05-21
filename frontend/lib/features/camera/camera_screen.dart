import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tryInitializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_isInitialized) {
      _tryInitializeCamera();
    } else if (!widget.isVisible && _isInitialized) {
      _disposeCamera();
    }
  }

  void _disposeCamera() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  Future<void> _tryInitializeCamera() async {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;

    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) return;
    }

    final cameras = await availableCameras();
    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == _currentLensDirection,
      orElse: () => cameras.first,
    );

    final controller = CameraController(selectedCamera, ResolutionPreset.max);

    try {
      await controller.initialize();
    } catch (e) {
      print('Kamera-Initialisierung fehlgeschlagen: $e');
      return;
    }

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _isInitialized = true;
    });
  }

  Future<void> _switchCamera() async {
    _isInitialized = false;
    _disposeCamera();

    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await _tryInitializeCamera();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (!widget.isVisible) return;

  if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
    _disposeCamera(); // Wichtig: Kamera richtig schließen
  } else if (state == AppLifecycleState.resumed) {
    _tryInitializeCamera(); // Kamera neu starten
  }
}

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final picture = await _controller!.takePicture();
      print('Bild aufgenommen: ${picture.path}');
      // Vorschau oder Upload hier
    } catch (e) {
      print('Fehler beim Fotografieren: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      print('Bild aus Galerie: ${file.path}');
      // Vorschau oder Upload hier
    }
  }

  Future<File?> _getLastImageThumbnail() async {
    final picker = ImagePicker();
    final recent = await picker.pickImage(source: ImageSource.gallery);
    if (recent != null) {
      return File(recent.path);
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height));

    return GestureDetector(
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          ClipRect(
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
          ),
Positioned(
  bottom: 32,
  left: 0,
  right: 0,
  child: SizedBox(
    height: 72, // Höhe wie Aufnahme-Button, für einfachere Zentrierung
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Galerie-Button links, mit Abstand 24
        Positioned(
          left: 24,
          top: (72 - 60) / 2, // zentriert den 60x60 Button vertikal im 72px hohen Container
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

        // Aufnahme-Button exakt in der Mitte
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
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class AnimatedCaptureButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedCaptureButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AnimatedCaptureButton> createState() => _AnimatedCaptureButtonState();
}

class _AnimatedCaptureButtonState extends State<AnimatedCaptureButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    widget.onTap(); // sofort Foto machen

    // WICHTIG: warte ganz kurz, damit die "kleine" Animation sichtbar ist
    await Future.delayed(const Duration(milliseconds: 40));
    if (mounted) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.transparent, // kein Füllbereich im äußeren Ring
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

