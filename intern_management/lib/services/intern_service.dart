import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/intern_model.dart';

class InternService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<InternModel>> getAllInterns() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get interns: $e');
    }
  }

  Stream<List<InternModel>> getInternsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<InternModel?> getInternById(String internId) async {
    try {
      final doc = await _firestore.collection('users').doc(internId).get();
      if (doc.exists) {
        return InternModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get intern: $e');
    }
  }

  Future<List<InternModel>> getActiveInterns() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active interns: $e');
    }
  }

  Stream<List<InternModel>> getActiveInternsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<bool> updateInternProfile({
    required String internId,
    String? name,
    String? phone,
    String? department,
    String? university,
    String? course,
    String? bio,
    List<String>? skills,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (department != null) updateData['department'] = department;
      if (university != null) updateData['university'] = university;
      if (course != null) updateData['course'] = course;
      if (bio != null) updateData['bio'] = bio;
      if (skills != null) updateData['skills'] = skills;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(internId).update(updateData);
      }
      return true;
    } catch (e) {
      throw Exception('Failed to update intern profile: $e');
    }
  }

  Future<bool> updateInternPerformance({
    required String internId,
    required Map<String, dynamic> performanceData,
  }) async {
    try {
      await _firestore.collection('users').doc(internId).update({
        'performance': performanceData,
        'lastActiveAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to update intern performance: $e');
    }
  }

  Future<Map<String, dynamic>> getInternPerformanceAnalytics(
    String internId,
  ) async {
    try {
      final intern = await getInternById(internId);
      if (intern == null) {
        throw Exception('Intern not found');
      }

      final performance = intern.performance;

      return {
        'totalTasksAssigned': performance['totalTasksAssigned'] ?? 0,
        'totalTasksCompleted': performance['totalTasksCompleted'] ?? 0,
        'totalTasksOverdue': performance['totalTasksOverdue'] ?? 0,
        'completionRate': intern.completionRate,
        'averageRating': intern.averageRating,
        'performanceStatus': intern.performanceStatus,
        'internshipDuration': intern.internshipDurationInDays,
        'remainingDays': intern.remainingDays,
        'isActive': intern.isActive,
        'isCompleted': intern.isInternshipCompleted,
      };
    } catch (e) {
      throw Exception('Failed to get intern performance analytics: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllInternsPerformanceAnalytics() async {
    try {
      final interns = await getAllInterns();
      final analytics = <Map<String, dynamic>>[];

      for (final intern in interns) {
        analytics.add({
          'internId': intern.id,
          'name': intern.name,
          'email': intern.email,
          'department': intern.department,
          'totalTasksAssigned': intern.totalTasksAssigned,
          'totalTasksCompleted': intern.totalTasksCompleted,
          'totalTasksOverdue': intern.totalTasksOverdue,
          'completionRate': intern.completionRate,
          'averageRating': intern.averageRating,
          'performanceStatus': intern.performanceStatus,
          'internshipDuration': intern.internshipDurationInDays,
          'remainingDays': intern.remainingDays,
          'isActive': intern.isActive,
          'isCompleted': intern.isInternshipCompleted,
          'lastActiveAt': intern.lastActiveAt,
        });
      }

      return analytics;
    } catch (e) {
      throw Exception('Failed to get all interns performance analytics: $e');
    }
  }

  Future<List<InternModel>> getInternsByDepartment(String department) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .where('department', isEqualTo: department)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get interns by department: $e');
    }
  }

  Stream<List<InternModel>> getInternsByDepartmentStream(String department) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .where('department', isEqualTo: department)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<List<InternModel>> getInternsByUniversity(String university) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .where('university', isEqualTo: university)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get interns by university: $e');
    }
  }

  Future<List<InternModel>> getInternsBySkills(List<String> skills) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .where('skills', arrayContainsAny: skills)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get interns by skills: $e');
    }
  }

  Future<List<InternModel>> searchInterns(String searchQuery) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .orderBy('name')
          .get();

      final allInterns = querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();

      return allInterns.where((intern) {
        return intern.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            intern.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (intern.department?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ??
                false) ||
            (intern.university?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ??
                false) ||
            (intern.course?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search interns: $e');
    }
  }

  Future<Map<String, dynamic>> getInternStatistics() async {
    try {
      final interns = await getAllInterns();

      final totalInterns = interns.length;
      final activeInterns = interns.where((i) => i.isActive).length;
      final completedInterns = interns
          .where((i) => i.isInternshipCompleted)
          .length;
      final ongoingInterns = interns.where((i) => i.isInternshipActive).length;

      final departmentStats = <String, int>{};
      for (final intern in interns) {
        if (intern.department != null) {
          departmentStats[intern.department!] =
              (departmentStats[intern.department!] ?? 0) + 1;
        }
      }

      final universityStats = <String, int>{};
      for (final intern in interns) {
        if (intern.university != null) {
          universityStats[intern.university!] =
              (universityStats[intern.university!] ?? 0) + 1;
        }
      }

      final performanceStats = <String, int>{};
      for (final intern in interns) {
        performanceStats[intern.performanceStatus] =
            (performanceStats[intern.performanceStatus] ?? 0) + 1;
      }

      return {
        'totalInterns': totalInterns,
        'activeInterns': activeInterns,
        'completedInterns': completedInterns,
        'ongoingInterns': ongoingInterns,
        'departmentStats': departmentStats,
        'universityStats': universityStats,
        'performanceStats': performanceStats,
      };
    } catch (e) {
      throw Exception('Failed to get intern statistics: $e');
    }
  }

  Future<bool> deactivateIntern(String internId) async {
    try {
      await _firestore.collection('users').doc(internId).update({
        'isActive': false,
        'endDate': DateTime.now(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to deactivate intern: $e');
    }
  }

  Future<bool> reactivateIntern(String internId) async {
    try {
      await _firestore.collection('users').doc(internId).update({
        'isActive': true,
        'endDate': null,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to reactivate intern: $e');
    }
  }
}
