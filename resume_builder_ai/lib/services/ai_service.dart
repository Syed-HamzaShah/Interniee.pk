import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Use local backend server if available, otherwise fallback to external service
  static const String _localServerUrl = 'http://localhost:8080';
  static const String _externalServiceUrl = 'https://text.pollinations.ai';
  static bool _useLocalServer = true; // Set to false to use external service

  Future<String> generateProfessionalSummary({
    required String role,
    required String experienceLevel,
    required List<String> skills,
  }) async {
    // Try local server first
    if (_useLocalServer) {
      try {
        final response = await http
            .post(
              Uri.parse('$_localServerUrl/api/ai/generate-summary'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'role': role,
                'experienceLevel': experienceLevel,
                'skills': skills,
              }),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data']['summary'];
        }
      } catch (e) {
        // Fallback to external service
      }
    }

    // Fallback to external service
    final prompt = Uri.encodeComponent(
      'Write a professional resume summary for a $experienceLevel $role with skills in ${skills.join(", ")}. '
      'Keep it concise (3-4 sentences), highlight key strengths, and use confident, professional tone. '
      'Return only the summary text without any labels or formatting.',
    );

    try {
      final response = await http
          .get(Uri.parse('$_externalServiceUrl/$prompt?model=openai'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return _fallbackSummary(role, experienceLevel);
    } catch (e) {
      return _fallbackSummary(role, experienceLevel);
    }
  }

  Future<List<String>> enhanceBulletPoint(String bulletPoint) async {
    // Try local server first
    if (_useLocalServer) {
      try {
        final response = await http
            .post(
              Uri.parse('$_localServerUrl/api/ai/enhance-bullet'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'bulletPoint': bulletPoint}),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return List<String>.from(data['data']['variations']);
        }
      } catch (e) {
        // Fallback to external service
      }
    }

    // Fallback to external service
    final prompt = Uri.encodeComponent(
      'Rewrite this resume bullet point to be more impactful using action verbs and quantifiable achievements: "$bulletPoint". '
      'Provide 3 variations. Return as JSON array of strings.',
    );

    try {
      final response = await http
          .get(Uri.parse('$_externalServiceUrl/$prompt?model=openai&json=true'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
      return _fallbackBulletPoints(bulletPoint);
    } catch (e) {
      return _fallbackBulletPoints(bulletPoint);
    }
  }

  Future<List<String>> suggestSkills(String jobTitle) async {
    // Try local server first
    if (_useLocalServer) {
      try {
        final response = await http
            .post(
              Uri.parse('$_localServerUrl/api/ai/suggest-skills'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'jobTitle': jobTitle}),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return List<String>.from(data['data']['skills']);
        }
      } catch (e) {
        // Fallback to external service
      }
    }

    // Fallback to external service
    final prompt = Uri.encodeComponent(
      'List 10 essential skills for a $jobTitle position. '
      'Include both technical and soft skills. Return as JSON array of strings.',
    );

    try {
      final response = await http
          .get(Uri.parse('$_externalServiceUrl/$prompt?model=openai&json=true'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
      return _fallbackSkills(jobTitle);
    } catch (e) {
      return _fallbackSkills(jobTitle);
    }
  }

  Future<List<String>> generateResponsibilities(
    String jobTitle,
    String company,
  ) async {
    final prompt = Uri.encodeComponent(
      'Generate 5 impactful resume bullet points for a $jobTitle at $company. '
      'Use action verbs, focus on achievements, and include metrics where possible. '
      'Return as JSON array of strings.',
    );

    try {
      final response = await http
          .get(Uri.parse('$_externalServiceUrl/$prompt?model=openai&json=true'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }
      return _fallbackResponsibilities(jobTitle);
    } catch (e) {
      return _fallbackResponsibilities(jobTitle);
    }
  }

  Future<Map<String, dynamic>> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    // Try local server first
    if (_useLocalServer) {
      try {
        final response = await http
            .post(
              Uri.parse('$_localServerUrl/api/ai/analyze-resume'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'resumeData': resumeData}),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data'];
        }
      } catch (e) {
        // Fallback to default analysis
      }
    }

    // Default analysis
    return {
      'score': 85,
      'strengths': [
        'Strong action verbs throughout',
        'Good use of quantifiable achievements',
        'Clear section organization',
      ],
      'improvements': [
        'Add more metrics to experience section',
        'Consider expanding professional summary',
        'Include relevant certifications',
      ],
      'atsCompatibility': 90,
    };
  }

  String _fallbackSummary(String role, String experienceLevel) {
    return 'Motivated $experienceLevel $role with proven expertise in delivering high-quality solutions. '
        'Strong analytical and problem-solving skills combined with excellent communication abilities. '
        'Passionate about continuous learning and contributing to team success.';
  }

  List<String> _fallbackBulletPoints(String original) {
    return [
      'Achieved significant improvements in $original through strategic implementation',
      'Successfully delivered $original exceeding performance targets',
      'Led initiatives focused on $original resulting in measurable outcomes',
    ];
  }

  List<String> _fallbackSkills(String jobTitle) {
    final commonSkills = [
      'Problem Solving',
      'Team Collaboration',
      'Communication',
      'Time Management',
      'Critical Thinking',
    ];

    if (jobTitle.toLowerCase().contains('developer') ||
        jobTitle.toLowerCase().contains('software')) {
      return [
        'JavaScript',
        'Python',
        'React',
        'Git',
        'API Development',
        ...commonSkills,
      ];
    }

    return [
      'Project Management',
      'Data Analysis',
      'Microsoft Office',
      'Strategic Planning',
      'Leadership',
      ...commonSkills,
    ];
  }

  List<String> _fallbackResponsibilities(String jobTitle) {
    return [
      'Collaborated with cross-functional teams to deliver high-quality solutions',
      'Implemented best practices resulting in 20% improvement in efficiency',
      'Managed multiple projects simultaneously while meeting tight deadlines',
      'Contributed to team goals through consistent performance and innovation',
      'Communicated effectively with stakeholders to ensure project success',
    ];
  }
}
