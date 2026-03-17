import 'package:flutter/material.dart';
import '../models/ingredient_analysis.dart';

/// A small chip/badge showing the safety level with color and label
class TrafficLightBadge extends StatelessWidget {
  final SafetyLevel level;
  final bool compact;

  const TrafficLightBadge({
    Key? key,
    required this.level,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 8 : 10,
            height: compact ? 8 : 10,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _dotColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (level) {
      case SafetyLevel.green:
        return 'Safe';
      case SafetyLevel.yellow:
        return 'Caution';
      case SafetyLevel.red:
        return 'Concern';
    }
  }

  Color get _dotColor {
    switch (level) {
      case SafetyLevel.green:
        return const Color(0xFF34C759);
      case SafetyLevel.yellow:
        return const Color(0xFFFF9500);
      case SafetyLevel.red:
        return const Color(0xFFFF3B30);
    }
  }

  Color get _backgroundColor {
    switch (level) {
      case SafetyLevel.green:
        return const Color(0xFFE8F8EC);
      case SafetyLevel.yellow:
        return const Color(0xFFFFF4E6);
      case SafetyLevel.red:
        return const Color(0xFFFFE5E5);
    }
  }

  Color get _borderColor {
    switch (level) {
      case SafetyLevel.green:
        return const Color(0xFFB4E7C0);
      case SafetyLevel.yellow:
        return const Color(0xFFFFD699);
      case SafetyLevel.red:
        return const Color(0xFFFFB3B3);
    }
  }

  Color get _textColor {
    switch (level) {
      case SafetyLevel.green:
        return const Color(0xFF1B7A2E);
      case SafetyLevel.yellow:
        return const Color(0xFF8A5A00);
      case SafetyLevel.red:
        return const Color(0xFFC41E1E);
    }
  }
}
