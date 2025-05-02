import 'package:objectbox/objectbox.dart';

@Entity()
class Category {
  @Id()
  int id = 0; // ObjectBox ID (PRIMARY KEY AUTOINCREMENT)

  int? playlistId; // Foreign key to the playlists table
  String categoryId; // Original ID from the IPTV provider
  String categoryName; // Display name of the category
  String contentType; // 'vod', 'live', or 'series'
  int? parentId; // For hierarchical categories (nullable)

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.contentType,
    this.playlistId,
    this.parentId,
  });

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? '',
      contentType: json['content_type'] ?? 'vod',
      playlistId: json['playlist_id'] != null ? int.parse(json['playlist_id'].toString()) : null,
      parentId: json['parent_id'] != null ? int.parse(json['parent_id'].toString()) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'content_type': contentType,
      'playlist_id': playlistId,
      'parent_id': parentId,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, playlistId: $playlistId, categoryId: $categoryId, categoryName: $categoryName, contentType: $contentType, parentId: $parentId}';
  }
}
