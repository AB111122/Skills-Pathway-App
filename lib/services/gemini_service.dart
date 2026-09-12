import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String defaultGeminiModel = 'gemini-3.6-flash';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chat;

  GeminiService({String? model}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env');
    }
    final modelName = model ?? dotenv.env['GEMINI_MODEL'] ?? defaultGeminiModel;
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e) {
      return "Error contacting AI: $e";
    }
  }
}
