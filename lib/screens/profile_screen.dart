import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _profileKey = 'user_profile_v1';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergensController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  final TextEditingController _dietaryNotesController = TextEditingController();

  String _gender = 'Prefer not to say';
  bool _hasDiabetes = false;
  bool _hasHypertension = false;
  bool _isPregnant = false;
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergensController.dispose();
    _medicalConditionsController.dispose();
    _dietaryNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);

    if (jsonString == null || jsonString.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;

      _nameController.text = (map['name'] ?? '').toString();
      _ageController.text = (map['age'] ?? '').toString();
      _heightController.text = (map['heightCm'] ?? '').toString();
      _weightController.text = (map['weightKg'] ?? '').toString();
      _allergensController.text = (map['allergens'] ?? '').toString();
      _medicalConditionsController.text =
          (map['medicalConditions'] ?? '').toString();
      _dietaryNotesController.text = (map['dietaryNotes'] ?? '').toString();
      _gender = (map['gender'] ?? _gender).toString();
      _hasDiabetes = map['hasDiabetes'] == true;
      _hasHypertension = map['hasHypertension'] == true;
      _isPregnant = map['isPregnant'] == true;
      _isVegetarian = map['isVegetarian'] == true;
      _isVegan = map['isVegan'] == true;
    } catch (_) {
      // Ignore corrupted profile payload and continue with defaults.
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final profile = {
      'name': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      'heightCm': _heightController.text.trim(),
      'weightKg': _weightController.text.trim(),
      'allergens': _allergensController.text.trim(),
      'medicalConditions': _medicalConditionsController.text.trim(),
      'dietaryNotes': _dietaryNotesController.text.trim(),
      'gender': _gender,
      'hasDiabetes': _hasDiabetes,
      'hasHypertension': _hasHypertension,
      'isPregnant': _isPregnant,
      'isVegetarian': _isVegetarian,
      'isVegan': _isVegan,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_profileKey, json.encode(profile));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionCard(
                    title: 'Basic Information',
                    children: [
                      _textField(_nameController, 'Name'),
                      const SizedBox(height: 12),
                      _textField(
                        _ageController,
                        'Age',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: _inputDecoration('Gender'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Prefer not to say',
                              child: Text('Prefer not to say')),
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'Female', child: Text('Female')),
                          DropdownMenuItem(
                              value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _gender = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'Body Metrics',
                    children: [
                      _textField(
                        _heightController,
                        'Height (cm)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _weightController,
                        'Weight (kg)',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'Health Flags',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Diabetes'),
                        value: _hasDiabetes,
                        onChanged: (value) {
                          setState(() => _hasDiabetes = value);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hypertension'),
                        value: _hasHypertension,
                        onChanged: (value) {
                          setState(() => _hasHypertension = value);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pregnancy'),
                        value: _isPregnant,
                        onChanged: (value) {
                          setState(() => _isPregnant = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'Diet Preferences',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Vegetarian'),
                        value: _isVegetarian,
                        onChanged: (value) {
                          setState(() => _isVegetarian = value);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Vegan'),
                        value: _isVegan,
                        onChanged: (value) {
                          setState(() => _isVegan = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'Safety & Medical Details',
                    children: [
                      _textField(
                        _allergensController,
                        'Known allergens (comma separated)',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _medicalConditionsController,
                        'Other medical conditions',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _dietaryNotesController,
                        'Dietary notes / restrictions',
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Profile'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your profile is stored locally on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF7F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
