import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/objectbox_service.dart';

class CategoryTestScreen extends StatefulWidget {
  const CategoryTestScreen({super.key});

  @override
  State<CategoryTestScreen> createState() => _CategoryTestScreenState();
}

class _CategoryTestScreenState extends State<CategoryTestScreen> {
  List<Category> _categories = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Get categories from ObjectBox
      final categories = ObjectBoxService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading categories: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTestCategory() async {
    try {
      // Create a test category
      final category = Category(
        categoryId: 'test-${DateTime.now().millisecondsSinceEpoch}',
        categoryName: 'Test Category ${DateTime.now().millisecondsSinceEpoch}',
        contentType: 'vod',
        playlistId: 1,
      );

      // Save to ObjectBox
      await ObjectBoxService.saveCategories([category], 'test-connection');

      // Reload categories
      await _loadCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding category: $e';
      });
    }
  }

  Future<void> _clearCategories() async {
    try {
      // Clear categories
      ObjectBoxService.categoriesBox.removeAll();

      // Reload categories
      await _loadCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categories cleared successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error clearing categories: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Test'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _addTestCategory,
                            child: const Text('Add Test Category'),
                          ),
                          ElevatedButton(
                            onPressed: _clearCategories,
                            child: const Text('Clear Categories'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _categories.isEmpty
                          ? const Center(child: Text('No categories found'))
                          : ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return ListTile(
                                  title: Text(category.categoryName),
                                  subtitle: Text(
                                    'ID: ${category.categoryId}, Type: ${category.contentType}',
                                  ),
                                  trailing: Text(
                                    'Playlist ID: ${category.playlistId ?? 'None'}',
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
