import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/theme_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

List<Map<String, dynamic>> getThemeOptions() {
  return [
    {'mode': ThemeMode.dark, 'name': "تشغيل"},
    {'mode': ThemeMode.light, 'name': "إيقاف"},
    {'mode': ThemeMode.system, 'name': "النظام"},
  ];
}

class DarkModeSelectionBottomSheet extends StatefulWidget {
  final Function(ThemeMode)? onThemeModeSelected;

  const DarkModeSelectionBottomSheet({super.key, this.onThemeModeSelected});

  @override
  State<DarkModeSelectionBottomSheet> createState() => _DarkModeSelectionBottomSheetState();
}

class _DarkModeSelectionBottomSheetState extends State<DarkModeSelectionBottomSheet> {
  ThemeMode? _selectedThemeMode;
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = _themeController.themeMode;
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
            CustomText(text: "الوضع الليلي", fontSize: 6, fontWeight: FontWeight.w600),
            SizedBox(height: 2.h),
            ...getThemeOptions().map(
              (option) => Column(
                children: [
                  _buildThemeOption(option, context),
                  if (getThemeOptions().last != option) SizedBox(height: 1.h),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Center(
              child: CustomButton(
                title: "اختيار وحفظ",
                width: 90.w,
                onTap: () {
                  if (_selectedThemeMode != null) {
                    _themeController.changeThemeMode(_selectedThemeMode!);
                    widget.onThemeModeSelected?.call(_selectedThemeMode!);
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

  Widget _buildThemeOption(Map<String, dynamic> option, BuildContext context) {
    final ThemeMode themeMode = option['mode'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThemeMode = themeMode;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 0.85.h),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4.5.sp)),
        child: Row(
          children: [
            Radio<ThemeMode>(
              value: themeMode,
              groupValue: _selectedThemeMode,
              onChanged: (value) {
                setState(() {
                  _selectedThemeMode = value!;
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
              child: CustomText(text: option['name'] as String, fontSize: 5.5, textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
    );
  }
}
