package com.example.music

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: AudioServiceActivity() {
    private val METHOD_CHANNEL = "com.example.music/headphone"
    private val EVENT_CHANNEL = "com.example.music/headphone_events"

    private var headsetReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isHeadphonePlugged" -> {
                    result.success(isHeadphoneConnected())
                }
                "setEqualizerPreset" -> {
                    val preset = call.argument<String>("preset") ?: "Normal"
                    val success = applyEqualizerPreset(preset)
                    result.success(success)
                }
                "setBassBoost" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    val success = applyBassBoost(strength)
                    result.success(success)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                events?.success(isHeadphoneConnected())
                registerHeadsetReceiver()
            }

            override fun onCancel(arguments: Any?) {
                unregisterHeadsetReceiver()
                eventSink = null
            }
        })
    }

    private var audioDeviceCallback: android.media.AudioDeviceCallback? = null

    private fun isHeadphoneConnected(): Boolean {
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return false
            var connected = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                connected = devices.any { device ->
                    device.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                    device.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
                    device.type == AudioDeviceInfo.TYPE_USB_HEADSET ||
                    device.type == AudioDeviceInfo.TYPE_USB_DEVICE ||
                    device.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                    device.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
                    device.type == AudioDeviceInfo.TYPE_BLE_HEADSET ||
                    device.type == AudioDeviceInfo.TYPE_LINE_ANALOG ||
                    device.type == AudioDeviceInfo.TYPE_LINE_DIGITAL ||
                    device.type == AudioDeviceInfo.TYPE_HEARING_AID
                }
            }
            if (!connected) {
                val sticky = registerReceiver(null, IntentFilter(Intent.ACTION_HEADSET_PLUG))
                if (sticky != null) {
                    connected = sticky.getIntExtra("state", -1) == 1
                }
            }
            if (!connected) {
                @Suppress("DEPRECATION")
                connected = audioManager.isWiredHeadsetOn || audioManager.isBluetoothA2dpOn || audioManager.isBluetoothScoOn
            }
            connected
        } catch (_: Exception) {
            false
        }
    }

    private fun registerHeadsetReceiver() {
        if (headsetReceiver == null) {
            headsetReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    val isConnected = isHeadphoneConnected()
                    eventSink?.success(isConnected)
                    if (!isConnected) {
                        disableEqualizer()
                    }
                }
            }
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_HEADSET_PLUG)
                addAction(AudioManager.ACTION_AUDIO_BECOMING_NOISY)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(headsetReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(headsetReceiver, filter)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && audioDeviceCallback == null) {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            if (audioManager != null) {
                audioDeviceCallback = object : android.media.AudioDeviceCallback() {
                    override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>?) {
                        eventSink?.success(isHeadphoneConnected())
                    }

                    override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>?) {
                        val isConnected = isHeadphoneConnected()
                        eventSink?.success(isConnected)
                        if (!isConnected) {
                            disableEqualizer()
                        }
                    }
                }
                audioManager.registerAudioDeviceCallback(audioDeviceCallback, null)
            }
        }
    }

    private fun unregisterHeadsetReceiver() {
        headsetReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {}
            headsetReceiver = null
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && audioDeviceCallback != null) {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            try {
                audioManager?.unregisterAudioDeviceCallback(audioDeviceCallback)
            } catch (_: Exception) {}
            audioDeviceCallback = null
        }
    }

    private fun initAudioEffects() {
        try {
            if (equalizer == null) {
                equalizer = Equalizer(0, 0).apply { enabled = true }
            }
            if (bassBoost == null) {
                bassBoost = BassBoost(0, 0).apply { enabled = true }
            }
        } catch (_: Exception) {}
    }

    private fun disableEqualizer() {
        try {
            equalizer?.enabled = false
            bassBoost?.enabled = false
        } catch (_: Exception) {}
    }

    private fun applyEqualizerPreset(presetName: String): Boolean {
        if (!isHeadphoneConnected()) {
            disableEqualizer()
            return false
        }
        return try {
            initAudioEffects()
            val eq = equalizer ?: return false
            eq.enabled = true
            val numPresets = eq.numberOfPresets
            var matchedIndex: Short = -1
            for (i in 0 until numPresets) {
                val name = eq.getPresetName(i.toShort())
                if (name.equals(presetName, ignoreCase = true)) {
                    matchedIndex = i.toShort()
                    break
                }
            }
            if (matchedIndex >= 0) {
                eq.usePreset(matchedIndex)
            } else {
                val numBands = eq.numberOfBands
                val minLevel = eq.bandLevelRange[0]
                val maxLevel = eq.bandLevelRange[1]
                val midLevel = 0.toShort()
                when (presetName.lowercase()) {
                    "rock" -> {
                        if (numBands >= 5) {
                            eq.setBandLevel(0, (maxLevel * 0.7).toInt().toShort())
                            eq.setBandLevel(1, (maxLevel * 0.4).toInt().toShort())
                            eq.setBandLevel(2, (minLevel * 0.2).toInt().toShort())
                            eq.setBandLevel(3, (maxLevel * 0.5).toInt().toShort())
                            eq.setBandLevel(4, (maxLevel * 0.8).toInt().toShort())
                        }
                    }
                    "jazz" -> {
                        if (numBands >= 5) {
                            eq.setBandLevel(0, (maxLevel * 0.4).toInt().toShort())
                            eq.setBandLevel(1, (maxLevel * 0.2).toInt().toShort())
                            eq.setBandLevel(2, midLevel)
                            eq.setBandLevel(3, (maxLevel * 0.3).toInt().toShort())
                            eq.setBandLevel(4, (maxLevel * 0.5).toInt().toShort())
                        }
                    }
                    "pop" -> {
                        if (numBands >= 5) {
                            eq.setBandLevel(0, (minLevel * 0.2).toInt().toShort())
                            eq.setBandLevel(1, (maxLevel * 0.3).toInt().toShort())
                            eq.setBandLevel(2, (maxLevel * 0.6).toInt().toShort())
                            eq.setBandLevel(3, (maxLevel * 0.3).toInt().toShort())
                            eq.setBandLevel(4, (minLevel * 0.2).toInt().toShort())
                        }
                    }
                    "classical" -> {
                        if (numBands >= 5) {
                            eq.setBandLevel(0, (maxLevel * 0.5).toInt().toShort())
                            eq.setBandLevel(1, (maxLevel * 0.3).toInt().toShort())
                            eq.setBandLevel(2, (minLevel * 0.2).toInt().toShort())
                            eq.setBandLevel(3, (maxLevel * 0.4).toInt().toShort())
                            eq.setBandLevel(4, (maxLevel * 0.6).toInt().toShort())
                        }
                    }
                    "bass boost" -> {
                        if (numBands >= 5) {
                            eq.setBandLevel(0, maxLevel)
                            eq.setBandLevel(1, (maxLevel * 0.7).toInt().toShort())
                            eq.setBandLevel(2, midLevel)
                            eq.setBandLevel(3, midLevel)
                            eq.setBandLevel(4, midLevel)
                        }
                        bassBoost?.let {
                            it.enabled = true
                            it.setStrength(1000.toShort())
                        }
                    }
                    else -> {
                        for (b in 0 until numBands) {
                            eq.setBandLevel(b.toShort(), midLevel)
                        }
                    }
                }
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun applyBassBoost(strength: Int): Boolean {
        if (!isHeadphoneConnected()) return false
        return try {
            initAudioEffects()
            bassBoost?.let {
                it.enabled = strength > 0
                it.setStrength(strength.coerceIn(0, 1000).toShort())
                true
            } ?: false
        } catch (_: Exception) {
            false
        }
    }

    override fun onDestroy() {
        unregisterHeadsetReceiver()
        try {
            equalizer?.release()
            bassBoost?.release()
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
