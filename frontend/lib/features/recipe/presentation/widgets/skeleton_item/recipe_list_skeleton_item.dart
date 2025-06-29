// lib/features/search/presentation/widgets/recipe_skeleton_item.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecipeSkeletonItem extends StatelessWidget {
  const RecipeSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    // Die horizontale Breite, die dem AspectRatio zur Verfügung steht.
    // Bildschirmbreite - (2 * horizontaler Padding des RecipeItem)
    final double availableWidthForAspectRatio = MediaQuery.of(context).size.width - (24 * 2); // 24 ist der horizontale Padding von RecipeItem

    // Die Höhe des AspectRatio-Widgets (16:9 Verhältnis)
    final double aspectRatioHeight = availableWidthForAspectRatio * (9 / 16);

    // Die gesamte vertikale Höhe des RecipeItem, inklusive des vertical Paddings (16 oben + 16 unten)
    final double totalItemHeight = aspectRatioHeight + (16 * 2);

    return SizedBox(
      height: totalItemHeight, // Setze die exakte Gesamthöhe des Items
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!, // Etwas helleres Grau für die Grundfarbe
        highlightColor: Colors.grey[50]!, // Noch helleres Grau für den Shimmer-Effekt (stärkerer Kontrast)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Match RecipeItem padding
          child: AspectRatio(
            aspectRatio: 16 / 9, // Match RecipeItem aspect ratio
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Match RecipeItem border radius
              child: Stack(
                children: [
                  // Hintergrund-Platzhalter für das "Bild"
                  Container(
                    color: Colors.grey[300], // Reduzierte Helligkeit
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Optional: Ein leichter Gradient, um den Textebene anzudeuten
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4)], // Leichterer Gradient
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 0.95],
                        ),
                      ),
                    ),
                  ),
                  // Platzhalter für Titel und Untertitel am unteren Rand
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Platzhalter für den Titel (Bold, größer)
                        Container(
                          width: double.infinity,
                          height: 20.0, // Entspricht ungefähr deiner fontSize: 20
                          color: Colors.grey[100], // Hellere Farbe für Text-Platzhalter
                        ),
                        const SizedBox(height: 8.0), // Abstand zum nächsten Element
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Platzhalter für "Prep Time"
                            Container(
                              width: 100.0, // Feste Breite, da die tatsächliche Länge variiert
                              height: 14.0, // Entspricht deiner fontSize: 14
                              color: Colors.grey[100],
                            ),
                            // Platzhalter für sekundäre Info (z.B. Kalorien)
                            Container(
                              width: 80.0, // Feste Breite
                              height: 14.0,
                              color: Colors.grey[100],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}