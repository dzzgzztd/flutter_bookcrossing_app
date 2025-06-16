import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String ownerId;
  final String title;
  final String author;
  final String description;
  final String? imageUrl;
  final String genre;
  final String condition;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;

  BookModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.author,
    required this.description,
    this.imageUrl,
    required this.genre,
    required this.condition,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.isAvailable = true,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      genre: json['genre'] ?? '',
      condition: json['condition'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'genre': genre,
      'condition': condition,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
    };
  }

  BookModel copyWith({
    String? title,
    String? author,
    String? genre,
    String? condition,
    String? description,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool? isAvailable,
  }) {
    return BookModel(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      genre: genre ?? this.genre,
      condition: condition ?? this.condition,
      createdAt: createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
