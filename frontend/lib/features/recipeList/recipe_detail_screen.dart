import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  // final Recipe recipe;
  final name;
  final imageUrl;
  final place;

  // const RecipeDetailScreen({super.key, required this.recipe});
  const RecipeDetailScreen({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.place,
  });

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text(name)),
  //     body: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Image.network(imageUrl, height: 200, fit: BoxFit.cover),
  //         const SizedBox(height: 16),
  //         Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Text(
  //             place.isNotEmpty
  //                 ? 'Quelle: $place'
  //                 : 'Keine Quelle angegeben',
  //             style: const TextStyle(fontSize: 16, color: Colors.grey),
  //           ),
  //         ),
  //         // Hier kannst du später Zutaten, Anleitungen etc. anzeigen
  //       ],
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     // Kein AppBar mehr
  //     body: CustomScrollView(
  //       slivers: [
  //         SliverToBoxAdapter(
  //           child: Stack(
  //             alignment: Alignment.bottomLeft,
  //             children: [
  //               Image.network(
  //                 imageUrl,
  //                 height: 300,
  //                 width: double.infinity,
  //                 fit: BoxFit.cover,
  //               ),
  //               Container(
  //                 height: 300,
  //                 width: double.infinity,
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       Colors.transparent,
  //                       Colors.black.withOpacity(0.6),
  //                     ],
  //                     begin: Alignment.topCenter,
  //                     end: Alignment.bottomCenter,
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
  //                 child: Text(
  //                   name,
  //                   style: const TextStyle(
  //                     fontSize: 28,
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     shadows: [
  //                       Shadow(
  //                         color: Colors.black38,
  //                         blurRadius: 6,
  //                         offset: Offset(1, 1),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         SliverToBoxAdapter(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Text(
  //               place.isNotEmpty
  //                   ? 'Quelle: $place'
  //                   : 'Keine Quelle angegeben',
  //               style: const TextStyle(fontSize: 16, color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //         // Mehr Inhalt könnte hier folgen...
  //       ],
  //     ),
  //   );
  // }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Bild
                Image.network(
                  imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // Verlaufs-Overlay nur unten
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 1],
                      ),
                    ),
                  ),
                ),

                // Rezeptname unten links
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Zurück-Button oben links
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Textbereich darunter
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Text(
          //       place.isNotEmpty
          //           ? 'Quelle: $place'
          //           : 'Keine Quelle angegeben',
          //       style: const TextStyle(fontSize: 16, color: Colors.grey),
          //     ),
          //   ),
          // ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(40, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Testzeile ${index + 1}'),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
