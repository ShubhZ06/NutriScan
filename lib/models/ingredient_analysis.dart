/// Safety classification for an ingredient
enum SafetyLevel { green, yellow, red }

/// Represents the AI analysis of a single ingredient
class IngredientAnalysis {
  final String rawName;
  final String commonName;
  final String functionality;
  final SafetyLevel safetyLevel;
  final String safetyExplanation;
  final String? regulatoryNotes;
  final List<String> sensitivityAlerts;
  final List<String> allergens;

  const IngredientAnalysis({
    required this.rawName,
    required this.commonName,
    required this.functionality,
    required this.safetyLevel,
    required this.safetyExplanation,
    this.regulatoryNotes,
    this.sensitivityAlerts = const [],
    this.allergens = const [],
  });

  factory IngredientAnalysis.fromJson(Map<String, dynamic> json) {
    return IngredientAnalysis(
      rawName: json['raw_name'] ?? '',
      commonName: json['common_name'] ?? '',
      functionality: json['functionality'] ?? '',
      safetyLevel: parseSafetyLevel(json['safety_level'] ?? 'green'),
      safetyExplanation: json['safety_explanation'] ?? '',
      regulatoryNotes: json['regulatory_notes'],
      sensitivityAlerts: List<String>.from(json['sensitivity_alerts'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
    );
  }

  static SafetyLevel parseSafetyLevel(String level) {
    switch (level.toLowerCase()) {
      case 'red':
        return SafetyLevel.red;
      case 'yellow':
        return SafetyLevel.yellow;
      case 'green':
      default:
        return SafetyLevel.green;
    }
  }
}

/// Represents the full AI analysis of all ingredients in a product
class ProductAnalysis {
  final List<IngredientAnalysis> ingredients;
  final String quickTakeaway;
  final SafetyLevel overallVerdict;
  final DateTime analyzedAt;

  const ProductAnalysis({
    required this.ingredients,
    required this.quickTakeaway,
    required this.overallVerdict,
    required this.analyzedAt,
  });

  /// Convenience getters
  List<IngredientAnalysis> get redIngredients =>
      ingredients.where((i) => i.safetyLevel == SafetyLevel.red).toList();

  List<IngredientAnalysis> get yellowIngredients =>
      ingredients.where((i) => i.safetyLevel == SafetyLevel.yellow).toList();

  List<IngredientAnalysis> get greenIngredients =>
      ingredients.where((i) => i.safetyLevel == SafetyLevel.green).toList();

  /// Sorted: red first, then yellow, then green
  List<IngredientAnalysis> get sortedIngredients {
    final sorted = List<IngredientAnalysis>.from(ingredients);
    sorted.sort((a, b) {
      const order = {
        SafetyLevel.red: 0,
        SafetyLevel.yellow: 1,
        SafetyLevel.green: 2
      };
      return order[a.safetyLevel]!.compareTo(order[b.safetyLevel]!);
    });
    return sorted;
  }
}
