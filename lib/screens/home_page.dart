import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';
import 'product_details_screen.dart';
import 'scan_history_screen.dart';
import 'about_us_screen.dart';
import 'tips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchProduct(String productName) async {
    try {
      setState(() => _isLoading = true);
      final response = await http.get(Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&json=true'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['products'] ?? [];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> searchHistory = prefs.getStringList('search_history') ?? [];
        searchHistory.add(productName);
        await prefs.setStringList('search_history', searchHistory);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanProduct() async {
    setState(() => _isLoading = true);
    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        final response = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/${result.rawContent}.json'));
        if (response.statusCode == 200) {
          final productData = json.decode(response.body);
          if (productData['product'] != null) {
            final product = productData['product'];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String> history = prefs.getStringList('scan_history') ?? [];
            history.add(json.encode(product));
            await prefs.setStringList('scan_history', history);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product not found')),
            );
          }
        } else {
          throw Exception('Failed to load product details');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriScan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _scanProduct,
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('Scan a Product', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a product',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchProduct(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading && _searchResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      leading: Image.network(product['image_url'] ?? '', height: 50, width: 50, fit: BoxFit.cover),
                      title: Text(product['product_name'] ?? 'Unknown Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(product['brands'] ?? 'No brand info'),
                      trailing: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
                        ),
                        child: const Text('More Info'),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanHistoryScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Tips'),
        ],
      ),
    );
  }
}