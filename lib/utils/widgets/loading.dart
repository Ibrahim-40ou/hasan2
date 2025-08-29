import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';

class CustomLoading extends StatelessWidget {
  final Color? loadingColor;
  const CustomLoading({super.key, this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 1.1.w,
      backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
      valueColor: AlwaysStoppedAnimation<Color>(loadingColor ?? Colors.white),
    );
  }
}
