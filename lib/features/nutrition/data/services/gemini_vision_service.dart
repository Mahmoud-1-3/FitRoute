import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/constants/api_keys.dart';

class AiMealItem {
  final String name;
  final int calories;

  AiMealItem({required this.name, required this.calories});

  factory AiMealItem.fromJson(Map<String, dynamic> json) {
    return AiMealItem(
      name: json['name'] as String? ?? 'Unknown Item',
      calories: json['calories'] as int? ?? 0,
    );
  }
}

class AiPlateAnalysis {
  final int totalCalories;
  final int totalCarbs;
  final int totalProtein;
  final int totalFat;
  final String feedback;
  final List<AiMealItem> items;

  AiPlateAnalysis({
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    required this.feedback,
    required this.items,
  });

  factory AiPlateAnalysis.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return AiPlateAnalysis(
      totalCalories: json['totalCalories'] as int? ?? 0,
      totalCarbs: json['totalCarbs'] as int? ?? 0,
      totalProtein: json['totalProtein'] as int? ?? 0,
      totalFat: json['totalFat'] as int? ?? 0,
      feedback: json['feedback'] as String? ?? 'Keep up the good work!',
      items: itemsList.map((e) => AiMealItem.fromJson(e)).toList(),
    );
  }
}

class GeminiVisionService {
  final GenerativeModel _model;

  GeminiVisionService()
      : _model = GenerativeModel(
          model: 'gemini-flash-latest',
          apiKey: ApiKeys.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<AiPlateAnalysis> analyzePlate(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final prompt = TextPart(
      "Analyze this image of a user's meal. Estimate the total macronutrients for the entire plate. Provide exactly ONE short, highly encouraging sentence of feedback. Then, break down the visible meal into its individual components (e.g., Chicken, Rice, Broccoli) and estimate the calories for each. You must respond ONLY with a valid JSON object using this exact structure: { 'totalCalories': int, 'totalCarbs': int, 'totalProtein': int, 'totalFat': int, 'feedback': string, 'items': [ {'name': string, 'calories': int} ] }",
    );
    final imagePart = DataPart('image/jpeg', bytes); // Using jpeg as general mime

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    if (response.text == null || response.text!.isEmpty) {
      throw Exception('Empty response from AI.');
    }

    try {
      final jsonResponse = jsonDecode(response.text!);
      return AiPlateAnalysis.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}

final geminiVisionServiceProvider = Provider<GeminiVisionService>((ref) {
  return GeminiVisionService();
});
