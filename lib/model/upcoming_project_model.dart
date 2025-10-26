class UpcomingProject {
  final String? id;
  final String title;
  final String price;
  final String address;
  final String flatSize;
  final String builder;
  final String status;
  final String? description;
  final String? imageUrl;
  final String? launchDate;
  final String? completionDate;
  final Map<String, dynamic>? contactInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UpcomingProject({
    this.id,
    required this.title,
    required this.price,
    required this.address,
    required this.flatSize,
    required this.builder,
    required this.status,
    this.description,
    this.imageUrl,
    this.launchDate,
    this.completionDate,
    this.contactInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory UpcomingProject.fromMap(Map<String, dynamic> map) {
    return UpcomingProject(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      flatSize: map['flatSize']?.toString() ?? '',
      builder: map['builder']?.toString() ?? '',
      status: map['status']?.toString() ?? 'upcoming',
      description: map['description']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      launchDate: map['launchDate']?.toString(),
      completionDate: map['completionDate']?.toString(),
      contactInfo: map['contactInfo'] as Map<String, dynamic>?,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] 
              : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'address': address,
      'flatSize': flatSize,
      'builder': builder,
      'status': status,
      'description': description,
      'imageUrl': imageUrl,
      'launchDate': launchDate,
      'completionDate': completionDate,
      'contactInfo': contactInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UpcomingProject copyWith({
    String? id,
    String? title,
    String? price,
    String? address,
    String? flatSize,
    String? builder,
    String? status,
    String? description,
    String? imageUrl,
    String? launchDate,
    String? completionDate,
    Map<String, dynamic>? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UpcomingProject(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      address: address ?? this.address,
      flatSize: flatSize ?? this.flatSize,
      builder: builder ?? this.builder,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      launchDate: launchDate ?? this.launchDate,
      completionDate: completionDate ?? this.completionDate,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UpcomingProject(id: $id, title: $title, price: $price, address: $address, flatSize: $flatSize, builder: $builder, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpcomingProject &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.address == address &&
        other.flatSize == flatSize &&
        other.builder == builder &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        price.hashCode ^
        address.hashCode ^
        flatSize.hashCode ^
        builder.hashCode ^
        status.hashCode;
  }
}
