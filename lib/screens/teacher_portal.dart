import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../models/class_session.dart';
import '../services/firebase_service.dart';

class TeacherPortal extends StatefulWidget {
  const TeacherPortal({super.key});

  @override
  State<TeacherPortal> createState() => _TeacherPortalState();
}

class _TeacherPortalState extends State<TeacherPortal> {
  final FirebaseService _firebaseService = FirebaseService();
  final NetworkInfo _networkInfo = NetworkInfo();
  String wifiStatus = "Checking...";
  bool hotspotReady = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
    _checkConnectivityStatus();
  }

  Future<void> _checkConnectivityStatus() async {
    setState(() {
      wifiStatus = "Checking...";
      hotspotReady = false;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    String? wifiName;
    String? ipAddress;

    try {
      wifiName = await _networkInfo.getWifiName();
      ipAddress = await _networkInfo.getWifiIP();
    } catch (_) {
      wifiName = null;
      ipAddress = null;
    }

    setState(() {
      if (connectivityResult == ConnectivityResult.wifi && wifiName != null) {
        wifiStatus = "Connected to Wi-Fi: $wifiName";
        hotspotReady = false;
      } else if (ipAddress != null && ipAddress.startsWith("192.168.")) {
        wifiStatus = "Hotspot Active (Hosting)";
        hotspotReady = true;
      } else {
        wifiStatus = "No Wi-Fi or Hotspot Detected";
        hotspotReady = false;
      }
    });
  }

  Future<void> _openHotspotSettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.TETHER_SETTINGS',
    );
    await intent.launch();
  }

  Future<void> _startClass() async {
    if (!hotspotReady) return;

    final now = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(now);
    final formattedTime = DateFormat('hh:mm a').format(now);

    final session = ClassSession(
      teacherName: "Prof. Sharma",
      subject: "Network Fundamentals",
      date: formattedDate,
      time: formattedTime,
    );

    await _firebaseService.createClassSession(session);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class session started successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text(
          "LearnTrack - Teacher Portal",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.indigoAccent.withOpacity(0.4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigoAccent, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_tethering, color: Colors.white, size: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "Hotspot & Class Control",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(
                          hotspotReady ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: hotspotReady ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        title: const Text(
                          "Current Status",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          wifiStatus,
                          style: TextStyle(
                            color: hotspotReady ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _checkConnectivityStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openHotspotSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text("Hotspot Settings"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: hotspotReady ? _startClass : null,
                      icon: const Icon(Icons.play_circle_fill, size: 26),
                      label: const Text(
                        "Start Class",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hotspotReady ? Colors.greenAccent.shade700 : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!hotspotReady)
                      const Text(
                        "⚠️ Please enable your hotspot to start class",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Powered by LearnTrack",
                style: TextStyle(
                  color: Colors.indigo.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
