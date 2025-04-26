import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;
  final bool showAllOption;
  
  const CategoryList({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.showAllOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: showAllOption ? categories.length + 1 : categories.length,
        padding: const EdgeInsets.symmetric(horizontal: AppPaddings.medium),
        itemBuilder: (context, index) {
          if (showAllOption && index == 0) {
            // "All" category option
            return Padding(
              padding: const EdgeInsets.only(right: AppPaddings.small),
              child: ChoiceChip(
                label: const Text(AppStrings.allCategories),
                selected: selectedCategoryId == null,
                onSelected: (_) => onCategorySelected(''),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selectedCategoryId == null
                      ? AppColors.text
                      : AppColors.textSecondary,
                ),
              ),
            );
          }
          
          final category = showAllOption
              ? categories[index - 1]
              : categories[index];
          
          return Padding(
            padding: const EdgeInsets.only(right: AppPaddings.small),
            child: ChoiceChip(
              label: Text(category.categoryName),
              selected: selectedCategoryId == category.categoryId,
              onSelected: (_) => onCategorySelected(category.categoryId),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selectedCategoryId == category.categoryId
                    ? AppColors.text
                    : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
