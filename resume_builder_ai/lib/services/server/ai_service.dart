class AiService {
  static Future<String> generateProfessionalSummary({
    required String role,
    required String experienceLevel,
    required List<String> skills,
  }) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));

    return 'Experienced $experienceLevel $role with a proven track record in ${skills.take(3).join(", ")}. '
        'Strong analytical and problem-solving skills combined with excellent communication abilities. '
        'Passionate about continuous learning and delivering high-quality solutions.';
  }

  static Future<List<String>> enhanceBulletPoint(String bulletPoint) async {
    await Future.delayed(Duration(milliseconds: 300));

    return [
      'Achieved significant results in $bulletPoint through strategic implementation',
      'Delivered measurable improvements in $bulletPoint exceeding performance targets',
      'Led key initiatives focused on $bulletPoint with proven outcomes',
    ];
  }

  static Future<List<String>> suggestSkills(String jobTitle) async {
    await Future.delayed(Duration(milliseconds: 400));

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

  static Future<Map<String, dynamic>> analyzeResume(
    Map<String, dynamic> resumeData,
  ) async {
    await Future.delayed(Duration(milliseconds: 600));

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
}
