import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ingredient_analysis.dart';
import '../services/gemini_service.dart';
import '../widgets/traffic_light_badge.dart';
import '../widgets/ingredient_card.dart';

/// Screen showing AI-analyzed ingredient breakdown with traffic light system
class IngredientAnalysisScreen extends StatefulWidget {
  final String ingredientsText;
  final String productName;
  final String? imageUrl;

  const IngredientAnalysisScreen({
    Key? key,
    required this.ingredientsText,
    required this.productName,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<IngredientAnalysisScreen> createState() =>
      _IngredientAnalysisScreenState();
}

class _IngredientAnalysisScreenState extends State<IngredientAnalysisScreen> {
  final GeminiService _geminiService = GeminiService();
  ProductAnalysis? _analysis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyzeIngredients();
  }

  Future<void> _analyzeIngredients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final analysis = await _geminiService.analyzeIngredients(
        widget.ingredientsText,
        widget.productName,
      );

      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Ingredient Analysis',
          style: GoogleFonts.inter(
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
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildAnalysisContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated scanning icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF34C759).withValues(alpha: 0.2),
                    const Color(0xFF007AFF).withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 40,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing ingredients...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is simplifying ${widget.productName}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _analyzeIngredients,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    final analysis = _analysis!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header with overall verdict
          _buildProductHeader(analysis),
          const SizedBox(height: 16),

          // Quick Takeaway Card
          _buildQuickTakeaway(analysis),
          const SizedBox(height: 20),

          // Summary Stats
          _buildSummaryStats(analysis),
          const SizedBox(height: 20),

          // Ingredient List Header
          Row(
            children: [
              Text(
                'Ingredients Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                '${analysis.ingredients.length} items',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sorted ingredient cards
          ...analysis.sortedIngredients
              .map((ing) => IngredientCard(ingredient: ing)),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProductHeader(ProductAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product icon or image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _verdictColor(analysis.overallVerdict).withValues(alpha: 0.2),
                  _verdictColor(analysis.overallVerdict).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.science,
              color: _verdictColor(analysis.overallVerdict),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                TrafficLightBadge(level: analysis.overallVerdict),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTakeaway(ProductAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF007AFF).withValues(alpha: 0.08),
            const Color(0xFF5856D6).withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF007AFF).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF007AFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Quick Takeaway',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007AFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            analysis.quickTakeaway,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(ProductAnalysis analysis) {
    return Row(
      children: [
        _buildStatCard(
          '${analysis.greenIngredients.length}',
          'Safe',
          const Color(0xFF34C759),
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${analysis.yellowIngredients.length}',
          'Caution',
          const Color(0xFFFF9500),
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${analysis.redIngredients.length}',
          'Concern',
          const Color(0xFFFF3B30),
        ),
      ],
    );
  }

  Widget _buildStatCard(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendRow(
            const Color(0xFF34C759),
            'Safe',
            'Natural or generally recognized as safe',
          ),
          const SizedBox(height: 8),
          _buildLegendRow(
            const Color(0xFFFF9500),
            'Caution',
            'Approved but has known side effects',
          ),
          const SizedBox(height: 8),
          _buildLegendRow(
            const Color(0xFFFF3B30),
            'Concern',
            'Controversial or restricted in some regions',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String description) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Color _verdictColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.green:
        return const Color(0xFF34C759);
      case SafetyLevel.yellow:
        return const Color(0xFFFF9500);
      case SafetyLevel.red:
        return const Color(0xFFFF3B30);
    }
  }
}
