// lib/common/models/measures.dart

import 'package:flutter/foundation.dart'; // For debugPrint

/// Represents different units of measurement for an ingredient.
class Measures {
  final UnitMeasure? us;
  final UnitMeasure? metric;

  const Measures({
    this.us,
    this.metric,
  });

  factory Measures.fromJson(Map<String, dynamic> json) {
    try {
      return Measures(
        us: json['us'] is Map<String, dynamic>
            ? UnitMeasure.fromJson(json['us'] as Map<String, dynamic>)
            : null,
        metric: json['metric'] is Map<String, dynamic>
            ? UnitMeasure.fromJson(json['metric'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, st) {
      debugPrint('Error parsing Measures: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }
}

/// Represents a unit of measure (e.g., "cup", "gram").
class UnitMeasure {
  final double? amount;
  final String? unitShort;
  final String? unitLong;

  const UnitMeasure({
    this.amount,
    this.unitShort,
    this.unitLong,
  });

  factory UnitMeasure.fromJson(Map<String, dynamic> json) {
    try {
      return UnitMeasure(
        amount: (json['amount'] as num?)?.toDouble(),
        unitShort: json['unitShort'] as String?,
        unitLong: json['unitLong'] as String?,
      );
    } catch (e, st) {
      debugPrint('Error parsing UnitMeasure: $e\nStack: $st. Raw JSON: $json');
      rethrow;
    }
  }
}