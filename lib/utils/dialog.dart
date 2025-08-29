import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/local_image.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class DialogCustom extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String imagePath;
  final String? imageType;
  final String? message;
  final Color? messageColor;
  final String? buttonTitle;
  final Color? backgroundColor;
  final Widget? action;
  final dynamic Function()? onTap;

  const DialogCustom({
    super.key,
    required this.title,
    required this.imagePath,
    this.imageType,
    this.titleColor,
    this.messageColor,
    this.message,
    this.buttonTitle,
    this.onTap,
    this.backgroundColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != '') LocalImage(img: imagePath, type: imageType ?? 'svg', height: 12.h),
              if (imagePath != '') SizedBox(height: 2.h),
              CustomText(text: title, color: titleColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 7, maxLines: 3),
              if (message != null) SizedBox(height: 1.h),
              if (message != null) CustomText(text: message ?? '', color: messageColor ?? Colors.white, maxLines: 4, fontSize: 5),
              SizedBox(height: 2.h),
              action != null
                  ? action!
                  : CustomButton(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 60,
                      title: buttonTitle ?? "موافق",
                      onTap:
                          onTap ??
                          () {
                            Get.back();
                          },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

void showConfirmationDialog({
  required BuildContext buildContext,
  required String content,
  required Future Function() confirm,
  required Function() reject,
}) {
  showGeneralDialog(
    context: buildContext,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withAlpha(128),
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (BuildContext dialogContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      return ConfirmationDialog(content: content, confirm: confirm, reject: reject);
    },
  );
}

void showMessageDialog({
  required BuildContext buildContext,
  required String title,
  required String content,
  String? buttonText,
  VoidCallback? onPressed,
}) {
  showGeneralDialog(
    context: buildContext,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withAlpha(128),
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (BuildContext dialogContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      return MessageDialog(title: title, content: content, buttonText: buttonText, onPressed: onPressed);
    },
  );
}

class ConfirmationDialog extends StatefulWidget {
  final String content;
  final Future Function() confirm;
  final Function() reject;
  const ConfirmationDialog({super.key, required this.content, required this.confirm, required this.reject});

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'تأكيد العملية', fontWeight: FontWeight.bold, fontSize: 6, maxLines: 3),
            SizedBox(height: 1.25.h),
            CustomText(text: widget.content, maxLines: 10, textAlign: TextAlign.start),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await widget.confirm();
                    setState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      Get.back();
                    }
                  },
                  title: 'نعم',
                  textColor: Theme.of(context).colorScheme.onSurface,
                  width: 30,
                  color: Theme.of(context).colorScheme.surface,
                  borderColor: Theme.of(context).primaryColor,
                  loading: isLoading,
                  loadingColor: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 2.w),
                CustomButton(
                  onTap: () {
                    widget.reject();
                    Get.back();
                  },
                  title: 'لا',
                  width: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? buttonText;
  final VoidCallback? onPressed;

  const MessageDialog({super.key, required this.title, required this.content, this.buttonText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: title, fontWeight: FontWeight.bold, fontSize: 6, maxLines: 3),
            SizedBox(height: 1.25.h),
            CustomText(text: content, maxLines: 10),
            SizedBox(height: 5.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CustomButton(
                onTap:
                    onPressed ??
                    () {
                      Get.back();
                    },
                title: buttonText ?? 'حسناً',
                width: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
