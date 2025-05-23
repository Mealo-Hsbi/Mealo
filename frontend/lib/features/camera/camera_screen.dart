import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/common/widgets/camera/capture_button.dart'; // Stelle sicher, dass dieser Pfad korrekt ist
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

  // Konstanten für die UI-Elemente
  static const double _navbarHeight = 72.0;
  static const double _navbarBottomPadding = 32.0;
  static const double _thumbnailListHeight = 80.0; // Höhe für die Thumbnail-Liste
  static const double _thumbnailSize = 60.0; // Die Größe der einzelnen Thumbnails (Breite und Höhe)

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

  // Bild aufnehmen und zur Liste hinzufügen
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
    // Fading-Effekt für die Kamera-Vorschau vor dem Öffnen der Galerie
    setState(() {
      _cameraOpacity = 0.0; // Kamera-Vorschau ausblenden
    });
    // Kurze Verzögerung, damit der Fade-Out sichtbar wird
    await Future.delayed(const Duration(milliseconds: 50));

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('Bild aus Galerie: ${pickedFile.path}');
      setState(() {
        _capturedImages.add(pickedFile); // Bild aus Galerie zur Liste hinzufügen
      });
    }

    // Kamera-Vorschau wieder einblenden, nachdem der ImagePicker geschlossen wurde
    if (widget.isVisible && mounted) {
      setState(() {
        _cameraOpacity = 1.0; // Kamera-Vorschau wieder einblenden
      });
    } else {
      _disposeCamera();
    }
  }

  // Funktion für den "Weiter"-Knopf
  void _onContinueButtonPressed() {
    print('Weiter-Button gedrückt! Anzahl der Bilder: ${_capturedImages.length}');
    // Hier würde die Logik für den nächsten Schritt implementiert werden,
    // z.B. das Senden der _capturedImages an die Google Vision API
    // oder das Navigieren zu einem anderen Bildschirm.
  }

  // Funktion zum Löschen eines Bildes (wird vom _ImageThumbnail aufgerufen)
  void _deleteImage(int index, String? imagePath) {
    setState(() {
      if (index >= 0 && index < _capturedImages.length) {
        _capturedImages.removeAt(index);

        // Optional: Bild von der Festplatte löschen
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
    final mediaSize = MediaQuery.of(context).size;
    final theme = Theme.of(context); // Theme abrufen, um ColorScheme zu nutzen

    // Der Skalierungsfaktor aus deinem Originalcode
    final scale = _controller != null && _controller!.value.isInitialized
        ? 1 / (_controller!.value.aspectRatio * (mediaSize.width / mediaSize.height))
        : 1.0;

    return GestureDetector(
      onDoubleTap: _switchCamera,
      onTap: () {
        // Hier könnte man zukünftig eine andere Interaktion einbauen,
        // z.B. wenn man einen Bild-Viewer öffnen möchte.
      },
      child: Stack(
        children: [
          // Schwarzer Hintergrund, wenn Kamera noch nicht da
          Container(color: Colors.black),

          // Kamera-Vorschau mit Fade
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

          // Thumbnail-Liste
          if (_capturedImages.isNotEmpty)
            Positioned(
              bottom: _navbarHeight + _navbarBottomPadding, // Platzierung über den Buttons
              left: 0,
              right: 0,
              height: _thumbnailListHeight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Horizontal scrollbar
                  itemCount: _capturedImages.length,
                  clipBehavior: Clip.none, // WICHTIG: Erlaubt dem Dismissible, sich außerhalb der ListView zu bewegen
                  itemBuilder: (context, index) {
                    final imageFile = _capturedImages[index];

                    return _ImageThumbnail(
                      key: ValueKey(imageFile.path), // Wichtig für Dismissible
                      imageFile: imageFile,
                      thumbnailSize: _thumbnailSize, // Die Größe des Thumbnails übergeben
                      onDeleteConfirmed: () => _deleteImage(index, imageFile.path), // Löschen bestätigen
                    );
                  },
                ),
              ),
            ),

          // UI (Navigationsleiste mit Buttons)
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

                  // Der "Weiter"-Knopf als Icon
                  if (_capturedImages.isNotEmpty) // Nur anzeigen, wenn mindestens ein Bild aufgenommen wurde
                    Positioned(
                      right: 24, // Positionierung rechts
                      child: ElevatedButton(
                        onPressed: _onContinueButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(60, 60),
                          fixedSize: const Size(60, 60),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Hilfs-Widgets ---

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

// NEUES WIDGET: _ImageThumbnail mit Swipe-to-Delete und verbessertem Hintergrund
class _ImageThumbnail extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onDeleteConfirmed; // Callback, wenn Löschung bestätigt wird
  final double thumbnailSize; // Die Größe des Thumbnails, übergeben vom Parent

  const _ImageThumbnail({
    required Key key, // Key ist hier WICHTIG für Dismissible
    required this.imageFile,
    required this.onDeleteConfirmed,
    this.thumbnailSize = 60.0, // Standardwert, falls nicht übergeben
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Die Größe des Lösch-Hintergrunds, z.B. 80% der Thumbnail-Größe
    // Du kannst den Multiplikator anpassen, um die gewünschte Größe zu erhalten
    final double deleteBackgroundSize = thumbnailSize * 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Dismissible(
        key: key!,
        direction: DismissDirection.up, // Nur nach oben wischen erlauben
        onDismissed: (direction) {
          // Callback, wenn das Element vollständig weggewischt wurde
          onDeleteConfirmed();
        },
        // Der Hintergrund, der sichtbar wird, wenn gewischt wird
        background: Center( // Zentriert den Hintergrund innerhalb des Dismissible-Bereichs
          child: Container(
            // Der Container für den Hintergrund
            width: deleteBackgroundSize, // Kleinere Breite
            height: deleteBackgroundSize, // Kleinere Höhe
            alignment: Alignment.center, // Icon in der Mitte zentrieren
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8), // Roter Hintergrund
              borderRadius: BorderRadius.circular(8.0), // Abgerundete Ecken passend zum Thumbnail
              boxShadow: [ // Subtiler Schatten für Tiefe
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // Schatten leicht nach unten
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_forever, // Mülleimer-Icon
              color: Colors.white, // Weißes Icon
              size: 36, // Größe des Icons
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            File(imageFile.path),
            width: thumbnailSize, // Sicherstellen, dass das Bild die korrekte Größe hat
            height: thumbnailSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}