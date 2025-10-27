import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'lib/services/server/resume_service.dart';
import 'lib/services/server/ai_service.dart';
import 'lib/services/server/database_service.dart';
import 'lib/utils/logger.dart';

void main(List<String> args) async {
  // Initialize database
  await DatabaseService.initialize();

  // Create server with CORS
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(_router);

  // Start server on port 8080
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);

  AppLogger.info('🚀 Server running at http://localhost:${server.port}');
  AppLogger.info('📖 API docs: http://localhost:${server.port}/');
}

// API Routes
final _router = Router()
  // Health check
  ..get('/', _rootHandler)
  // Resume routes (now public, no auth required)
  ..get('/api/resumes', _listResumesHandler)
  ..post('/api/resumes', _createResumeHandler)
  ..post('/api/resumes/update', _updateResumeHandler)
  ..post('/api/resumes/delete', _deleteResumeHandler)
  // AI routes
  ..post('/api/ai/generate-summary', _generateSummaryHandler)
  ..post('/api/ai/enhance-bullet', _enhanceBulletHandler)
  ..post('/api/ai/suggest-skills', _suggestSkillsHandler)
  ..post('/api/ai/analyze-resume', _analyzeResumeHandler)
  // Not found
  ..all('/<ignored|.*>', _notFoundHandler);

// Health check
Handler _rootHandler = (Request request) {
  return Response.ok(
    '{"status":"running","service":"Resume Builder AI Backend","version":"1.0.0"}',
    headers: {'content-type': 'application/json'},
  );
};

// Resume Handlers (no authentication required)
Handler _listResumesHandler = (Request request) async {
  try {
    // Get all resumes (no user filtering)
    final resumes = await ResumeService.getAllResumes();
    return _success(resumes);
  } catch (e) {
    return _error('Failed to fetch resumes: $e');
  }
};

Handler _createResumeHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final resume = await ResumeService.createResume('guest', json);

    return _success(resume);
  } catch (e) {
    return _error('Failed to create resume: $e');
  }
};

Handler _updateResumeHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final id = json['id'] as String?;
    if (id == null) {
      return _error('Resume ID is required');
    }

    final resume = await ResumeService.updateResume(id, 'guest', json);

    if (resume == null) {
      return _notFound('Resume not found');
    }

    return _success(resume);
  } catch (e) {
    return _error('Failed to update resume: $e');
  }
};

Handler _deleteResumeHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final id = json['id'] as String?;
    if (id == null) {
      return _error('Resume ID is required');
    }

    final success = await ResumeService.deleteResume(id, 'guest');
    if (!success) {
      return _notFound('Resume not found');
    }

    return _success({'message': 'Resume deleted successfully'});
  } catch (e) {
    return _error('Failed to delete resume: $e');
  }
};

// AI Handlers
Handler _generateSummaryHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final summary = await AiService.generateProfessionalSummary(
      role: json['role'],
      experienceLevel: json['experienceLevel'],
      skills: List<String>.from(json['skills'] ?? []),
    );

    return _success({'summary': summary});
  } catch (e) {
    return _error('Failed to generate summary: $e');
  }
};

Handler _enhanceBulletHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final variations = await AiService.enhanceBulletPoint(json['bulletPoint']);

    return _success({'variations': variations});
  } catch (e) {
    return _error('Failed to enhance bullet point: $e');
  }
};

Handler _suggestSkillsHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final skills = await AiService.suggestSkills(json['jobTitle']);

    return _success({'skills': skills});
  } catch (e) {
    return _error('Failed to suggest skills: $e');
  }
};

Handler _analyzeResumeHandler = (Request request) async {
  try {
    final json = await _parseJson(request);
    final analysis = await AiService.analyzeResume(json['resumeData']);

    return _success(analysis);
  } catch (e) {
    return _error('Failed to analyze resume: $e');
  }
};

// Not found handler
Handler _notFoundHandler = (Request request) {
  return Response.notFound(
    jsonEncode({'error': 'Not Found', 'path': request.url.path}),
    headers: {'content-type': 'application/json'},
  );
};

// Helper functions
Future<Map<String, dynamic>> _parseJson(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  try {
    return json.decode(body) as Map<String, dynamic>;
  } catch (e) {
    return {};
  }
}

Response _success(dynamic data) {
  return Response.ok(
    jsonEncode({'success': true, 'data': data}),
    headers: {'content-type': 'application/json'},
  );
}

Response _error(String message) {
  return Response.internalServerError(
    body: jsonEncode({'success': false, 'error': message}),
    headers: {'content-type': 'application/json'},
  );
}

Response _notFound(String message) {
  return Response.notFound(
    jsonEncode({'success': false, 'error': message}),
    headers: {'content-type': 'application/json'},
  );
}
