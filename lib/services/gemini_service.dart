import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ingredient_analysis.dart';

class GeminiQuotaException implements Exception {
  final String message;
  const GeminiQuotaException(this.message);

  @override
  String toString() => message;
}

class GeminiConfigurationException implements Exception {
  final String message;
  const GeminiConfigurationException(this.message);

  @override
  String toString() => message;
}

/// AI simplification engine using Google Gemini.
class GeminiService {
  GenerativeModel? _model;

  String get _modelName {
    final configured = dotenv.env['GEMINI_MODEL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    return 'gemini-2.5-flash';
  }

  GenerativeModel get model {
    _model ??= GenerativeModel(
      model: _modelName,
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );
    return _model!;
  }

  /// Analyze ingredients using Gemini AI and return structured analysis.
  Future<ProductAnalysis> analyzeIngredients(
    String ingredientsText,
    String productName,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.trim().isEmpty) {
      throw const GeminiConfigurationException(
        'Gemini API key is missing. Add GEMINI_API_KEY to your .env file.',
      );
    }

    final prompt = '''
You are a food safety and nutrition expert. Analyze the following ingredients list from the product "$productName".

INGREDIENTS: $ingredientsText

For EACH ingredient, provide:
1. **raw_name**: The original ingredient name exactly as listed
2. **common_name**: A simple, everyday name (e.g., "Titanium Dioxide" -> "White Food Pigment")
3. **functionality**: Why this ingredient is used in the product (1 sentence)
4. **safety_level**: One of "green", "yellow", or "red":
   - "green": Natural or Generally Recognized As Safe (GRAS), minimal concerns
   - "yellow": Processed additive that is approved but has known side effects or sensitivities
   - "red": Controversial, banned in some regions, or flagged by health organizations
5. **safety_explanation**: One-sentence explanation of the safety classification
6. **regulatory_notes**: If banned or restricted in any country/region, mention it. Otherwise null.
7. **sensitivity_alerts**: List of sensitivity warnings. Empty list if none.
8. **allergens**: List of allergen flags. Empty list if none.

Also provide:
- **quick_takeaway**: A 1-2 sentence consumer-friendly summary
- **overall_verdict**: "green", "yellow", or "red"

Respond ONLY with valid JSON in this exact format:
{
  "ingredients": [
    {
      "raw_name": "...",
      "common_name": "...",
      "functionality": "...",
      "safety_level": "green|yellow|red",
      "safety_explanation": "...",
      "regulatory_notes": "..." or null,
      "sensitivity_alerts": ["..."],
      "allergens": ["..."]
    }
  ],
  "quick_takeaway": "...",
  "overall_verdict": "green|yellow|red"
}
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      if (text.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      String jsonString = text;
      final jsonMatch =
          RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
      if (jsonMatch != null) {
        jsonString = jsonMatch.group(1)!.trim();
      } else {
        final braceStart = text.indexOf('{');
        final braceEnd = text.lastIndexOf('}');
        if (braceStart != -1 && braceEnd != -1) {
          jsonString = text.substring(braceStart, braceEnd + 1);
        }
      }

      final parsed = json.decode(jsonString) as Map<String, dynamic>;

      final ingredients = (parsed['ingredients'] as List<dynamic>)
          .map((e) => IngredientAnalysis.fromJson(e as Map<String, dynamic>))
          .toList();

      return ProductAnalysis(
        ingredients: ingredients,
        quickTakeaway: parsed['quick_takeaway'] ?? 'No summary available.',
        overallVerdict: IngredientAnalysis.parseSafetyLevel(
          parsed['overall_verdict'] ?? 'green',
        ),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      final normalized = e.toString().toLowerCase();
      final isQuotaError = normalized.contains('resource_exhausted') ||
          normalized.contains('quota') ||
          normalized.contains('rate limit') ||
          normalized.contains('429');

      if (isQuotaError) {
        final retrySeconds = _extractRetrySeconds(e.toString());
        final retryMessage = retrySeconds != null
            ? ' Please retry in about ${retrySeconds.ceil()} seconds.'
            : '';

        throw GeminiQuotaException(
          'Gemini API quota exceeded.$retryMessage Check your Gemini plan/billing or wait for the quota window to reset.',
        );
      }

      throw Exception('Failed to analyze ingredients: $e');
    }
  }

  double? _extractRetrySeconds(String errorText) {
    final match = RegExp(r'retry in\s+([0-9]*\.?[0-9]+)s', caseSensitive: false)
        .firstMatch(errorText);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}
