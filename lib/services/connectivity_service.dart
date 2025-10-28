import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Checks if the device is connected to WiFi or hosting a hotspot
  Future<Map<String, dynamic>> getNetworkStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    String? ssid;
    bool isHotspot = false;

    if (connectivityResult == ConnectivityResult.wifi) {
      ssid = await _networkInfo.getWifiName();
      final ip = await _networkInfo.getWifiIP();

      // If device IP is in hotspot range (commonly 192.168.43.1 for Android)
      if (ip == '192.168.43.1' || ip == '192.168.0.1') {
        isHotspot = true;
      }
    }

    return {
      'ssid': ssid ?? 'Not Connected',
      'isHotspot': isHotspot,
      'isWifiConnected': connectivityResult == ConnectivityResult.wifi,
    };
  }
}
