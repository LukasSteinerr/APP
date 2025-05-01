/// A simple class to represent a category item in the UI
/// This replaces the Category entity which is now deprecated
///
/// Unlike Category, this class is not an ObjectBox entity and is not stored in the database.
/// Instead, category information is stored directly in the content objects (Movie, Series, Channel).
class CategoryItem {
  final String categoryId;
  final String categoryName;

  CategoryItem({required this.categoryId, required this.categoryName});
}
