import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';
import 'dart:ui';
import 'product_details_screen.dart';
import 'scan_history_screen.dart';
import 'about_us_screen.dart';
import 'tips_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchProduct(String productName) async {
    try {
      setState(() => _isLoading = true);
      final response = await http.get(Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$productName&json=true'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['products'] ?? [];
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> searchHistory =
            prefs.getStringList('search_history') ?? [];
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
        final response = await http.get(Uri.parse(
            'https://world.openfoodfacts.org/api/v0/product/${result.rawContent}.json'));
        if (response.statusCode == 200) {
          final productData = json.decode(response.body);
          if (productData['product'] != null) {
            final product = productData['product'];

            // Save to Firestore
            await _firestoreService.addScan(product);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: product)),
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
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF2F2F7),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'NutriScan',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 28, // Large Title size
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.blue),
                onPressed: () async {
                  await _authService.signOut();
                },
              ),
            ],
          ),
          SliverLoginHeader(), // Just a placeholder for clean code structure if needed, but proceeding inline
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E8), // iOS Search Bar Grey
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search for a product',
                        hintStyle:
                            TextStyle(color: Colors.grey[600], fontSize: 17),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[600], size: 22),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          color: Theme.of(context).primaryColor,
                          onPressed: () =>
                              _searchProduct(_searchController.text),
                        ),
                      ),
                      onSubmitted: (value) => _searchProduct(value),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scan Button - Hero/Prominent
                  GestureDetector(
                    onTap: _scanProduct,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Scan Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap to start scanning',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_searchResults.isNotEmpty) ...[
                    Text(
                      'Results',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._searchResults.map((product) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsScreen(product: product)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product['image_url'] ?? '',
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 60,
                                        width: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['product_name'] ??
                                              'Unknown Product',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product['brands'] ?? 'No brand info',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: const Border(
              top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedItemColor: Colors.grey,
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScanHistoryScreen()));
                } else if (index == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TipsScreen()));
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: 'History'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.lightbulb), label: 'Tips'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SliverLoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Container());
  }
}
