import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for interacting with the Open Food Facts API
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// Fetch a product by barcode (GTIN/UPC)
  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v0/product/$barcode.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['product'] != null) {
        return data['product'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// Search products by name
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cgi/search.pl?search_terms=$query&json=true'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>? ?? [];
      return products.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
