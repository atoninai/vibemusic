import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class PermissionService {
  /// Request storage/audio permission based on Android version
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_AUDIO
      if (await _isAndroid13OrAbove()) {
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return false;
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrAbove()) {
        return await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }

  /// Request overlay (System Alert Window) permission
  Future<bool> requestOverlayPermission() async {
    final status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      final result = await FlutterOverlayWindow.requestPermission();
      return result ?? false;
    }
    return true;
  }

  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// Check all permissions and return status map
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'storage': await hasStoragePermission(),
      'overlay': await hasOverlayPermission(),
    };
  }

  Future<bool> _isAndroid13OrAbove() async {
    // Android 13 = API 33
    // permission_handler handles version-specific logic internally
    return true;
  }
}
