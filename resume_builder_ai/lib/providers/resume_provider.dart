import 'package:flutter/foundation.dart';
import '../models/resume_model.dart';
import '../services/storage_service.dart';

class ResumeProvider with ChangeNotifier {
  List<ResumeModel> _resumes = [];
  ResumeModel? _currentResume;
  bool _isLoading = false;

  List<ResumeModel> get resumes => _resumes;
  ResumeModel? get currentResume => _currentResume;
  bool get isLoading => _isLoading;

  ResumeProvider() {
    loadResumes();
  }

  Future<void> loadResumes() async {
    _isLoading = true;
    notifyListeners();

    _resumes = StorageService.getAllResumes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewResume(String title) async {
    final resume = ResumeModel(title: title, personalInfo: PersonalInfo());

    _currentResume = resume;
    await saveCurrentResume();
    await loadResumes();
    notifyListeners();
  }

  void setCurrentResume(ResumeModel resume) {
    _currentResume = resume;
    notifyListeners();
  }

  Future<void> saveCurrentResume() async {
    if (_currentResume == null) return;

    _currentResume = _currentResume!.copyWith(updatedAt: DateTime.now());

    await StorageService.saveResume(_currentResume!);
    await loadResumes();
    notifyListeners();
  }

  Future<void> deleteResume(String id) async {
    await StorageService.deleteResume(id);
    if (_currentResume?.id == id) {
      _currentResume = null;
    }
    await loadResumes();
    notifyListeners();
  }

  void updatePersonalInfo(PersonalInfo info) {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(personalInfo: info);
    saveCurrentResume();
  }

  void updateProfessionalSummary(String summary) {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(professionalSummary: summary);
    saveCurrentResume();
  }

  void addExperience(WorkExperience experience) {
    if (_currentResume == null) return;
    final experiences = List<WorkExperience>.from(_currentResume!.experience)
      ..add(experience);
    _currentResume = _currentResume!.copyWith(experience: experiences);
    saveCurrentResume();
  }

  void updateExperience(int index, WorkExperience experience) {
    if (_currentResume == null) return;
    final experiences = List<WorkExperience>.from(_currentResume!.experience);
    experiences[index] = experience;
    _currentResume = _currentResume!.copyWith(experience: experiences);
    saveCurrentResume();
  }

  void removeExperience(int index) {
    if (_currentResume == null) return;
    final experiences = List<WorkExperience>.from(_currentResume!.experience)
      ..removeAt(index);
    _currentResume = _currentResume!.copyWith(experience: experiences);
    saveCurrentResume();
  }

  void addEducation(Education education) {
    if (_currentResume == null) return;
    final educations = List<Education>.from(_currentResume!.education)
      ..add(education);
    _currentResume = _currentResume!.copyWith(education: educations);
    saveCurrentResume();
  }

  void updateEducation(int index, Education education) {
    if (_currentResume == null) return;
    final educations = List<Education>.from(_currentResume!.education);
    educations[index] = education;
    _currentResume = _currentResume!.copyWith(education: educations);
    saveCurrentResume();
  }

  void removeEducation(int index) {
    if (_currentResume == null) return;
    final educations = List<Education>.from(_currentResume!.education)
      ..removeAt(index);
    _currentResume = _currentResume!.copyWith(education: educations);
    saveCurrentResume();
  }

  void addSkill(String skill) {
    if (_currentResume == null) return;
    final skills = List<String>.from(_currentResume!.skills);
    if (!skills.contains(skill)) {
      skills.add(skill);
      _currentResume = _currentResume!.copyWith(skills: skills);
      saveCurrentResume();
    }
  }

  void removeSkill(String skill) {
    if (_currentResume == null) return;
    final skills = List<String>.from(_currentResume!.skills)..remove(skill);
    _currentResume = _currentResume!.copyWith(skills: skills);
    saveCurrentResume();
  }

  void addProject(Project project) {
    if (_currentResume == null) return;
    final projects = List<Project>.from(_currentResume!.projects)..add(project);
    _currentResume = _currentResume!.copyWith(projects: projects);
    saveCurrentResume();
  }

  void updateProject(int index, Project project) {
    if (_currentResume == null) return;
    final projects = List<Project>.from(_currentResume!.projects);
    projects[index] = project;
    _currentResume = _currentResume!.copyWith(projects: projects);
    saveCurrentResume();
  }

  void removeProject(int index) {
    if (_currentResume == null) return;
    final projects = List<Project>.from(_currentResume!.projects)
      ..removeAt(index);
    _currentResume = _currentResume!.copyWith(projects: projects);
    saveCurrentResume();
  }

  void addCertification(Certification certification) {
    if (_currentResume == null) return;
    final certifications = List<Certification>.from(
      _currentResume!.certifications,
    )..add(certification);
    _currentResume = _currentResume!.copyWith(certifications: certifications);
    saveCurrentResume();
  }

  void removeCertification(int index) {
    if (_currentResume == null) return;
    final certifications = List<Certification>.from(
      _currentResume!.certifications,
    )..removeAt(index);
    _currentResume = _currentResume!.copyWith(certifications: certifications);
    saveCurrentResume();
  }

  void updateSettings(ResumeSettings settings) {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(settings: settings);
    saveCurrentResume();
  }
}
