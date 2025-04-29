import 'package:objectbox/objectbox.dart';

@Entity()
class Category {
  @Id()
  int id = 0;

  String categoryId;
  String categoryName;
  String parentId;

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
