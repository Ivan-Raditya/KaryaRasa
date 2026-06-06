import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
String get geminiApiKey => dotenv.env['GEMINI_API_KEY']!;

Future<List<double>?> generateEmbedding(String teks) async {
  try {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-embedding-001:embedContent?key=$geminiApiKey',
    );
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'models/gemini-embedding-001',
        'content': {
          'parts': [{'text': teks}]
        }
      }),
    );
    debugPrint('Gemini status: ${res.statusCode}');
    debugPrint('Gemini body: ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final values = data['embedding']['values'] as List;
      return values.map((v) => (v as num).toDouble()).toList();
    }
    return null;
  } catch (e) {
    debugPrint('generateEmbedding error: $e');
    return null;
  }
}

/// Shortcut akses Supabase client dari mana saja
SupabaseClient get supabase => Supabase.instance.client;
