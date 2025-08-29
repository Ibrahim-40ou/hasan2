import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/screens/auth/login_screen.dart';
import 'package:hasan2/screens/main/main_screen.dart';
import 'package:hasan2/utils/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  bool get isLoading => _isLoading;

  bool get isPasswordVisible => _isPasswordVisible;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotPasswordEmailController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    update();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    update();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!GetUtils.isEmail(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      emailController.clear();
      passwordController.clear();

      Get.offAll(MainScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة مرور خاطئة';
          break;
        case 'invalid-email':
          errorMessage = 'يرجى إدخال بريد إلكتروني صحيح';
          break;
        case 'user-disabled':
          errorMessage = 'تم تعطيل هذا الحساب';
          break;
        case 'too-many-requests':
          errorMessage = 'محاولات فاشلة كثيرة. يرجى المحاولة لاحقاً';
          break;
        case 'network-request-failed':
          errorMessage = 'خطأ في الشبكة. يرجى التحقق من اتصالك';
          break;
      }

      showMessageDialog(buildContext: Get.context!, title: 'تنبيه', content: errorMessage);
    } catch (e) {
      showMessageDialog(buildContext: Get.context!, title: 'تنبيه', content: 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى');
    } finally {
      setLoading(false);
    }
  }

  Future<void> forgotPassword(BuildContext context) async {
    if (!forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    final email = forgotPasswordEmailController.text.trim();

    setLoading(true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      forgotPasswordEmailController.clear();

      if (context.mounted) {
        showMessageDialog(buildContext: context, title: 'تم بنجاح', content: 'تم إرسال رابط إعادة تعيين كلمة المرور بنجاح');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'فشل في إرسال رابط إعادة التعيين. يرجى المحاولة مرة أخرى';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'يرجى إدخال بريد إلكتروني صحيح';
          break;
        case 'too-many-requests':
          errorMessage = 'محاولات فاشلة كثيرة. يرجى المحاولة لاحقاً';
          break;
        case 'network-request-failed':
          errorMessage = 'خطأ في الشبكة. يرجى التحقق من اتصالك';
          break;
        default:
          break;
      }

      showMessageDialog(buildContext: context, title: 'تنبيه', content: errorMessage);
    } catch (e) {
      showMessageDialog(buildContext: context, title: 'تنبيه', content: 'فشل في إرسال رابط إعادة التعيين. يرجى المحاولة مرة أخرى');
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    Get.offAll(() => LoginScreen());
  }
}
