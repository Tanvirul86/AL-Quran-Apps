import 'package:flutter/material.dart';

/// Tajweed color-coding service
class TajweedService {
  static final TajweedService _instance = TajweedService._internal();
  factory TajweedService() => _instance;
  TajweedService._internal();

  /// Apply tajweed colors to Arabic text
  String applyTajweedColors(String arabicText) {
    // This is a simplified implementation
    // In production, you'd use proper tajweed rules and color mapping
    
    // Tajweed rules and their colors
    final tajweedRules = {
      // Ghunnah (nasalization) - Green
      'م': Colors.green,
      'ن': Colors.green,
      
      // Qalqalah (echo) - Red
      'ق': Colors.red,
      'ط': Colors.red,
      'ب': Colors.red,
      'ج': Colors.red,
      'د': Colors.red,
      
      // Ikhfa (hiding) - Yellow
      // Idgham (merging) - Blue
      // Iqlab (conversion) - Orange
    };

    // Return text with HTML-like color tags (simplified)
    // In production, use RichText with TextSpan
    return arabicText;
  }

  /// Get tajweed color for a character
  Color? getTajweedColor(String character) {
    final tajweedMap = {
      'م': Colors.green,
      'ن': Colors.green,
      'ق': Colors.red,
      'ط': Colors.red,
      'ب': Colors.red,
      'ج': Colors.red,
      'د': Colors.red,
    };
    return tajweedMap[character];
  }

  /// Check if character has tajweed rule
  bool hasTajweedRule(String character) {
    return getTajweedColor(character) != null;
  }
}
