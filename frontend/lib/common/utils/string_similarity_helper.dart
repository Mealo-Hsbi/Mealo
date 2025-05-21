import 'package:string_similarity/string_similarity.dart';

List<T> filterBySimilarity<T>(
  List<T> items,
  String Function(T) getName,
  String query, {
  double threshold = 0.3,
}) {
  if (query.isEmpty) return [];

  final lowerQuery = query.toLowerCase();

  final scored = items
      .map((item) => MapEntry(item, getName(item).toLowerCase().similarityTo(lowerQuery)))
      .where((entry) => entry.value >= threshold)
      .toList();

  scored.sort((a, b) => b.value.compareTo(a.value));
  return scored.map((e) => e.key).toList();
}
