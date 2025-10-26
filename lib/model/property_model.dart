import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String? id;
  final String? userId;
  final String propertyLooking; // buy, rent, pg
  final String category; // residential, commercial
  final String propertyType; // flat, independent house, etc.
  final String city;
  final String locality;
  final String subLocality;
  final String plotArea;
  final String plotAreaUnit;
  final String builtUpArea;
  final String superBuiltUpArea;
  final List<String> otherRooms;
  final String totalFloors;
  final String noOfBedrooms;
  final String noOfBathrooms;
  final String noOfBalconies;
  final int coveredParking;
  final int openParking;
  final String availabilityStatus;
  final List<String> propertyPhotos;
  final String ownership;
  final String expectedPrice;
  final List<String> priceDetails;
  final String description;
  final List<String> amenities;
  final List<String> waterSource;
  final List<String> otherFeatures;
  final List<String> locationAdvantages;
  // User contact information
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String contactAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Property({
    this.id,
    this.userId,
    required this.propertyLooking,
    required this.category,
    required this.propertyType,
    required this.city,
    required this.locality,
    required this.subLocality,
    required this.plotArea,
    required this.plotAreaUnit,
    this.builtUpArea = '',
    this.superBuiltUpArea = '',
    this.otherRooms = const [],
    required this.totalFloors,
    required this.noOfBedrooms,
    required this.noOfBathrooms,
    required this.noOfBalconies,
    this.coveredParking = 0,
    this.openParking = 0,
    required this.availabilityStatus,
    this.propertyPhotos = const [],
    required this.ownership,
    required this.expectedPrice,
    this.priceDetails = const [],
    this.description = '',
    this.amenities = const [],
    this.waterSource = const [],
    this.otherFeatures = const [],
    this.locationAdvantages = const [],
    required this.contactName,
    required this.contactPhone,
    this.contactEmail = '',
    this.contactAvatar = '',
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'propertyLooking': propertyLooking,
      'category': category,
      'propertyType': propertyType,
      'city': city,
      'locality': locality,
      'subLocality': subLocality,
      'plotArea': plotArea,
      'plotAreaUnit': plotAreaUnit,
      'builtUpArea': builtUpArea,
      'superBuiltUpArea': superBuiltUpArea,
      'otherRooms': otherRooms,
      'totalFloors': totalFloors,
      'noOfBedrooms': noOfBedrooms,
      'noOfBathrooms': noOfBathrooms,
      'noOfBalconies': noOfBalconies,
      'coveredParking': coveredParking,
      'openParking': openParking,
      'availabilityStatus': availabilityStatus,
      'propertyPhotos': propertyPhotos,
      'ownership': ownership,
      'expectedPrice': expectedPrice,
      'priceDetails': priceDetails,
      'description': description,
      'amenities': amenities,
      'waterSource': waterSource,
      'otherFeatures': otherFeatures,
      'locationAdvantages': locationAdvantages,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'contactAvatar': contactAvatar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    Timestamp? createdTimestamp;
    Timestamp? updatedTimestamp;

    if (map['createdAt'] is Timestamp) {
      createdTimestamp = map['createdAt'] as Timestamp;
    }
    if (map['updatedAt'] is Timestamp) {
      updatedTimestamp = map['updatedAt'] as Timestamp;
    }

    return Property(
      id: map['id'],
      userId: map['userId'],
      propertyLooking: map['propertyLooking'] ?? '',
      category: map['category'] ?? '',
      propertyType: map['propertyType'] ?? '',
      city: map['city'] ?? '',
      locality: map['locality'] ?? '',
      subLocality: map['subLocality'] ?? '',
      plotArea: map['plotArea'] ?? '',
      plotAreaUnit: map['plotAreaUnit'] ?? '',
      builtUpArea: map['builtUpArea'] ?? '',
      superBuiltUpArea: map['superBuiltUpArea'] ?? '',
      otherRooms: List<String>.from(map['otherRooms'] ?? []),
      totalFloors: map['totalFloors'] ?? '',
      noOfBedrooms: map['noOfBedrooms'] ?? '',
      noOfBathrooms: map['noOfBathrooms'] ?? '',
      noOfBalconies: map['noOfBalconies'] ?? '',
      coveredParking: map['coveredParking'] ?? 0,
      openParking: map['openParking'] ?? 0,
      availabilityStatus: map['availabilityStatus'] ?? '',
      propertyPhotos: List<String>.from(map['propertyPhotos'] ?? []),
      ownership: map['ownership'] ?? '',
      expectedPrice: map['expectedPrice'] ?? '',
      priceDetails: List<String>.from(map['priceDetails'] ?? []),
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      waterSource: List<String>.from(map['waterSource'] ?? []),
      otherFeatures: List<String>.from(map['otherFeatures'] ?? []),
      locationAdvantages: List<String>.from(map['locationAdvantages'] ?? []),
      contactName: map['contactName'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      contactAvatar: map['contactAvatar'] ?? '',
      createdAt: createdTimestamp?.toDate() ??
          (map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null),
      updatedAt: updatedTimestamp?.toDate() ??
          (map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null),
      isActive: map['isActive'] ?? true,
    );
  }
  
  // Convenience methods for JSON serialization (aliases for toMap/fromMap)
  Map<String, dynamic> toJson() => toMap();
  factory Property.fromJson(Map<String, dynamic> json) => Property.fromMap(json);
}
