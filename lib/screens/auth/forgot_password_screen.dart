import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/auth_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "", isBackButtonVisible: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Form(
            key: authController.forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),

                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.lock, size: 15.w, color: Theme.of(context).colorScheme.primary),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: 'إعادة تعيين كلمة المرور',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 0.5.h),
                      CustomText(
                        text: 'أدخل بريدك الإلكتروني لاستلام رابط إعادة تعيين كلمة المرور',
                        fontSize: 5,
                        color: Theme.of(context).colorScheme.secondary,
                        textAlign: TextAlign.center,
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                CustomField(
                  controller: authController.forgotPasswordEmailController,
                  hintText: 'البريد الإلكتروني',
                  labelText: 'البريد الإلكتروني',
                  showRedStar: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: authController.validateEmail,
                  onSubmitted: (_) => authController.forgotPassword(context),
                ),
                SizedBox(height: 4.h),
                GetBuilder<AuthController>(
                  builder: (controller) => CustomButton(
                    title: 'إرسال رسالة إعادة التعيين',
                    loading: controller.isLoading,
                    onTap: () {
                      controller.forgotPassword(context);
                    },
                    width: 100,
                    verticalPadding: 1.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: GestureDetector(
                    onTap: Get.back,
                    child: CustomText(
                      text: 'العودة لتسجيل الدخول',
                      fontSize: 5,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
