import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';
import '../models/student_profile_model.dart';
import 'opportunity_service.dart';
export 'gemini_service.dart';

abstract class AiService {
  Future<String> sendMessage(
    String message,
    StudentProfileModel? profile, {
    List<ChatTurn> history = const [],
  });
  Future<List<OpportunityModel>> recommendOpportunities({
    required OpportunityType type,
    StudentProfileModel? profile,
  });
}

class ChatTurn {
  final bool fromUser;
  final String content;

  const ChatTurn({required this.fromUser, required this.content});
}

class OpenAiCompatibleService implements AiService {
  OpenAiCompatibleService({
    http.Client? client,
    String? apiKey,
    String? endpoint,
    String? model,
  }) : _client = client ?? http.Client(),
       _apiKeyValue = apiKey ?? _apiKey,
       _endpointValue = endpoint ?? _endpoint,
       _modelValue = model ?? _model;

  final http.Client _client;
  final String _apiKeyValue;
  final String _endpointValue;
  final String _modelValue;
  static const _apiKey = String.fromEnvironment('AI_API_KEY');
  static const _endpoint = String.fromEnvironment(
    'AI_API_ENDPOINT',
    defaultValue: 'https://api.openai.com/v1/chat/completions',
  );
  static const _model = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  @override
  Future<String> sendMessage(
    String message,
    StudentProfileModel? profile, {
    List<ChatTurn> history = const [],
  }) async {
    if (_apiKeyValue.isEmpty) {
      throw StateError(
        'AI is not configured. Build with --dart-define=AI_API_KEY=your-key.',
      );
    }
    final profileContext = profile == null
        ? 'No private profile information is available.'
        : 'The student profile context supplied by the user is: '
              '${profile.fieldOfStudy}, ${profile.educationLevel}, skills: ${profile.skills.join(', ')}.';
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are an AI Career Assistant inside the Skills Pathway student application. '
            'Help students with career exploration, skill recommendations, career pathways, internships, '
            'scholarships, resume improvement, interview preparation, learning roadmaps, and market skills. '
            'Ask useful follow-up questions when needed. Give practical, structured answers. '
            'Do not claim private user information that was not provided. $profileContext',
      },
      ...history.map(
        (turn) => {
          'role': turn.fromUser ? 'user' : 'assistant',
          'content': turn.content,
        },
      ),
      {'role': 'user', 'content': message.trim()},
    ];
    final response = await _client.post(
      Uri.parse(_endpointValue),
      headers: {
        'Authorization': 'Bearer $_apiKeyValue',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _modelValue,
        'messages': messages,
        'temperature': 0.4,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('AI request failed with status ${response.statusCode}.');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['choices'] as List<dynamic>?)
        ?.firstOrNull?['message']?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw StateError('AI returned an empty response.');
    }
    return content.trim();
  }

  @override
  Future<List<OpportunityModel>> recommendOpportunities({
    required OpportunityType type,
    StudentProfileModel? profile,
  }) async => const [];
}

class MockAiService implements AiService {
  final OpportunityService opportunityService;
  MockAiService(this.opportunityService);

  @override
  Future<String> sendMessage(
    String message,
    StudentProfileModel? profile, {
    List<ChatTurn> history = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = message.toLowerCase();
    final skills = profile?.skills.join(', ');
    if (lower.contains('intern')) {
      return 'Based on your profile${skills == null ? '' : ' and skills in $skills'}, start with verified internships matching your field. I can narrow these by location or deadline.';
    }
    if (lower.contains('scholar')) {
      return 'Look for scholarships aligned with your education level and field. I can show platform listings that are explicitly verified, but acceptance is decided by each organization.';
    }
    if (lower.contains('resume')) {
      return 'Keep your resume focused: lead with measurable projects, match relevant skills to the role, and keep evidence links easy to scan. Full resume parsing is planned for a later phase.';
    }
    if (lower.contains('market')) {
      return 'For market insight, compare your target role with recurring skills in current listings. This is general guidance from the mock assistant, not a guarantee of employment.';
    }
    return 'I can help you explore career directions, internships, scholarships, resume improvements, and market skills. Tell me what you want to work on next.';
  }

  @override
  Future<List<OpportunityModel>> recommendOpportunities({
    required OpportunityType type,
    StudentProfileModel? profile,
  }) async {
    final items = await opportunityService.getOpportunities(
      filter: OpportunityFilterModel(
        opportunityType: type,
        isVerifiedOnly: true,
      ),
    );
    return items;
  }
}
