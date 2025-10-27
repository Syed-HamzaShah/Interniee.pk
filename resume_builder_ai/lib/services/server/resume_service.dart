class ResumeService {
  static final List<Map<String, dynamic>> _resumes = [];

  static Future<List<Map<String, dynamic>>> getAllResumes() async {
    return _resumes.toList();
  }

  static Future<List<Map<String, dynamic>>> getResumesByUserId(
    String userId,
  ) async {
    return _resumes.where((r) => r['userId'] == userId).toList();
  }

  static Future<Map<String, dynamic>> createResume(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final resume = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'title': data['title'] ?? 'Untitled Resume',
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _resumes.add(resume);
    return resume;
  }

  static Future<Map<String, dynamic>?> getResume(
    String id,
    String userId,
  ) async {
    try {
      final resume = _resumes.firstWhere(
        (r) => r['id'] == id && r['userId'] == userId,
      );
      return Map<String, dynamic>.from(resume);
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateResume(
    String id,
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final index = _resumes.indexWhere(
        (r) => r['id'] == id && r['userId'] == userId,
      );

      if (index == -1) return null;

      _resumes[index] = {
        ..._resumes[index],
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      return Map<String, dynamic>.from(_resumes[index]);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteResume(String id, String userId) async {
    try {
      final index = _resumes.indexWhere(
        (r) => r['id'] == id && r['userId'] == userId,
      );

      if (index == -1) return false;

      _resumes.removeAt(index);
      return true;
    } catch (e) {
      return false;
    }
  }
}
