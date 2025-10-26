import 'package:flutter/material.dart';
import 'package:antill_estates/services/upcoming_project_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Upcoming Projects Integration...');
  
  try {
    // Test fetching upcoming projects
    print('📡 Fetching upcoming projects from Firebase...');
    final projects = await UpcomingProjectService.getUpcomingProjects(limit: 5);
    
    print('📊 Results:');
    print('   Total projects found: ${projects.length}');
    
    for (int i = 0; i < projects.length; i++) {
      final project = projects[i];
      print('   Project ${i + 1}:');
      print('     ID: ${project.id}');
      print('     Title: ${project.title}');
      print('     Price: ${project.price}');
      print('     Address: ${project.address}');
      print('     Builder: ${project.builder}');
      print('     Status: ${project.status}');
      print('     Image URL: ${project.imageUrl ?? 'No image'}');
      print('');
    }
    
    if (projects.isEmpty) {
      print('⚠️  No projects found in Firebase.');
      print('💡 To test the integration:');
      print('   1. Open the admin panel at: admin_panel/projects.html');
      print('   2. Add some upcoming projects using the form');
      print('   3. Run this test again to see the projects');
    } else {
      print('✅ Integration test successful! Projects are being fetched from Firebase.');
    }
    
  } catch (e) {
    print('❌ Error during integration test: $e');
    print('💡 Make sure Firebase is properly configured and the admin panel is deployed.');
  }
}
