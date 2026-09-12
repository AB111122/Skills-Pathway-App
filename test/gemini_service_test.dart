import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/services/gemini_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeminiService Tests', () {
    test('instantiates successfully when GEMINI_API_KEY is present in dotenv', () {
      dotenv.testLoad(fileInput: 'GEMINI_API_KEY=mock_key_for_testing');
      final service = GeminiService();
      expect(service, isNotNull);
    });

    test('supports custom model or GEMINI_MODEL env variable', () {
      expect(defaultGeminiModel, equals('gemini-3.6-flash'));
      dotenv.testLoad(
        fileInput:
            'GEMINI_API_KEY=mock_key_for_testing\nGEMINI_MODEL=gemini-flash-latest',
      );
      final service = GeminiService();
      expect(service, isNotNull);

      final customService = GeminiService(model: 'gemini-3.6-flash');
      expect(customService, isNotNull);
    });

    test('throws exception when GEMINI_API_KEY is missing', () {
      dotenv.testLoad(fileInput: '');
      expect(() => GeminiService(), throwsA(isA<Exception>()));
    });
  });
}
