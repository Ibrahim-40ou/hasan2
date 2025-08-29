import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class UnitSelectionBottomSheetCustom extends StatefulWidget {
  final Function(String) onUnitSelected;
  final String initialSelection;

  const UnitSelectionBottomSheetCustom({super.key, required this.onUnitSelected, this.initialSelection = ''});

  @override
  State<UnitSelectionBottomSheetCustom> createState() => _UnitSelectionBottomSheetCustomState();
}

class _UnitSelectionBottomSheetCustomState extends State<UnitSelectionBottomSheetCustom> {
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialSelection.isNotEmpty ? widget.initialSelection : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.only(right: 5.w, left: 5.w, top: 3.h, bottom: 3.h),
      decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: "اختر الوحدة", fontSize: 6, fontWeight: FontWeight.w600),
          SizedBox(height: 3.h),
          _buildUnitOption('وزن'),
          SizedBox(height: 1.5.h),
          _buildUnitOption('عدد'),
          SizedBox(height: 3.h),
          Center(
            child: CustomButton(
              title: 'تحديد وحفظ',
              width: 90.w,
              onTap: () {
                if (_selectedUnit != null) {
                  widget.onUnitSelected(_selectedUnit!);
                }
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitOption(String unit) {
    final isSelected = _selectedUnit == unit;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUnit = unit;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 0.85.h),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(4.5.sp)),
        child: Row(
          children: [
            Radio<String>(
              value: unit,
              groupValue: _selectedUnit,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value;
                });
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Theme.of(context).colorScheme.secondary.withAlpha(100);
              }),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: CustomText(text: unit, fontSize: 5.5, textAlign: TextAlign.start),
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 6.w),
              ),
          ],
        ),
      ),
    );
  }
}
