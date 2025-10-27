import 'package:hive_flutter/hive_flutter.dart';
import '../models/resume_model.dart';

class StorageService {
  static const String _resumeBoxName = 'resume_box';
  static const String _settingsBoxName = 'settings_box';

  static late Box<Map> _resumeBox;
  static late Box _settingsBox;

  static Future<void> initialize() async {
    _resumeBox = await Hive.openBox<Map>(_resumeBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveResume(ResumeModel resume) async {
    await _resumeBox.put(resume.id, resume.toJson());
  }

  static List<ResumeModel> getAllResumes() {
    final resumes = <ResumeModel>[];
    for (var key in _resumeBox.keys) {
      final data = _resumeBox.get(key);
      if (data != null) {
        resumes.add(ResumeModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    resumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return resumes;
  }

  static ResumeModel? getResume(String id) {
    final data = _resumeBox.get(id);
    if (data != null) {
      return ResumeModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  static Future<void> deleteResume(String id) async {
    await _resumeBox.delete(id);
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static bool hasCompletedOnboarding() {
    return _settingsBox.get('onboarding_completed', defaultValue: false);
  }

  static Future<void> setOnboardingCompleted() async {
    await _settingsBox.put('onboarding_completed', true);
  }
}
