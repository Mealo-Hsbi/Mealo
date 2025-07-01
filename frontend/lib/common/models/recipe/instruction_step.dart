// lib/common/models/recipe/instruction_step.dart

import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:html_unescape/html_unescape.dart'; // NEU: Für HTML unescaping

/// Represents a single step within a recipe's instructions.
/// Now includes an optional duration for timer functionality and handles HTML unescaping.
class InstructionStep {
  final int stepNumber;
  final String description;
  final int? durationMinutes;

  InstructionStep({
    required this.stepNumber,
    required this.description,
    this.durationMinutes,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    // Spoonacular: {number, step, length: {number, unit}}
    // Eigenes Backend: {step_number, description, duration_minutes}
    try {
      if (json.containsKey('step_number')) {
        // Eigenes Backend-Format
        return InstructionStep(
          stepNumber: json['step_number'] as int,
          description: json['description'] as String,
          durationMinutes: json['duration_minutes'] as int?,
        );
      } else if (json.containsKey('number') && json.containsKey('step')) {
        // Spoonacular-Format
        int? duration;
        if (json['length'] != null && json['length'] is Map<String, dynamic> && json['length']['number'] != null) {
          duration = json['length']['number'] as int;
        }
        return InstructionStep(
          stepNumber: json['number'] as int,
          description: json['step'] as String,
          durationMinutes: duration,
        );
      } else {
        throw Exception('Unknown instruction step format: ' + json.toString());
      }
    } catch (e, st) {
      debugPrint('Error parsing InstructionStep: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'description': description,
      'duration_minutes': durationMinutes,
    };
  }

  @override
  String toString() {
    return 'InstructionStep(stepNumber: $stepNumber, description: $description, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstructionStep &&
          runtimeType == other.runtimeType &&
          stepNumber == other.stepNumber;

  @override
  int get hashCode => stepNumber.hashCode;

  InstructionStep copyWith({
    int? stepNumber,
    String? description,
    int? durationMinutes,
  }) {
    return InstructionStep(
      stepNumber: stepNumber ?? this.stepNumber,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

/// Repräsentiert die Dauer eines Schrittes (z.B. 10 Minuten)
class LengthDetail {
  final int number;
  final String unit;

  const LengthDetail({
    required this.number,
    required this.unit,
  });

  factory LengthDetail.fromJson(Map<String, dynamic> json) {
    try {
      return LengthDetail(
        number: json['number'] as int,
        unit: json['unit'] as String,
      );
    } catch (e, st) {
      debugPrint('Error parsing LengthDetail: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  int toSeconds() {
    if (unit.toLowerCase().contains('minute')) {
      return number * 60;
    } else if (unit.toLowerCase().contains('hour')) {
      return number * 3600;
    }
    return 0;
  }

  @override
  String toString() {
    return 'LengthDetail(number: $number, unit: $unit)';
  }
}
