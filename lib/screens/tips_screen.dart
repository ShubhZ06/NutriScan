import 'dart:math';
import 'package:flutter/material.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({Key? key}) : super(key: key);

  @override
  _TipsScreenState createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final List<String> funFacts = [
    "Dark chocolate contains antioxidants that are good for heart health!",
    "Bananas can boost your mood due to their serotonin precursors.",
    "Carrots can help improve night vision due to Vitamin A.",
    "Eating nuts daily can reduce the risk of heart disease.",
    "Watermelon helps keep you hydrated and supports muscle recovery.",
    "Leafy greens can slow down cognitive decline as you age.",
    "Avocados are loaded with heart-healthy monounsaturated fats.",
    "Eating eggs can boost brain function due to choline content.",
    "Salmon is rich in omega-3s, which support brain health.",
    "Spicy foods can boost metabolism and aid in weight loss."
  ];

  String currentFunFact = "Dark chocolate contains antioxidants that are good for heart health!"; // Default Fact

  @override
  void initState() {
    super.initState();
    _updateFunFact();
  }

  void _updateFunFact() {
    setState(() {
      currentFunFact = funFacts[Random().nextInt(funFacts.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tips'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              _buildTipCard(
                icon: Icons.local_drink,
                title: "Calcium Needs",
                description: "The recommended daily intake of calcium is 1000 mg for most adults.",
                foodSources: ["Milk", "Cheese", "Leafy Greens", "Almonds"],
              ),
              _buildTipCard(
                icon: Icons.local_fire_department,
                title: "Caloric Intake",
                description: "The average adult needs about 2000-2500 calories per day, depending on activity level.",
                foodSources: ["Rice", "Bread", "Meat", "Nuts"],
              ),
              _buildTipCard(
                icon: Icons.eco,
                title: "Essential Nutrients",
                description: "A balanced diet includes vitamins, minerals, protein, and healthy fats.",
                foodSources: ["Fruits", "Vegetables", "Whole Grains", "Legumes"],
              ),
              _buildTipCard(
                icon: Icons.water_drop,
                title: "Stay Hydrated",
                description: "Drink at least 8 glasses of water daily to maintain good health.",
                foodSources: ["Water", "Fruits", "Herbal Teas", "Coconut Water"],
              ),
              _buildTipCard(
                icon: Icons.lightbulb,
                title: "Fun Nutrition Fact",
                description: currentFunFact,
                foodSources: ["Dark Chocolate", "Berries", "Nuts", "Green Tea"],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateFunFact,
                child: const Text("Get New Fun Fact"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> foodSources,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: foodSources.map((food) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      food,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
