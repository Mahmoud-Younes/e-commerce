import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/colors.dart';

/// Horizontal category filter (PRD §2: browse products by category). The
/// first chip is "All" (`selectedCategory == null`).
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              selectedColor: ColorsManager.mainGreen,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? ColorsManager.white
                    : ColorsManager.darkerGray,
              ),
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...categories.map(
            (category) => Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                selectedColor: ColorsManager.mainGreen,
                labelStyle: TextStyle(
                  color: selectedCategory == category
                      ? ColorsManager.white
                      : ColorsManager.darkerGray,
                ),
                onSelected: (_) => onSelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
