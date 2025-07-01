// lib/features/profile/domain/entities/profile_dto.dart

import 'package:flutter/foundation.dart'; // für mapEquals

class RecipePreviewDto {
  final String? id;
  final String? internalId;
  final String? spoonacularId;
  final String imageUrl;
  final String title;

  RecipePreviewDto({
    this.id,
    this.internalId,
    this.spoonacularId,
    required this.imageUrl,
    required this.title,
  });

  factory RecipePreviewDto.fromJson(Map<String, dynamic> json) {
    return RecipePreviewDto(
      id: json['id']?.toString(),
      internalId: (json['internalId'] ?? json['id'])?.toString(),
      spoonacularId: json['spoonacularId']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internalId': internalId,
      'spoonacularId': spoonacularId,
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
  final int pantryCount;

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
    required this.pantryCount,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      recipesCount: json['recipesCount'] is int ? json['recipesCount'] : int.tryParse(json['recipesCount']?.toString() ?? '0') ?? 0,
      favoritesCount: json['favoritesCount'] is int ? json['favoritesCount'] : int.tryParse(json['favoritesCount']?.toString() ?? '0') ?? 0,
      pantryCount: json['pantryCount'] is int ? json['pantryCount'] : int.tryParse(json['pantryCount']?.toString() ?? '0') ?? 0,
      likesCount: json['likesCount'] is int ? json['likesCount'] : int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0,
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      recentRecipes: (json['recentRecipes'] as List?)?.map((e) => RecipePreviewDto.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      achievements: (json['achievements'] as List?)?.map((e) => AchievementDto.fromJson(e as Map<String, dynamic>)).toList() ?? [],
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
      'pantryCount': pantryCount,
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
      pantryCount: pantryCount ?? this.pantryCount,
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
