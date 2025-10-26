import 'package:cloud_firestore/cloud_firestore.dart';

class ArtsAntiquesItem {
  final String? id;
  final String title;
  final String category;
  final String artist;
  final double price;
  final String description;
  final int? year;
  final String dimensions;
  final String materials;
  final String location;
  final String status;
  final bool featured;
  final List<String> images;
  final int views;
  final double rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? contactPhone;
  final String? contactEmail;

  ArtsAntiquesItem({
    this.id,
    required this.title,
    required this.category,
    required this.artist,
    required this.price,
    required this.description,
    this.year,
    this.dimensions = '',
    this.materials = '',
    this.location = '',
    this.status = 'active',
    this.featured = false,
    this.images = const [],
    this.views = 0,
    this.rating = 0.0,
    this.createdAt,
    this.updatedAt,
    this.contactPhone,
    this.contactEmail,
  });

  factory ArtsAntiquesItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArtsAntiquesItem(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      artist: data['artist'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      year: data['year'],
      dimensions: data['dimensions'] ?? '',
      materials: data['materials'] ?? '',
      location: data['location'] ?? '',
      status: data['status'] ?? 'active',
      featured: data['featured'] ?? false,
      images: List<String>.from(data['images'] ?? []),
      views: data['views'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      contactPhone: data['contactPhone'],
      contactEmail: data['contactEmail'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'artist': artist,
      'price': price,
      'description': description,
      'year': year,
      'dimensions': dimensions,
      'materials': materials,
      'location': location,
      'status': status,
      'featured': featured,
      'images': images,
      'views': views,
      'rating': rating,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }

  ArtsAntiquesItem copyWith({
    String? id,
    String? title,
    String? category,
    String? artist,
    double? price,
    String? description,
    int? year,
    String? dimensions,
    String? materials,
    String? location,
    String? status,
    bool? featured,
    List<String>? images,
    int? views,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactPhone,
    String? contactEmail,
  }) {
    return ArtsAntiquesItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      artist: artist ?? this.artist,
      price: price ?? this.price,
      description: description ?? this.description,
      year: year ?? this.year,
      dimensions: dimensions ?? this.dimensions,
      materials: materials ?? this.materials,
      location: location ?? this.location,
      status: status ?? this.status,
      featured: featured ?? this.featured,
      images: images ?? this.images,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}
