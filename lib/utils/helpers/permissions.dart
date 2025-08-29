import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dialog.dart';
import '../widgets/button.dart';

enum AppPermission {
  camera,
  location,
  locationWhenInUse,
  locationAlways,
  // microphone,
  storage,
  notification,
  // contacts,
  // calendar,
  photos,
}

class PermissionHandlerService with WidgetsBindingObserver {
  static final PermissionHandlerService _instance = PermissionHandlerService._internal();
  factory PermissionHandlerService() => _instance;
  PermissionHandlerService._internal();

  VoidCallback? _pendingOnGranted;
  AppPermission? _pendingPermission;
  BuildContext? _context;
  bool _isCheckingLocationService = false;

  void initialize(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingOnGranted = null;
    _pendingPermission = null;
    _context = null;
    _isCheckingLocationService = false;
  }

  Future<void> requestPermission({
    required AppPermission permission,
    required VoidCallback onGranted,
    String? customMessage,
    bool enableLocationServiceCheck = false,
  }) async {
    _pendingOnGranted = onGranted;
    _pendingPermission = permission;

    if (enableLocationServiceCheck && Platform.isAndroid && _isLocationPermission(permission)) {
      final bool isLocationServiceEnabled = await _isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        _isCheckingLocationService = true;
        _showLocationServiceDialog();
        return;
      }
    }

    await _handlePermissionRequest(permission, onGranted, customMessage);
  }

  Future<void> _handlePermissionRequest(AppPermission permission, VoidCallback onGranted, String? customMessage) async {
    final Permission actualPermission = _getActualPermission(permission);
    final PermissionStatus status = await actualPermission.status;

    if (status.isGranted) {
      onGranted();
      _clearPendingCallback();
      return;
    }

    log('permission state is: $status');

    if (status.isDenied || status.isRestricted) {
      log('permission state is: 1');

      await _requestSystemPermission(actualPermission, permission, onGranted);
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(permission, customMessage);
    }
  }

  Future<void> _requestSystemPermission(Permission permission, AppPermission appPermission, VoidCallback onGranted) async {
    final PermissionStatus result = await permission.request();
    if (result.isGranted) {
      onGranted();
      _clearPendingCallback();
    } else if (result.isPermanentlyDenied) {
      _showSettingsDialog(appPermission, null);
    }
  }

  void _showSettingsDialog(AppPermission permission, String? customMessage) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (BuildContext context) {
        final info = _getPermissionInfo(permission);
        return DialogCustom(
          title: info.title,
          titleColor: Theme.of(context).canvasColor,
          imagePath: info.image,
          imageType: 'png',
          message: customMessage ?? info.message,
          messageColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).colorScheme.surface,
          action: CustomButton(
            title: "المتابعة",
            onTap: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        );
      },
    );
  }

  void _showLocationServiceDialog() {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogCustom(
          title: "خدمة الموقع مطلوبة",
          titleColor: Theme.of(context).canvasColor,
          imagePath: 'location',
          imageType: 'png',
          message: "يجب تفعيل خدمة الموقع أولاً لاستخدام ميزات الموقع. يرجى تفعيل خدمة الموقع من إعدادات الجهاز.",
          messageColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).colorScheme.surface,
          action: CustomButton(
            title: "المتابعة",
            onTap: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
          ),
        );
      },
    );
  }

  Permission _getActualPermission(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.location:
        return Permission.location;
      case AppPermission.locationWhenInUse:
        return Permission.locationWhenInUse;
      case AppPermission.locationAlways:
        return Permission.locationAlways;
      case AppPermission.storage:
        return Permission.storage;
      case AppPermission.notification:
        return Permission.notification;
      case AppPermission.photos:
        return Permission.photos;
    }
  }

  ({String title, String message, String image}) _getPermissionInfo(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return (
          title: "إذن الكاميرا مطلوب",
          message: "نحتاج إلى إذن الكاميرا لتتمكن من التقاط الصور. يرجى تفعيل إذن الكاميرا من إعدادات التطبيق.",
          image: 'camera',
        );
      case AppPermission.location:
      case AppPermission.locationWhenInUse:
      case AppPermission.locationAlways:
        return (
          title: "إذن الموقع مطلوب",
          message: "نحتاج إلى إذن الوصول للموقع للعمل بشكل صحيح. يرجى تفعيل إذن الموقع من إعدادات التطبيق.",
          image: 'map',
        );
      case AppPermission.storage:
      case AppPermission.photos:
        return (
          title: "إذن الصور مطلوب",
          message: "نحتاج إلى إذن الوصول للصور لتتمكن من اختيار الصور من المعرض. يرجى تفعيل إذن الصور من إعدادات التطبيق.",
          image: 'picture',
        );
      case AppPermission.notification:
        return (
          title: "إذن الإشعارات مطلوب",
          message: "نحتاج إلى إذن الإشعارات لإرسال التنبيهات المهمة. يرجى تفعيل إذن الإشعارات من إعدادات التطبيق.",
          image: 'bell',
        );
    }
  }

  Future<bool> _isLocationServiceEnabled() async {
    try {
      if (!Platform.isAndroid) return true;
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      return isServiceEnabled;
    } catch (e) {
      log('Error checking location service: $e');
      return true;
    }
  }

  bool _isLocationPermission(AppPermission permission) {
    return permission == AppPermission.location ||
        permission == AppPermission.locationWhenInUse ||
        permission == AppPermission.locationAlways;
  }

  void _clearPendingCallback() {
    _pendingOnGranted = null;
    _pendingPermission = null;
    _isCheckingLocationService = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (_isCheckingLocationService && _pendingPermission != null) {
        _checkLocationServiceAndProceed();
      } else if (_pendingPermission != null && _pendingOnGranted != null) {
        _checkPendingPermission();
      }
    }
  }

  Future<void> _checkLocationServiceAndProceed() async {
    if (_pendingPermission == null || _pendingOnGranted == null) {
      _clearPendingCallback();
      return;
    }

    final bool isLocationServiceEnabled = await _isLocationServiceEnabled();

    if (isLocationServiceEnabled) {
      _isCheckingLocationService = false;
      await _handlePermissionRequest(_pendingPermission!, _pendingOnGranted!, null);
    } else {
      _clearPendingCallback();
    }
  }

  Future<void> _checkPendingPermission() async {
    if (_pendingPermission == null || _pendingOnGranted == null) return;

    final Permission permission = _getActualPermission(_pendingPermission!);
    final PermissionStatus status = await permission.status;

    if (status.isGranted) {
      final VoidCallback callback = _pendingOnGranted!;
      _clearPendingCallback();
      callback();
    }
  }

  Future<bool> isPermissionGranted(AppPermission permission) async {
    final Permission actualPermission = _getActualPermission(permission);
    final PermissionStatus status = await actualPermission.status;
    return status.isGranted;
  }

  Future<Map<AppPermission, bool>> checkMultiplePermissions(List<AppPermission> permissions) async {
    final Map<AppPermission, bool> results = {};

    for (final permission in permissions) {
      results[permission] = await isPermissionGranted(permission);
    }

    return results;
  }

  // Utility method to check if location service is enabled (public method)
  Future<bool> isLocationServiceEnabled() async {
    return await _isLocationServiceEnabled();
  }
}
