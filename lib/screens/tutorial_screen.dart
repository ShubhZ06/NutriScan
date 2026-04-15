import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  static const String _tutorialDoneKey = 'tutorial_completed_v1';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scan Products Instantly',
      subtitle:
          'Point your camera at any barcode to fetch ingredients and nutrition details in seconds.',
      accent: Color(0xFF34C759),
      bullets: [
        'Fast barcode scanner',
        'Open Food Facts data lookup',
        'One-tap product details',
      ],
    ),
    _OnboardingStep(
      icon: Icons.document_scanner_rounded,
      title: 'Read Labels with OCR',
      subtitle:
          'If a product is missing from the database, scan the ingredient label directly from camera or gallery.',
      accent: Color(0xFF007AFF),
      bullets: [
        'Camera and gallery support',
        'Automatic text extraction',
        'Built-in fallback flow',
      ],
    ),
    _OnboardingStep(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Ingredient Analysis',
      subtitle:
          'Get clear safety insights for each ingredient with plain language explanations and traffic-light verdicts.',
      accent: Color(0xFFFF9500),
      bullets: [
        'Green / yellow / red risk levels',
        'Allergen and sensitivity highlights',
        'Quick takeaway summary',
      ],
    ),
    _OnboardingStep(
      icon: Icons.person_rounded,
      title: 'Build Your Health Profile',
      subtitle:
          'Store age, conditions, allergens, and dietary preferences to make recommendations more personalized.',
      accent: Color(0xFFAF52DE),
      bullets: [
        'Profile and history tabs',
        'Local privacy-first storage',
        'Smarter future guidance',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialDoneKey, true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth-gate');
  }

  void _nextPage() {
    if (_currentPage >= _steps.length - 1) {
      _completeTutorial();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'NutriScan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeTutorial,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _OnboardingCard(
                        step: step, index: index, total: _steps.length);
                  },
                ),
              ),
              const SizedBox(height: 18),
              SmoothPageIndicator(
                controller: _pageController,
                count: _steps.length,
                effect: WormEffect(
                  activeDotColor: _steps[_currentPage].accent,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 9,
                  dotWidth: 9,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentPage == 0 ? null : _previousPage,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child:
                          Text(isLastPage ? 'Start Using NutriScan' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingStep step;
  final int index;
  final int total;

  const _OnboardingCard({
    required this.step,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            step.accent.withValues(alpha: 0.18),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP ${index + 1} OF $total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: step.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(step.icon, color: step.accent, size: 34),
          ),
          const SizedBox(height: 22),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.subtitle,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          ...step.bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded,
                        color: step.accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<String> bullets;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.bullets,
  });
}
