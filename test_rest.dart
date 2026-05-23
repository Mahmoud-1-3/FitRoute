import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fit_route/core/constants/api_keys.dart';

void main() async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=${ApiKeys.geminiApiKey}&pageSize=100');
  
  final response = await http.get(url);
  final data = jsonDecode(response.body);
  final models = data['models'] as List;
  for (var m in models) {
    if ((m['supportedGenerationMethods'] as List).contains('generateContent')) {
      print(m['name']);
    }
  }
}
