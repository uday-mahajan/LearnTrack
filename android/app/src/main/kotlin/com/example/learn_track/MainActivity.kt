package com.example.learn_track

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import java.lang.reflect.Method

class MainActivity : FlutterActivity() {
    private val CHANNEL = "learn_track/network"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isHotspotEnabled" -> {
                        result.success(isWifiApEnabled())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isWifiApEnabled(): Boolean {
        return try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val method: Method? = wifiManager.javaClass.getDeclaredMethod("isWifiApEnabled")
            method?.isAccessible = true
            val enabled = method?.invoke(wifiManager) as? Boolean
            enabled == true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
