import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:hasan2/controllers/search_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class SortSelectionBottomSheet extends StatefulWidget {
  final Function(SortOption)? onSortOptionSelected;

  const SortSelectionBottomSheet({super.key, this.onSortOptionSelected});

  @override
  State<SortSelectionBottomSheet> createState() => _SortSelectionBottomSheetState();
}

class _SortSelectionBottomSheetState extends State<SortSelectionBottomSheet> {
  SortOption? _selectedSortOption;
  final SearchController _searchController = Get.find<SearchController>();

  @override
  void initState() {
    super.initState();
    _selectedSortOption = _searchController.currentSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: "ترتيب النتائج", fontSize: 6, fontWeight: FontWeight.w600),
            SizedBox(height: 2.h),
            ..._searchController.getSortOptions().map(
              (option) => Column(
                children: [
                  _buildSortOption(option, context),
                  if (_searchController.getSortOptions().last != option) SizedBox(height: 1.h),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Center(
              child: CustomButton(
                title: "اختيار وحفظ",
                width: 90.w,
                onTap: () {
                  if (_selectedSortOption != null) {
                    _searchController.setSortOption(_selectedSortOption!);
                    widget.onSortOptionSelected?.call(_selectedSortOption!);
                  }

                  if (context.mounted) {
                    Get.back();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(SortOption sortOption, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortOption = sortOption;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 0.85.h),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4.5.sp)),
        child: Row(
          children: [
            Radio<SortOption>(
              value: sortOption,
              groupValue: _selectedSortOption,
              onChanged: (value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Theme.of(context).colorScheme.secondary.withAlpha(102);
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: CustomText(text: _searchController.getSortOptionName(sortOption), fontSize: 5.5, textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
    );
  }
}
