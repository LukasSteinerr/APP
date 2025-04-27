import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String categoryId;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final String parentId;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? '',
      parentId: json['parent_id']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'category_name': categoryName,
    'parent_id': parentId,
  };
}
