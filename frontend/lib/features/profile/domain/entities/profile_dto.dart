// lib/features/profile/domain/entities/profile_dto.dart

import 'package:flutter/foundation.dart'; // für mapEquals

class RecipePreviewDto {
  final String imageUrl;
  final String title;

  RecipePreviewDto({required this.imageUrl, required this.title});

  factory RecipePreviewDto.fromJson(Map<String, dynamic> json) {
    return RecipePreviewDto(
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecipePreviewDto) return false;
    return imageUrl == other.imageUrl && title == other.title;
  }

  @override
  int get hashCode => Object.hash(imageUrl, title);
}

class AchievementDto {
  final String key;
  final String title;
  final String description;
  final String? icon;

  AchievementDto({
    required this.key,
    required this.title,
    required this.description,
    this.icon,
  });

  factory AchievementDto.fromJson(Map<String, dynamic> json) {
    return AchievementDto(
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'icon': icon,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AchievementDto) return false;
    return key == other.key &&
        title == other.title &&
        description == other.description &&
        icon == other.icon;
  }

  @override
  int get hashCode => Object.hash(key, title, description, icon);
}

class ProfileDto {
  final String id;
  final String name;
  final String email;
  final List<String> tags;
  final int recipesCount;
  final int favoritesCount;
  final int likesCount;
  final String avatarUrl;
  final List<RecipePreviewDto> recentRecipes;
  final List<AchievementDto> achievements;

  ProfileDto({
    required this.id,
    required this.name,
    required this.email,
    required this.tags,
    required this.recipesCount,
    required this.favoritesCount,
    required this.likesCount,
    required this.avatarUrl,
    required this.recentRecipes,
    required this.achievements,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      tags: List<String>.from(json['tags'] as List),
      recipesCount: json['recipesCount'] as int,
      favoritesCount: json['favoritesCount'] as int,
      likesCount: json['likesCount'] as int,
      avatarUrl: json['avatarUrl'] as String,
      recentRecipes: (json['recentRecipes'] as List)
          .map((e) => RecipePreviewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List)
          .map((e) => AchievementDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tags': tags,
      'recipesCount': recipesCount,
      'favoritesCount': favoritesCount,
      'likesCount': likesCount,
      'avatarUrl': avatarUrl,
      'recentRecipes':
          recentRecipes.map((e) => e.toJson()).toList(),
      'achievements':
          achievements.map((e) => e.toJson()).toList(),
    };
  }

  ProfileDto copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? tags,
    int? recipesCount,
    int? favoritesCount,
    int? likesCount,
    String? avatarUrl,
    List<RecipePreviewDto>? recentRecipes,
    List<AchievementDto>? achievements,
  }) {
    return ProfileDto(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tags: tags ?? this.tags,
      recipesCount: recipesCount ?? this.recipesCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      likesCount: likesCount ?? this.likesCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      recentRecipes: recentRecipes ?? this.recentRecipes,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileDto) return false;
    return mapEquals(toJson(), other.toJson());
  }

  @override
  int get hashCode => Object.hashAll(toJson().values);
}
