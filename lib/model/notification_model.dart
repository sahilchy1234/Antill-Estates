class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? type;
  final String? imageUrl;
  
  // Enhanced fields for in-app notification panel
  final bool isViewed;  // Track if user has viewed the full notification
  final String? itemId; // ID of the property/project/art item
  final String? itemType; // 'property', 'project', 'arts_antiques'
  final String? actionUrl; // Deep link or route to the item
  final String? actionText; // Text for action button
  final List<String>? images; // Multiple images for the notification
  final String? price; // Price information
  final String? location; // Location information

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.type,
    this.imageUrl,
    this.isViewed = false,
    this.itemId,
    this.itemType,
    this.actionUrl,
    this.actionText,
    this.images,
    this.price,
    this.location,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isRead: json['isRead'] ?? false,
      data: json['data'],
      type: json['type'],
      imageUrl: json['imageUrl'],
      isViewed: json['isViewed'] ?? false,
      itemId: json['itemId'],
      itemType: json['itemType'],
      actionUrl: json['actionUrl'],
      actionText: json['actionText'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      price: json['price'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp,
      'isRead': isRead,
      'data': data,
      'type': type,
      'imageUrl': imageUrl,
      'isViewed': isViewed,
      'itemId': itemId,
      'itemType': itemType,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'images': images,
      'price': price,
      'location': location,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
    String? type,
    String? imageUrl,
    bool? isViewed,
    String? itemId,
    String? itemType,
    String? actionUrl,
    String? actionText,
    List<String>? images,
    String? price,
    String? location,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isViewed: isViewed ?? this.isViewed,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      images: images ?? this.images,
      price: price ?? this.price,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, subtitle: $subtitle, timestamp: $timestamp, isRead: $isRead, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
