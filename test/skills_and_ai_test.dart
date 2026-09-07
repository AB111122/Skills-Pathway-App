import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:skills_pathway_app/core/constants/skill_catalog.dart';
import 'package:skills_pathway_app/features/authentication/data/mock_auth_service.dart';
import 'package:skills_pathway_app/services/ai_service.dart';

void main() {
  group('Student skills', () {
    test(
      'normalizes, deduplicates, persists, and restores custom skills',
      () async {
        final auth = MockAuthService();
        final user = await auth.login(
          email: 'student@example.com',
          password: 'Password123',
        );

        final updated = await auth.updateStudentSkills(user.id, [
          'Java',
          ' Networking ',
          'java',
          'Automotive Diagnostics',
        ]);
        expect(updated.skills, [
          'Java',
          'Networking',
          'Automotive Diagnostics',
        ]);

        await auth.logout();
        await auth.login(email: 'student@example.com', password: 'Password123');
        final restored = await auth.getStudentProfile(user.id);
        expect(
          restored?.skills,
          containsAll(['Java', 'Networking', 'Automotive Diagnostics']),
        );
      },
    );

    test('empty custom values are not saved', () {
      expect(SkillCatalog.normalizedUnique(['  ', 'Java']), ['Java']);
    });
  });

  group('AI service', () {
    test(
      'sends the actual prompt and history and returns the model response',
      () async {
        late Map<String, dynamic> request;
        final service = OpenAiCompatibleService(
          client: _FakeAiClient((body) {
            request = jsonDecode(body) as Map<String, dynamic>;
            return 'A networking roadmap';
          }),
          apiKey: 'test-key',
        );

        final response = await service.sendMessage(
          'What skills should I learn?',
          null,
          history: const [
            ChatTurn(
              fromUser: true,
              content: 'I am interested in cybersecurity.',
            ),
            ChatTurn(
              fromUser: false,
              content: 'Start with networking fundamentals.',
            ),
          ],
        );

        expect(response, 'A networking roadmap');
        final messages = request['messages'] as List<dynamic>;
        expect(
          messages.any(
            (item) => item['content'] == 'What skills should I learn?',
          ),
          isTrue,
        );
        expect(
          messages.any(
            (item) => item['content'].toString().contains('cybersecurity'),
          ),
          isTrue,
        );
      },
    );
  });
}

class _FakeAiClient extends http.BaseClient {
  final String Function(String body) responder;

  _FakeAiClient(this.responder);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().bytesToString();
    final content = responder(body);
    final responseBody = jsonEncode({
      'choices': [
        {
          'message': {'content': content},
        },
      ],
    });
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
