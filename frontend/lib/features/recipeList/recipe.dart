class Recipe {
  const Recipe({
    required this.name,
    required this.place,
    required this.imageUrl,
  });

  final String name;     
  final String place;  
  final String imageUrl;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['title'] ?? 'Unknown Recipe',
      place: 'Spoonacular',
      imageUrl: json['image'] ?? '',
    );
  }
}