import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;


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

  // Fokus-Overlay
  bool _showFocusCircle = false;
  double _tapX = 0;
  double _tapY = 0;

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
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _tryInitializeCamera();
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

Future<void> _handleTap(TapUpDetails details) async {
  if (!mounted || _controller == null || !_controller!.value.isInitialized) return;

final RenderBox? previewBox = _previewKey.currentContext!.findRenderObject() as RenderBox?;
final RenderBox? stackBox = context.findRenderObject() as RenderBox?;

if (previewBox == null || stackBox == null) return;

final Offset previewLocal = previewBox.globalToLocal(details.globalPosition);
final Offset stackLocal = stackBox.globalToLocal(details.globalPosition);
final Size previewSize = previewBox.size;

final double x = (previewLocal.dx / previewSize.width).clamp(0.0, 1.0);
final double y = (previewLocal.dy / previewSize.height).clamp(0.0, 1.0);

// 🎯 Zeige den Kreis SOFORT
setState(() {
  _showFocusCircle = true;
  _tapX = stackLocal.dx;
  _tapY = stackLocal.dy;
});

// 🔧 Fokus & Belichtung später (asynchron)
unawaited(_controller?.setFocusPoint(Offset(x, y)));
unawaited(_controller?.setExposurePoint(Offset(x, y)));

Future.delayed(const Duration(seconds: 2), () {
  if (mounted) {
    setState(() => _showFocusCircle = false);
  }
});
}

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height));

    return GestureDetector(
      onTapUp: _handleTap,
      onDoubleTap: _switchCamera,
      child: Stack(
        children: [
          ClipRect(
            clipper: _MediaSizeClipper(mediaSize),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              // child: CameraPreview(_controller!),
              child: Transform(
                alignment: Alignment.center,
                transform: _currentLensDirection == CameraLensDirection.front
                    ? Matrix4.rotationY(math.pi)
                    : Matrix4.identity(),
                child: CameraPreview(_controller!, key: _previewKey),
              ),
            ),
          ),
          if (_showFocusCircle) _buildFocusCircle(),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    iconSize: 36,
                    color: Colors.white,
                    onPressed: _pickImageFromGallery,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    iconSize: 48,
                    color: Colors.white,
                    onPressed: _takePicture,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCircle() {
  return Positioned(
    left: _tapX - 30,
    top: _tapY - 30,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedOpacity(
            opacity: _showFocusCircle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      },
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

