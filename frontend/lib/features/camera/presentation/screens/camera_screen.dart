// frontend/screens/camera_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- HIER: services.dart importieren
import 'package:camera/camera.dart';
import 'package:frontend/common/models/ingredient.dart';
import 'package:frontend/features/camera/presentation/widgets/camera_controls.dart';
import 'package:frontend/features/camera/presentation/widgets/camera_view.dart';
import 'package:frontend/features/camera/presentation/widgets/thumbnail_bar.dart';
import 'package:frontend/features/camera/presentation/screens/ingredient_review_screen.dart';
import 'package:frontend/services/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/features/camera/presentation/screens/ingredient_review_screen.dart'; // Dein Ziel-Screen
import 'package:frontend/features/camera/domain/usecases/process_images_use_case.dart'; // Dein Use Case
import 'package:frontend/features/camera/data/repositories/image_recognition_repository_impl.dart'; // Die Implementierung deines Repositories
import 'package:frontend/features/camera/data/datasources/image_recognition_api_data_source.dart'; // Deine DataSource

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
  bool _isProcessingImages = false;
  late final ProcessImagesUseCase _processImagesUseCase;

  final List<XFile> _capturedImages = [];

  static const double _navbarHeight = 72.0;
  static const double _navbarBottomPadding = 32.0;
  static const double _thumbnailListHeight = 80.0;
  static const double _thumbnailSize = 60.0;
  static const double _borderRadius = 18.0;

  @override
  void initState() {
    super.initState();
    _capturedImages.clear();

    final ApiClient apiClient = ApiClient(); // Hier musst du deinen API-Client initialisieren
    final imageRecognitionApiDataSource = ImageRecognitionApiDataSource(apiClient);
    final imageRecognitionRepository = ImageRecognitionRepositoryImpl(imageRecognitionApiDataSource);
    _processImagesUseCase = ProcessImagesUseCase(imageRecognitionRepository);

    WidgetsBinding.instance.addObserver(this);
    if (widget.isVisible) _initializeCamera(); // Necessary to initialize the camera only if the widget is visible
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

Future<List<String>> _uploadAndProcessImages(List<XFile> images) async {
  try {
    // Simuliere eine Netzwerkoperation oder Backend-Verarbeitung
    // Jetzt mit einer simulierten längeren Verzögerung, um den Timeout zu testen
    await Future.delayed(const Duration(seconds: 3)) // Simuliert eine lange Antwortzeit
        .timeout(const Duration(seconds: 5), onTimeout: () { // Timeout nach 5 Sekunden
      throw TimeoutException('Der Server hat zu lange für die Antwort gebraucht.');
    });

    // Hier würde dein tatsächlicher HTTP-Request an das Backend stehen, z.B. mit Dio oder http
    // Beispiel:
    // var response = await Dio().post(
    //   'YOUR_BACKEND_URL/api/process-images',
    //   data: formData, // Deine Multipart-Form-Daten
    // ).timeout(const Duration(seconds: 30)); // Setze hier einen realistischen Timeout (z.B. 30 Sekunden)

    // Beispielhafte erkannte Zutaten bei Erfolg
    return ['Tomate', 'Mozzarella', 'Basilikum', 'Olivenöl'];

  } on TimeoutException catch (e) {
    // Hier wird die spezifische Timeout-Ausnahme abgefangen
    print('Timeout bei der Bildverarbeitung: $e');
    rethrow; // Wirf die Ausnahme erneut, damit sie im _onContinueButtonPressed gefangen wird
  } catch (e) {
    // Hier werden andere potenzielle Fehler (z.B. Netzwerkfehler, Serverfehler) abgefangen
    print('Fehler im _uploadAndProcessImages: $e');
    rethrow; // Wirf die Ausnahme erneut
  }
}


  Future<void> _onContinueButtonPressed() async {
    if (_capturedImages.isEmpty) {
      _showSnackBar('Please capture at least one image first.');
      return;
    }

    _startProcessingState(); // Zeigt Lade-UI an und setzt Lade-Status

    try {
      final List<Ingredient> processedIngredients = await _processImagesUseCase(_capturedImages);
      _handleProcessingSuccess(processedIngredients); // Schließt Dialog, navigiert weiter
    } catch (e) {
      _handleProcessingError(e); // Schließt Dialog, zeigt Fehlermeldung
    } finally {
      _endProcessingState(); // Setzt Lade-Status zurück
    }
  }

  void _startProcessingState() {
    setState(() {
      _isProcessingImages = true;
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Analyzing images...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This may take a moment.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleProcessingSuccess(List<Ingredient> ingredients) {
    if (mounted) {
      // Wichtig: rootNavigator: true, um den Dialog-Kontext zu schließen
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => IngredientReviewScreen(ingredients: ingredients),
        ),
      );
    }
  }

  void _handleProcessingError(Object e) {
    print('Error processing images: $e'); // Für Debugging in der Konsole

    if (mounted) {
      // Wichtig: rootNavigator: true, um den Dialog-Kontext zu schließen
      Navigator.of(context, rootNavigator: true).pop();

      String errorMessage = 'An unknown error occurred.';
      if (e is TimeoutException) {
        errorMessage = 'The server response took too long. Please try again later.';
      } else {
        // Für alle anderen Fehler (inkl. generische DioExceptions, wenn sie nicht speziell behandelt werden)
        errorMessage = 'Error analyzing images: ${e.toString()}';
      }

      _showSnackBar(errorMessage, isError: true);
    }
  }

  void _endProcessingState() {
    if (mounted) {
      setState(() {
        _isProcessingImages = false;
      });
    }
  }

  // Hilfsmethode, um SnackBar-Nachrichten anzuzeigen
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: Duration(seconds: isError ? 5 : 2),
      ),
    );
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