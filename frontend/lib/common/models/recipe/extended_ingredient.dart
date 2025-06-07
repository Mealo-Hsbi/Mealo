import 'package:flutter/foundation.dart'; 
import 'package:frontend/common/models/measures/measures.dart';

/// Represents a detailed ingredient in a recipe.
class ExtendedIngredient {
  final int id;
  final String? aisle;
  final String? image;
  final String? consistency;
  final String name;
  final String original;
  final String? originalName;
  final double? amount;
  final String? unit;
  final List<String>? meta;
  final Measures? measures;

  const ExtendedIngredient({
    required this.id,
    this.aisle,
    this.image,
    this.consistency,
    required this.name,
    required this.original,
    this.originalName,
    this.amount,
    this.unit,
    this.meta,
    this.measures,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    try {
      return ExtendedIngredient(
        id: json['id'] as int,
        aisle: json['aisle'] as String?,
        image: json['image'] as String?,
        consistency: json['consistency'] as String?,
        name: json['name'] as String? ?? '',
        original: json['original'] as String? ?? '',
        originalName: json['originalName'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        meta: (json['meta'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        measures: json['measures'] is Map<String, dynamic>
            ? Measures.fromJson(json['measures'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, st) {
      debugPrint('Error parsing ExtendedIngredient: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'ExtendedIngredient(name: $name, amount: $amount ${unit ?? ''})';
  }
}