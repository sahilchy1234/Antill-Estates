class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? type;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.data,
    this.type,
    this.imageUrl,
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
