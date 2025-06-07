// lib/common/models/instruction_step.dart

import 'package:flutter/foundation.dart'; // For debugPrint

/// Represents a single step within a recipe's instructions.
class InstructionStep {
  final int number;
  final String step; // Can contain HTML
  final List<String> ingredients; // Names of ingredients mentioned in this step
  final List<String> equipment; // Names of equipment mentioned in this step

  const InstructionStep({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    // Helper to parse lists where items can be String or Map<String, dynamic> with 'name'
    List<String> parseNamedList(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) {
          if (item is String) {
            return item;
          } else if (item is Map<String, dynamic> && item.containsKey('name')) {
            return item['name'].toString();
          }
          return ''; // Return empty string for unparsable items
        }).where((item) => item.isNotEmpty).toList(); // Filter out empty strings
      }
      return [];
    }

    try {
      return InstructionStep(
        number: json['number'] as int,
        step: json['step'] as String? ?? '',
        ingredients: parseNamedList(json['ingredients']),
        equipment: parseNamedList(json['equipment']),
      );
    } catch (e, st) {
      debugPrint('Error parsing InstructionStep ${json['number']}: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'InstructionStep(number: $number, step: $step)';
  }
}