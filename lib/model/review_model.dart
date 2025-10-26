import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String propertyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerified;

  Review({
    this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    Timestamp? createdTimestamp;

    if (map['createdAt'] is Timestamp) {
      createdTimestamp = map['createdAt'] as Timestamp;
    }

    return Review(
      id: map['id'],
      propertyId: map['propertyId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: createdTimestamp?.toDate() ??
          (map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
      isVerified: map['isVerified'] ?? false,
    );
  }

  Review copyWith({
    String? id,
    String? propertyId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return Review(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
