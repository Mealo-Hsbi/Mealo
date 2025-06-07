import 'package:flutter/foundation.dart';
import 'package:frontend/common/models/recipe/instruction_step.dart';

/// Represents a set of instructions for a recipe, possibly with a name (e.g., "Preparation").
class AnalyzedInstructionSet {
  final String? name;
  final List<InstructionStep> steps;

  const AnalyzedInstructionSet({
    this.name,
    required this.steps,
  });

  factory AnalyzedInstructionSet.fromJson(Map<String, dynamic> json) {
    List<InstructionStep> parseSteps(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList
            .whereType<Map<String, dynamic>>() // Ensure items are maps
            .map(InstructionStep.fromJson)
            .toList();
      }
      return [];
    }

    try {
      return AnalyzedInstructionSet(
        name: json['name'] as String?,
        steps: parseSteps(json['steps']),
      );
    } catch (e, st) {
      debugPrint('Error parsing AnalyzedInstructionSet: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'AnalyzedInstructionSet(name: $name, steps: ${steps.length})';
  }
}