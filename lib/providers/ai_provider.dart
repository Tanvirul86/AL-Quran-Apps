import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/ayah.dart';

/// Provider for AI-powered features
class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  
  List<Ayah> _searchResults = [];
  bool _isSearching = false;
  String? _error;
  
  List<Ayah> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get error => _error;

  /// Perform semantic search
  Future<void> semanticSearch(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _aiService.semanticSearch(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to perform semantic search: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Get AI-generated summary for an ayah
  Future<String?> getAyahInsight(int surah, int ayah) async {
    try {
      return await _aiService.getAISummary(surah, ayah);
    } catch (e) {
      return null;
    }
  }
}
