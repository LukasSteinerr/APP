class Category {
  final String categoryId;
  final String categoryName;
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
}
