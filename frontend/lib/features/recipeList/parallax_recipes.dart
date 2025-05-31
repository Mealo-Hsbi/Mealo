import 'package:flutter/material.dart';
import 'package:frontend/common/models/recipe.dart';
import 'package:frontend/features/recipeList/recipe_detail_screen.dart';

class ParallaxRecipes extends StatelessWidget {
  const ParallaxRecipes({
    super.key,
    required this.recipes,
  });

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    // return SingleChildScrollView(
      // child: Column(
      return Column(
        children: [
          // for (final recipe in locations)
          for (final recipe in recipes)
            RecipeItem(
              imageUrl: recipe.imageUrl,
              name: recipe.name,
              country: recipe.place ?? '',
            ),
        ],
      );
    // );
  }
}

@immutable
class RecipeItem extends StatelessWidget {
  RecipeItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.country, // Bleibt für den Ort (Place)
    this.readyInMinutes, // NEU: Optionale Zubereitungszeit
    this.servings,       // NEU: Optionale Portionen
  });

  final String imageUrl;
  final String name;
  final String country;
  final int? readyInMinutes; // NEU: Kann null sein
  final int? servings;       // NEU: Kann null sein
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(name: name, imageUrl: imageUrl, place: country),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildParallaxBackground(context),
                _buildGradient(),
                _buildTitleAndSubtitle(), // Diese Methode wird angepasst
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        // Image.network(imageUrl, key: _backgroundImageKey, fit: BoxFit.cover),
        _buildRecipeImageWidget(imageUrl, _backgroundImageKey), // Hier wird das Bild geladen
      ],
    );
  }

  Widget _buildRecipeImageWidget(String imageUrl, GlobalKey imageKey) {
    // Entscheidet, welches Bild angezeigt wird: das von der URL oder ein Platzhalter
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        key: imageKey, // Wichtig: Den Key hier übergeben
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback: Wenn das Bild nicht geladen werden kann, zeige ein lokales Asset.
          return Image.asset(
            'assets/images/placeholder_image.png', // Stelle sicher, dass dieses Asset existiert
            key: imageKey, // Auch hier den Key übergeben
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          // Optional: Ladeindikator während des Ladens
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white, // Optional: Farbe anpassen
            ),
          );
        },
      );
    } else {
      // Fallback: Wenn die URL leer ist, zeige ein anderes lokales Asset
      return Image.asset(
        'assets/images/no_image_available.png', // Stelle sicher, dass dieses Asset existiert
        key: imageKey, // Auch hier den Key übergeben
        fit: BoxFit.cover,
      );
    }
  }
  
  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)], // withValues zu withOpacity geändert
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,              
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis, // Damit der Text nicht überläuft
          ),
          // Bestehende Länder-Anzeige (Ort)
          // Text(
          //   country,
          //   style: const TextStyle(color: Colors.white, fontSize: 14),
          // ),
          // NEU: Anzeige für Zubereitungszeit
          if (readyInMinutes != null)
            Text(
              'Prep Time: $readyInMinutes Min.',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          // NEU: Anzeige für Portionen
          // if (servings != null)
          //   Text(
          //     'Portionen: $servings',
          //     style: const TextStyle(color: Colors.white, fontSize: 14),
          //   ),
        ],
      ),
    );
  }
}



class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(
      0.0,
      1.0,
    );

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    // Paint the background.
    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}