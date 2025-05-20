import 'dart:io';
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

    final controller = CameraController(selectedCamera, ResolutionPreset.medium);

    try {
      await controller.initialize();
    } catch (e) {
      print('Fehler bei Kamera-Initialisierung: $e');
      return;
    }

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _isInitialized = true;
    });
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isInitialized = false;
    });
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

  final picture = await _controller!.takePicture();
  print('Bild gespeichert unter: ${picture.path}');

  // Hier z.B. ans Backend schicken oder anzeigen
}

Future<void> _pickImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final file = File(pickedFile.path);
    print('Bild aus Galerie: ${file.path}');

    // Hier z.B. ans Backend schicken oder anzeigen
  }
}


@override
Widget build(BuildContext context) {
  if (!_isInitialized || _controller == null) {
    return const Center(child: CircularProgressIndicator());
  }

  final mediaSize = MediaQuery.of(context).size;
  final scale = 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height));

  return Stack(
    children: [
      ClipRect(
        clipper: _MediaSizeClipper(mediaSize),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onDoubleTap: _switchCamera,  // hier wieder das Umschalten per Doppeltap
            child: CameraPreview(_controller!),
          ),
        ),
      ),
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
