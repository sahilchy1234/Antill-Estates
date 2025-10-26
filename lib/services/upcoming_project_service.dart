import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../model/upcoming_project_model.dart';

class UpcomingProjectService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Firebase Functions URL
  static const String _functionsBaseUrl = 'https://us-central1-antella-estates.cloudfunctions.net';

  /// Get upcoming projects from Firebase Functions or direct Firestore
  static Future<List<UpcomingProject>> getUpcomingProjects({
    int limit = 10,
    String status = 'upcoming',
  }) async {
    try {
      print('🔍 Fetching upcoming projects with limit: $limit, status: $status');
      
      // First try to fetch from Firebase Functions endpoint
      try {
        final response = await http.get(
          Uri.parse('$_functionsBaseUrl/getUpcomingProjectsHTTP?limit=$limit&status=$status'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['projects'] != null) {
            final projects = (data['projects'] as List)
                .map((project) => UpcomingProject.fromMap(Map<String, dynamic>.from(project)))
                .toList();
            
            print('✅ Found ${projects.length} upcoming projects from Firebase Functions');
            return projects;
          }
        }
      } catch (httpError) {
        print('⚠️ Firebase Functions request failed, falling back to direct Firestore: $httpError');
      }
      
      // Fallback: Direct Firestore query
      print('🔍 Falling back to direct Firestore query');
      final querySnapshot = await _firestore
          .collection('upcomingProjects')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final projects = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include the document ID
            return UpcomingProject.fromMap(data);
          })
          .toList();

      print('✅ Found ${projects.length} upcoming projects from Firestore');
      return projects;
    } catch (e) {
      print('❌ Error fetching upcoming projects: $e');
      return [];
    }
  }

  /// Get all projects (regardless of status)
  static Future<List<UpcomingProject>> getAllProjects({
    int limit = 50,
  }) async {
    try {
      print('🔍 Fetching all projects with limit: $limit');
      
      // First try Firebase Functions
      try {
        final response = await http.get(
          Uri.parse('$_functionsBaseUrl/getUpcomingProjectsHTTP?limit=$limit&status=all'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['projects'] != null) {
            final projects = (data['projects'] as List)
                .map((project) => UpcomingProject.fromMap(Map<String, dynamic>.from(project)))
                .toList();
            
            print('✅ Found ${projects.length} projects from Firebase Functions');
            return projects;
          }
        }
      } catch (httpError) {
        print('⚠️ Firebase Functions request failed, falling back to direct Firestore: $httpError');
      }
      
      // Fallback: Direct Firestore query
      final querySnapshot = await _firestore
          .collection('upcomingProjects')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final projects = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UpcomingProject.fromMap(data);
          })
          .toList();

      print('✅ Found ${projects.length} projects from Firestore');
      return projects;
    } catch (e) {
      print('❌ Error fetching all projects: $e');
      return [];
    }
  }

  /// Get projects by status
  static Future<List<UpcomingProject>> getProjectsByStatus(String status, {int limit = 10}) async {
    return getUpcomingProjects(limit: limit, status: status);
  }

  /// Get project by ID
  static Future<UpcomingProject?> getProjectById(String projectId) async {
    try {
      print('🔍 Fetching project by ID: $projectId');
      
      final docSnapshot = await _firestore
          .collection('upcomingProjects')
          .doc(projectId)
          .get();

      if (!docSnapshot.exists) {
        print('🔍 Project not found with ID: $projectId');
        return null;
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      final project = UpcomingProject.fromMap(data);
      print('✅ Found project: ${project.title}');
      return project;
    } catch (e) {
      print('❌ Error fetching project by ID: $e');
      return null;
    }
  }

  /// Get project statistics
  static Future<Map<String, dynamic>> getProjectStats() async {
    try {
      print('🔍 Fetching project statistics');
      
      final projectsSnapshot = await _firestore.collection('upcomingProjects').get();
      
      int totalProjects = 0;
      int activeProjects = 0;
      int upcomingProjects = 0;
      int completedProjects = 0;
      
      for (var doc in projectsSnapshot.docs) {
        totalProjects++;
        final status = doc.data()['status'] ?? 'upcoming';
        
        switch (status) {
          case 'upcoming':
            upcomingProjects++;
            activeProjects++;
            break;
          case 'launched':
          case 'ongoing':
            activeProjects++;
            break;
          case 'completed':
            completedProjects++;
            break;
        }
      }
      
      final stats = {
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'upcomingProjects': upcomingProjects,
        'completedProjects': completedProjects,
      };

      print('✅ Project stats: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching project stats: $e');
      return {
        'totalProjects': 0,
        'activeProjects': 0,
        'upcomingProjects': 0,
        'completedProjects': 0,
      };
    }
  }

  /// Search projects by title, builder, or address
  static Future<List<UpcomingProject>> searchProjects(String query, {int limit = 20}) async {
    try {
      print('🔍 Searching projects with query: $query');
      
      if (query.isEmpty) {
        return getAllProjects(limit: limit);
      }
      
      // Convert query to lowercase for case-insensitive search
      final searchQuery = query.toLowerCase();
      
      final querySnapshot = await _firestore
          .collection('upcomingProjects')
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Get more to filter client-side
          .get();

      final projects = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UpcomingProject.fromMap(data);
          })
          .where((project) {
            return project.title.toLowerCase().contains(searchQuery) ||
                   project.builder.toLowerCase().contains(searchQuery) ||
                   project.address.toLowerCase().contains(searchQuery);
          })
          .take(limit)
          .toList();

      print('✅ Found ${projects.length} projects matching search query');
      return projects;
    } catch (e) {
      print('❌ Error searching projects: $e');
      return [];
    }
  }

  /// Get featured/trending projects (can be enhanced with actual trending logic)
  static Future<List<UpcomingProject>> getFeaturedProjects({int limit = 5}) async {
    try {
      print('🔍 Fetching featured projects');
      
      // For now, get recent projects as featured
      // Later this can be enhanced with actual trending/featured logic
      return getUpcomingProjects(limit: limit, status: 'upcoming');
    } catch (e) {
      print('❌ Error fetching featured projects: $e');
      return [];
    }
  }

  /// Add new project (for admin use)
  static Future<String?> addProject(UpcomingProject project) async {
    try {
      print('🔍 Adding new project: ${project.title}');
      
      final projectData = project.toMap();
      projectData.remove('id'); // Remove ID for new document
      projectData['createdAt'] = FieldValue.serverTimestamp();
      projectData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection('upcomingProjects').add(projectData);
      print('✅ Project added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding project: $e');
      return null;
    }
  }

  /// Update existing project (for admin use)
  static Future<bool> updateProject(String projectId, UpcomingProject project) async {
    try {
      print('🔍 Updating project: $projectId');
      
      final projectData = project.toMap();
      projectData.remove('id'); // Remove ID from update data
      projectData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('upcomingProjects').doc(projectId).update(projectData);
      print('✅ Project updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating project: $e');
      return false;
    }
  }

  /// Delete project (for admin use)
  static Future<bool> deleteProject(String projectId) async {
    try {
      print('🔍 Deleting project: $projectId');
      
      await _firestore.collection('upcomingProjects').doc(projectId).delete();
      print('✅ Project deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting project: $e');
      return false;
    }
  }
}
