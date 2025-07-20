import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['product_name'] ?? 'Product Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (if available)
            if (product['image_url'] != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product['image_url'],
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Product Name
            Text(
              product['product_name'] ?? 'Unknown Product',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Brand
            Text(
              'Brand: ${product['brands'] ?? 'Not Available'}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 10),

            // Ingredients
            Text(
              'Ingredients:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              product['ingredients_text'] ?? 'No ingredients info available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Nutritional Information
            const Text(
              'Nutritional Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔹 Energy: ${product['nutriments']?['energy'] ?? 'N/A'} kcal'),
                    Text('🔹 Fat: ${product['nutriments']?['fat'] ?? 'N/A'} g'),
                    Text('🔹 Carbohydrates: ${product['nutriments']?['carbohydrates'] ?? 'N/A'} g'),
                    Text('🔹 Proteins: ${product['nutriments']?['proteins'] ?? 'N/A'} g'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Harmful Substances
            const Text(
              '⚠️ Potential Allergens:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red),
            ),
            Text(
              product['allergens'] ?? 'No harmful substances detected',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Packaging
            Text(
              '📦 Packaging: ${product['packaging'] ?? 'No packaging info available'}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Recommendations
            Text(
              '💡 Recommendations:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              product['recommendations'] ?? 'No recommendations available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
