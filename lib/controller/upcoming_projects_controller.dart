import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingProjectsController extends GetxController {
  // Loading states
  RxBool isLoading = true.obs;
  RxBool isRefreshing = false.obs;
  
  // Projects data
  RxList<Map<String, dynamic>> upcomingProjects = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredProjects = <Map<String, dynamic>>[].obs;
  
  // Search and filter
  RxString searchQuery = ''.obs;
  RxString selectedStatus = ''.obs;
  RxString selectedSortBy = 'createdAt'.obs;
  
  // Stats
  RxInt totalProjects = 0.obs;
  RxInt upcomingCount = 0.obs;
  RxInt launchedCount = 0.obs;
  RxInt ongoingCount = 0.obs;
  RxInt completedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUpcomingProjects();
  }

  /// Load upcoming projects from Firebase
  Future<void> loadUpcomingProjects() async {
    try {
      isLoading.value = true;
      
      // Try Firebase Functions first
      try {
        // For now, we'll use direct Firestore query
        // In production, you might want to use Firebase Functions
        await _loadFromFirestore();
      } catch (e) {
        print('Error loading from Firestore: $e');
        // Fallback to sample data
        _loadSampleData();
      }
      
    } catch (e) {
      print('Error loading upcoming projects: $e');
      _loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load projects from Firestore
  Future<void> _loadFromFirestore() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('upcomingProjects')
        .orderBy('createdAt', descending: true)
        .get();

    upcomingProjects.clear();
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      upcomingProjects.add({
        'id': doc.id,
        ...data,
      });
    }
    
    filteredProjects.value = List.from(upcomingProjects);
    _updateStats();
    print('✅ Loaded ${upcomingProjects.length} projects from Firestore');
  }

  /// Load sample data for demonstration
  void _loadSampleData() {
    upcomingProjects.value = [
      {
        'id': 'sample1',
        'title': 'Luxury Villa Project',
        'price': '₹45 Lakh - ₹1.2 Cr',
        'address': 'Near IT Park, Sector 45, Gurgaon',
        'flatSize': '2BHK, 3BHK, 4BHK',
        'builder': 'Luxury Developers',
        'status': 'upcoming',
        'description': 'Premium residential project with modern amenities and excellent connectivity. Features include swimming pool, gym, clubhouse, and 24/7 security.',
        'imageUrl': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500',
        'createdAt': DateTime.now().toIso8601String(),
        'launchDate': '2024-03-01',
        'completionDate': '2026-12-31',
        'amenities': ['Swimming Pool', 'Gym', 'Clubhouse', '24/7 Security', 'Parking', 'Garden'],
        'location': {
          'latitude': 28.4595,
          'longitude': 77.0266,
        },
        'contactInfo': {
          'phone': '+91 98765 43210',
          'email': 'info@luxurydevelopers.com',
        }
      },
      {
        'id': 'sample2',
        'title': 'Green Valley Residency',
        'price': '₹35 Lakh - ₹85 Lakh',
        'address': 'Whitefield, Bangalore',
        'flatSize': '1BHK, 2BHK, 3BHK',
        'builder': 'Green Valley Builders',
        'status': 'launched',
        'description': 'Eco-friendly residential project with sustainable living features. Built with green technology and energy-efficient systems.',
        'imageUrl': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=500',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'launchDate': '2024-01-15',
        'completionDate': '2025-08-31',
        'amenities': ['Solar Panels', 'Rainwater Harvesting', 'Organic Garden', 'Electric Vehicle Charging', 'Waste Management'],
        'location': {
          'latitude': 12.9716,
          'longitude': 77.5946,
        },
        'contactInfo': {
          'phone': '+91 98765 43211',
          'email': 'info@greenvalleybuilders.com',
        }
      },
      {
        'id': 'sample3',
        'title': 'Ocean View Towers',
        'price': '₹80 Lakh - ₹2.5 Cr',
        'address': 'Marine Drive, Mumbai',
        'flatSize': '2BHK, 3BHK, 4BHK, Penthouse',
        'builder': 'Ocean Developers',
        'status': 'ongoing',
        'description': 'Luxury high-rise project with stunning ocean views. Premium location with world-class amenities and concierge services.',
        'imageUrl': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'launchDate': '2023-06-01',
        'completionDate': '2025-03-31',
        'amenities': ['Ocean View', 'Concierge Service', 'Sky Lounge', 'Infinity Pool', 'Spa', 'Fine Dining Restaurant'],
        'location': {
          'latitude': 18.9445,
          'longitude': 72.8258,
        },
        'contactInfo': {
          'phone': '+91 98765 43212',
          'email': 'info@oceandevelopers.com',
        }
      },
      {
        'id': 'sample4',
        'title': 'Tech Park Residences',
        'price': '₹55 Lakh - ₹1.5 Cr',
        'address': 'Electronic City, Bangalore',
        'flatSize': '2BHK, 3BHK, 4BHK',
        'builder': 'Tech Builders',
        'status': 'completed',
        'description': 'Modern residential project designed for tech professionals. Smart home features and proximity to major IT companies.',
        'imageUrl': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=500',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'launchDate': '2022-01-01',
        'completionDate': '2023-12-31',
        'amenities': ['Smart Home System', 'Co-working Space', 'Tech Lounge', 'High-speed Internet', 'EV Charging'],
        'location': {
          'latitude': 12.8456,
          'longitude': 77.6603,
        },
        'contactInfo': {
          'phone': '+91 98765 43213',
          'email': 'info@techbuilders.com',
        }
      },
    ];
    
    filteredProjects.value = List.from(upcomingProjects);
    _updateStats();
    print('✅ Loaded ${upcomingProjects.length} sample projects');
  }

  /// Update project statistics
  void _updateStats() {
    totalProjects.value = upcomingProjects.length;
    upcomingCount.value = upcomingProjects.where((p) => p['status'] == 'upcoming').length;
    launchedCount.value = upcomingProjects.where((p) => p['status'] == 'launched').length;
    ongoingCount.value = upcomingProjects.where((p) => p['status'] == 'ongoing').length;
    completedCount.value = upcomingProjects.where((p) => p['status'] == 'completed').length;
  }

  /// Filter projects based on search query and status
  void filterProjects() {
    List<Map<String, dynamic>> filtered = List.from(upcomingProjects);
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((project) {
        final title = project['title']?.toString().toLowerCase() ?? '';
        final address = project['address']?.toString().toLowerCase() ?? '';
        final builder = project['builder']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        
        return title.contains(query) || 
               address.contains(query) || 
               builder.contains(query);
      }).toList();
    }
    
    // Filter by status
    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered.where((project) {
        return project['status'] == selectedStatus.value;
      }).toList();
    }
    
    // Sort projects
    filtered.sort((a, b) {
      switch (selectedSortBy.value) {
        case 'title':
          return (a['title'] ?? '').compareTo(b['title'] ?? '');
        case 'price':
          // Simple price comparison (you might want to improve this)
          return (a['price'] ?? '').compareTo(b['price'] ?? '');
        case 'status':
          return (a['status'] ?? '').compareTo(b['status'] ?? '');
        case 'createdAt':
        default:
          return (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? '');
      }
    });
    
    filteredProjects.value = filtered;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterProjects();
  }

  /// Update status filter
  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    filterProjects();
  }

  /// Update sort option
  void updateSortBy(String sortBy) {
    selectedSortBy.value = sortBy;
    filterProjects();
  }

  /// Refresh projects
  Future<void> refreshProjects() async {
    isRefreshing.value = true;
    await loadUpcomingProjects();
    isRefreshing.value = false;
  }

  /// Get project by ID
  Map<String, dynamic>? getProjectById(String id) {
    try {
      return upcomingProjects.firstWhere((project) => project['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get projects by status
  List<Map<String, dynamic>> getProjectsByStatus(String status) {
    return upcomingProjects.where((project) => project['status'] == status).toList();
  }

  /// Get status display text
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'launched':
        return 'Launched';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Get status color
  String getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return '#f39c12'; // Orange
      case 'launched':
        return '#17a2b8'; // Teal
      case 'ongoing':
        return '#3498db'; // Blue
      case 'completed':
        return '#27ae60'; // Green
      default:
        return '#6c757d'; // Gray
    }
  }
}
