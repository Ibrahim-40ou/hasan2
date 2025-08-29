import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/auth_controller.dart';
import 'package:hasan2/screens/auth/forgot_password_screen.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Form(
            key: authController.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.shop5, size: 15.w, color: Theme.of(context).colorScheme.primary),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: 'مرحباً بعودتك',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 0.5.h),
                      CustomText(text: 'سجل دخولك للمتابعة', fontSize: 5, color: Theme.of(context).colorScheme.secondary),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                CustomField(
                  controller: authController.emailController,
                  hintText: 'البريد الإلكتروني',
                  labelText: 'البريد الإلكتروني',
                  showRedStar: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: authController.validateEmail,
                ),
                SizedBox(height: 2.h),
                GetBuilder<AuthController>(
                  builder: (controller) => CustomField(
                    controller: controller.passwordController,
                    hintText: 'كلمة المرور',
                    labelText: 'كلمة المرور',
                    showRedStar: true,
                    obscureText: !controller.isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    validator: controller.validatePassword,
                    suffixIcon: controller.isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                    suffixIconOnTap: controller.togglePasswordVisibility,
                    onSubmitted: (_) => controller.login(),
                    maxLines: 1,
                  ),
                ),

                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(ForgotPasswordScreen()),
                    child: CustomText(
                      text: 'نسيت كلمة المرور؟',
                      fontSize: 4.5,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // Login Button
                GetBuilder<AuthController>(
                  builder: (controller) => CustomButton(
                    title: 'تسجيل الدخول',
                    loading: controller.isLoading,
                    onTap: controller.login,
                    width: 100,
                    verticalPadding: 1.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Center(
                  child: CustomText(
                    text: 'أدخل بياناتك للوصول إلى حسابك واستخدام التطبيق',
                    fontSize: 4,
                    color: Theme.of(context).colorScheme.secondary,
                    textAlign: TextAlign.center,
                    maxLines: 3,
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
