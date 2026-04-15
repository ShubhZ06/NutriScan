import 'package:flutter/material.dart';
import 'ingredient_analysis_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingredientsText = (product['ingredients_text'] ?? '').toString();
    final ingredientItems = _parseIngredients(ingredientsText);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      appBar: AppBar(
        title: Text(
          product['product_name'] ?? 'Details',
          style: const TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Product Image Section
            if (product['image_url'] != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Hero(
                      tag: product['product_name'] ?? 'product_image',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          product['image_url'],
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['product_name'] ?? 'Unknown Product',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (product['brands'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        product['brands'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Ingredients Section - Inset Grouped Style
            _buildSection(
              title: 'Ingredients',
              icon: Icons.restaurant_menu,
              content: _buildStructuredIngredients(
                rawText: ingredientsText,
                ingredients: ingredientItems,
              ),
            ),

            // ✨ Simplify Ingredients Button
            if (ingredientsText.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IngredientAnalysisScreen(
                          ingredientsText: ingredientsText,
                          productName:
                              product['product_name'] ?? 'Unknown Product',
                          imageUrl: product['image_url'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Simplify Ingredients',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Nutritional Information - Inset Grouped Style
            _buildSection(
              title: 'Nutrition Facts',
              icon: Icons.bar_chart,
              content: Column(
                children: [
                  _buildNutritionRow('Energy', _formatEnergyValue()),
                  const Divider(height: 20),
                  _buildNutritionRow('Fat', _formatGramValue('fat')),
                  const Divider(height: 20),
                  _buildNutritionRow(
                      'Carbs', _formatGramValue('carbohydrates')),
                  const Divider(height: 20),
                  _buildNutritionRow('Proteins', _formatGramValue('proteins')),
                ],
              ),
            ),

            // Allergens Section
            if (product['allergens'] != null &&
                (product['allergens'] as String).isNotEmpty)
              _buildSection(
                title: 'Allergens',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.red,
                content: Text(
                  product['allergens'],
                  style: const TextStyle(
                      fontSize: 16, color: Colors.redAccent, height: 1.5),
                ),
              ),

            // Additional Info
            _buildSection(
              title: 'More Info',
              icon: Icons.info_outline,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product['packaging'] != null) ...[
                    Text('Packaging: ${product['packaging']}',
                        style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 10),
                  ],
                  if (product['recommendations'] != null)
                    Text('Recommendations: ${product['recommendations']}',
                        style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
    Color iconColor = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon,
                    color: iconColor == Colors.black
                        ? const Color(0xFF007AFF)
                        : iconColor,
                    size: 22), // Blue icon by default, Apple style
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStructuredIngredients({
    required String rawText,
    required List<String> ingredients,
  }) {
    if (rawText.trim().isEmpty) {
      return const Text(
        'No ingredients info available',
        style: TextStyle(fontSize: 15, color: Colors.black54),
      );
    }

    final additives = _extractInsCodes(rawText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoChip('${ingredients.length} ingredients'),
            if (additives.isNotEmpty)
              _infoChip('${additives.length} INS additives'),
          ],
        ),
        const SizedBox(height: 12),
        ...ingredients.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(Icons.circle, size: 8, color: Color(0xFF007AFF)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 15, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (additives.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Detected INS additives',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: additives.map((code) => _infoChip(code)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF005EC2),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<String> _parseIngredients(String text) {
    if (text.trim().isEmpty) return const [];

    final normalized =
        text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    int depth = 0;

    for (int i = 0; i < normalized.length; i++) {
      final char = normalized[i];

      if (char == '(' || char == '[' || char == '{') {
        depth++;
      } else if (char == ')' || char == ']' || char == '}') {
        depth = depth > 0 ? depth - 1 : 0;
      }

      if (char == ',' && depth == 0) {
        final entry = current.toString().trim();
        if (entry.isNotEmpty) result.add(_cleanIngredient(entry));
        current.clear();
      } else {
        current.write(char);
      }
    }

    final last = current.toString().trim();
    if (last.isNotEmpty) result.add(_cleanIngredient(last));

    return result;
  }

  String _cleanIngredient(String value) {
    return value
        .replaceAll(RegExp(r'^\*+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _extractInsCodes(String text) {
    final matches = RegExp(r'INS\s*\d+[A-Z]?', caseSensitive: false)
        .allMatches(text)
        .map((m) => m.group(0)!.toUpperCase().replaceAll(RegExp(r'\s+'), ' '))
        .toSet()
        .toList();
    matches.sort();
    return matches;
  }

  dynamic _nutrimentValue(String key) {
    final nutriments = product['nutriments'];
    if (nutriments is! Map) return null;

    return nutriments[key] ??
        nutriments['${key}_100g'] ??
        nutriments[key.replaceAll('-', '_')] ??
        nutriments['${key.replaceAll('-', '_')}_100g'];
  }

  String _formatEnergyValue() {
    final kcal = _asNum(_nutrimentValue('energy-kcal'));
    final kj = _asNum(_nutrimentValue('energy-kj'));

    if (kcal != null && kj != null) {
      return '${_formatNum(kcal)} kcal (${_formatNum(kj)} kJ)';
    }
    if (kcal != null) return '${_formatNum(kcal)} kcal';
    if (kj != null) return '${_formatNum(kj)} kJ';

    final rawEnergy = _asNum(_nutrimentValue('energy'));
    if (rawEnergy != null) return '${_formatNum(rawEnergy)} kJ';
    return '-';
  }

  String _formatGramValue(String key) {
    final value = _asNum(_nutrimentValue(key));
    return value == null ? '-' : '${_formatNum(value)} g';
  }

  num? _asNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  String _formatNum(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
