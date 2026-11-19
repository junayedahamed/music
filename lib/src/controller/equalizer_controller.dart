import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class EqualizerController extends GetxController {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.music/headphone');
  static const EventChannel _eventChannel =
      EventChannel('com.example.music/headphone_events');

  final isHeadphonePlugged = true.obs;
  final hasNativeSupport = true.obs;
  final currentPreset = "Normal".obs;
  final bassLevel = 0.0.obs; // 0.0 to 1.0

  final List<String> presets = const [
    "Normal",
    "Jazz",
    "Rock",
    "Pop",
    "Classical",
    "Bass Boost",
  ];

  StreamSubscription<dynamic>? _headphoneSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadSavedState();
    checkHeadphoneStatus();
    _listenToHeadphoneEvents();
  }

  void _loadSavedState() {
    try {
      final box = Hive.box<Map>("music");
      final saved = box.get("equalizer_prefs");
      if (saved != null) {
        if (saved["preset"] != null) {
          currentPreset.value = saved["preset"] as String;
        }
        if (saved["bass"] != null) {
          bassLevel.value = (saved["bass"] as num).toDouble();
        }
        if (saved["headphoneOverride"] != null) {
          isHeadphonePlugged.value = saved["headphoneOverride"] as bool;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveState() async {
    try {
      final box = Hive.box<Map>("music");
      await box.put("equalizer_prefs", {
        "preset": currentPreset.value,
        "bass": bassLevel.value,
        "headphoneOverride": isHeadphonePlugged.value,
      });
    } catch (_) {}
  }

  Future<void> checkHeadphoneStatus() async {
    try {
      final bool? plugged =
          await _methodChannel.invokeMethod<bool>('isHeadphonePlugged');
      if (plugged != null) {
        hasNativeSupport.value = true;
        isHeadphonePlugged.value = plugged;
      }
    } on MissingPluginException {
      hasNativeSupport.value = false;
      // Native plugin not present in older APK bytecode -> unlock by default
      isHeadphonePlugged.value = true;
    } catch (_) {
      hasNativeSupport.value = false;
      isHeadphonePlugged.value = true;
    }
  }

  void _listenToHeadphoneEvents() {
    try {
      _headphoneSubscription =
          _eventChannel.receiveBroadcastStream().handleError((error) {
        hasNativeSupport.value = false;
      }).listen(
        (dynamic event) {
          if (event is bool) {
            hasNativeSupport.value = true;
            isHeadphonePlugged.value = event;
            _saveState();
            if (event) {
              setPreset(currentPreset.value);
              setBass(bassLevel.value);
            }
          }
        },
        onError: (_) {
          hasNativeSupport.value = false;
        },
        cancelOnError: false,
      );
    } on MissingPluginException {
      hasNativeSupport.value = false;
    } catch (_) {
      hasNativeSupport.value = false;
    }
  }

  void toggleHeadphoneOverride([bool? forceState]) {
    isHeadphonePlugged.value = forceState ?? !isHeadphonePlugged.value;
    _saveState();
    if (isHeadphonePlugged.value) {
      setPreset(currentPreset.value);
      setBass(bassLevel.value);
    }
    Get.rawSnackbar(
      message: isHeadphonePlugged.value
          ? "Headphone override ENABLED (Audio effects active)"
          : "Headphone override DISABLED",
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xff1f212c),
      icon: Icon(
        isHeadphonePlugged.value
            ? Icons.headphones_rounded
            : Icons.headset_off_rounded,
        color: const Color(0xff00b0ff),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  Future<void> setPreset(String preset) async {
    currentPreset.value = preset;
    _saveState();
    if (!isHeadphonePlugged.value) return;
    try {
      await _methodChannel
          .invokeMethod('setEqualizerPreset', {'preset': preset});
    } on MissingPluginException {
      hasNativeSupport.value = false;
    } catch (_) {}
  }

  Future<void> setBass(double value) async {
    bassLevel.value = value;
    _saveState();
    if (!isHeadphonePlugged.value) return;
    try {
      await _methodChannel
          .invokeMethod('setBassBoost', {'strength': (value * 1000).round()});
    } on MissingPluginException {
      hasNativeSupport.value = false;
    } catch (_) {}
  }

  @override
  void onClose() {
    _headphoneSubscription?.cancel();
    super.onClose();
  }
}
