// lib/common/models/instruction_step.dart

import 'package:flutter/foundation.dart';

/// Represents a single step within a recipe's instructions.
class InstructionStep {
  final int number;
  final String step; 
  final List<String> ingredients;
  final List<String> equipment;
  final LengthDetail? duration;

  const InstructionStep({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
    this.duration,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    List<String> parseNamedList(dynamic jsonList) {
      if (jsonList is List) {
        return jsonList.map((item) {
          if (item is String) {
            return item;
          } else if (item is Map<String, dynamic> && item.containsKey('name')) {
            return item['name'].toString();
          }
          return '';
        }).where((item) => item.isNotEmpty).toList();
      }
      return [];
    }

    try {
      // Spoonacular doesnt  always provide a 'length' field, so we handle it gracefully
      // and parse it only if it exists and is a valid JSON object.
      final lengthJson = json['length'];
      final LengthDetail? parsedLength = lengthJson != null && lengthJson is Map<String, dynamic>
          ? LengthDetail.fromJson(lengthJson)
          : null;

      return InstructionStep(
        number: json['number'] as int,
        step: json['step'] as String? ?? '',
        ingredients: parseNamedList(json['ingredients']),
        equipment: parseNamedList(json['equipment']),
        duration: parsedLength,
      );
    } catch (e, st) {
      debugPrint('Error parsing InstructionStep ${json['number']}: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'InstructionStep(number: $number, step: $step, duration: ${duration?.number ?? 'N/A'} ${duration?.unit ?? ''})';
  }
}

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