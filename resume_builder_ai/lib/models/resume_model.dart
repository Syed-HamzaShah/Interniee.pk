import 'package:uuid/uuid.dart';

class ResumeModel {
  final String id;
  String title;
  DateTime updatedAt;
  PersonalInfo personalInfo;
  String professionalSummary;
  List<WorkExperience> experience;
  List<Education> education;
  List<String> skills;
  List<Project> projects;
  List<Certification> certifications;
  ResumeSettings settings;

  ResumeModel({
    String? id,
    required this.title,
    DateTime? updatedAt,
    required this.personalInfo,
    this.professionalSummary = '',
    List<WorkExperience>? experience,
    List<Education>? education,
    List<String>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
    ResumeSettings? settings,
  }) : id = id ?? const Uuid().v4(),
       updatedAt = updatedAt ?? DateTime.now(),
       experience = experience ?? [],
       education = education ?? [],
       skills = skills ?? [],
       projects = projects ?? [],
       certifications = certifications ?? [],
       settings = settings ?? ResumeSettings();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'updatedAt': updatedAt.toIso8601String(),
      'personalInfo': personalInfo.toJson(),
      'professionalSummary': professionalSummary,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'skills': skills,
      'projects': projects.map((p) => p.toJson()).toList(),
      'certifications': certifications.map((c) => c.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'],
      title: json['title'],
      updatedAt: DateTime.parse(json['updatedAt']),
      personalInfo: PersonalInfo.fromJson(json['personalInfo']),
      professionalSummary: json['professionalSummary'] ?? '',
      experience: (json['experience'] as List?)
          ?.map((e) => WorkExperience.fromJson(e))
          .toList(),
      education: (json['education'] as List?)
          ?.map((e) => Education.fromJson(e))
          .toList(),
      skills: List<String>.from(json['skills'] ?? []),
      projects: (json['projects'] as List?)
          ?.map((p) => Project.fromJson(p))
          .toList(),
      certifications: (json['certifications'] as List?)
          ?.map((c) => Certification.fromJson(c))
          .toList(),
      settings: ResumeSettings.fromJson(json['settings']),
    );
  }

  ResumeModel copyWith({
    String? title,
    DateTime? updatedAt,
    PersonalInfo? personalInfo,
    String? professionalSummary,
    List<WorkExperience>? experience,
    List<Education>? education,
    List<String>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
    ResumeSettings? settings,
  }) {
    return ResumeModel(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      personalInfo: personalInfo ?? this.personalInfo,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      settings: settings ?? this.settings,
    );
  }
}

class PersonalInfo {
  String fullName;
  String email;
  String phone;
  String location;
  String headline;
  String? linkedIn;
  String? portfolio;
  String? github;

  PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.headline = '',
    this.linkedIn,
    this.portfolio,
    this.github,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'headline': headline,
      'linkedIn': linkedIn,
      'portfolio': portfolio,
      'github': github,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      headline: json['headline'] ?? '',
      linkedIn: json['linkedIn'],
      portfolio: json['portfolio'],
      github: json['github'],
    );
  }
}

class WorkExperience {
  String jobTitle;
  String company;
  String location;
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrentJob;
  List<String> responsibilities;

  WorkExperience({
    this.jobTitle = '',
    this.company = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.isCurrentJob = false,
    List<String>? responsibilities,
  }) : responsibilities = responsibilities ?? [];

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'company': company,
      'location': location,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentJob': isCurrentJob,
      'responsibilities': responsibilities,
    };
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrentJob: json['isCurrentJob'] ?? false,
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
    );
  }
}

class Education {
  String degree;
  String institution;
  String location;
  DateTime? graduationDate;
  String? gpa;
  String? fieldOfStudy;

  Education({
    this.degree = '',
    this.institution = '',
    this.location = '',
    this.graduationDate,
    this.gpa,
    this.fieldOfStudy,
  });

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'institution': institution,
      'location': location,
      'graduationDate': graduationDate?.toIso8601String(),
      'gpa': gpa,
      'fieldOfStudy': fieldOfStudy,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      location: json['location'] ?? '',
      graduationDate: json['graduationDate'] != null
          ? DateTime.parse(json['graduationDate'])
          : null,
      gpa: json['gpa'],
      fieldOfStudy: json['fieldOfStudy'],
    );
  }
}

class Project {
  String title;
  String description;
  String? link;
  List<String> technologies;

  Project({
    this.title = '',
    this.description = '',
    this.link,
    List<String>? technologies,
  }) : technologies = technologies ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'technologies': technologies,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'],
      technologies: List<String>.from(json['technologies'] ?? []),
    );
  }
}

class Certification {
  String name;
  String issuer;
  DateTime? dateObtained;
  String? credentialId;

  Certification({
    this.name = '',
    this.issuer = '',
    this.dateObtained,
    this.credentialId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuer': issuer,
      'dateObtained': dateObtained?.toIso8601String(),
      'credentialId': credentialId,
    };
  }

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      dateObtained: json['dateObtained'] != null
          ? DateTime.parse(json['dateObtained'])
          : null,
      credentialId: json['credentialId'],
    );
  }
}

class ResumeSettings {
  String templateId;
  String colorScheme;
  String fontFamily;
  String layout;

  ResumeSettings({
    this.templateId = 'modern',
    this.colorScheme = 'blue',
    this.fontFamily = 'Inter',
    this.layout = 'single',
  });

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'colorScheme': colorScheme,
      'fontFamily': fontFamily,
      'layout': layout,
    };
  }

  factory ResumeSettings.fromJson(Map<String, dynamic> json) {
    return ResumeSettings(
      templateId: json['templateId'] ?? 'modern',
      colorScheme: json['colorScheme'] ?? 'blue',
      fontFamily: json['fontFamily'] ?? 'Inter',
      layout: json['layout'] ?? 'single',
    );
  }
}
