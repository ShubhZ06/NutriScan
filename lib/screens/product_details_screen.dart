import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.black.withOpacity(0.05),
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
              content: Text(
                product['ingredients_text'] ?? 'No ingredients info available',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            // Nutritional Information - Inset Grouped Style
            _buildSection(
              title: 'Nutrition Facts',
              icon: Icons.bar_chart,
              content: Column(
                children: [
                  _buildNutritionRow('Energy',
                      '${product['nutriments']?['energy'] ?? '-'} kcal'),
                  const Divider(height: 20),
                  _buildNutritionRow(
                      'Fat', '${product['nutriments']?['fat'] ?? '-'} g'),
                  const Divider(height: 20),
                  _buildNutritionRow('Carbs',
                      '${product['nutriments']?['carbohydrates'] ?? '-'} g'),
                  const Divider(height: 20),
                  _buildNutritionRow('Proteins',
                      '${product['nutriments']?['proteins'] ?? '-'} g'),
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
}
