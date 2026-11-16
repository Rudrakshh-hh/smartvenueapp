import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BeaconNavigationScreen extends StatefulWidget {
  const BeaconNavigationScreen({super.key});

  @override
  _BeaconNavigationScreenState createState() => _BeaconNavigationScreenState();
}

class _BeaconNavigationScreenState extends State<BeaconNavigationScreen> {
  // We use standard UUIDs for BLE advertising
  final String _venueUUID = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D';
  
  bool _isBroadcasting = false;
  bool _isScanning = false;
  
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  StreamSubscription? _scanSubscription;
  
  ScanResult? _closestBeacon;
  String _radarText = "Looking for nearby rooms...";
  Color _radarColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _stopScanning();
    _stopBroadcasting();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
  }

  // ==========================================
  // ANCHOR DEVICE (BROADCASTER)
  // ==========================================
  Future<void> _toggleBroadcasting() async {
    if (_isBroadcasting) {
      _stopBroadcasting();
    } else {
      _startBroadcasting();
    }
  }

  Future<void> _startBroadcasting() async {
    if (await blePeripheral.isSupported == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("BLE Advertising not supported on this device.")),
      );
      return;
    }

    try {
      final AdvertiseDataCore advertiseData = AdvertiseDataCore(
        serviceUuid: _venueUUID,
        localName: 'GEHU_Room_224',
      );

      await blePeripheral.start(advertiseData: advertiseData);
      
      setState(() {
        _isBroadcasting = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Now broadcasting as Room 224 Anchor!"))
      );
    } catch (e) {
      debugPrint("Broadcasting Error: \$e");
    }
  }

  Future<void> _stopBroadcasting() async {
    await blePeripheral.stop();
    setState(() {
      _isBroadcasting = false;
    });
  }


  // ==========================================
  // NAVIGATOR DEVICE (SCANNER)
  // ==========================================
  Future<void> _toggleScanning() async {
    if (_isScanning) {
      _stopScanning();
    } else {
      _startScanning();
    }
  }

  Future<void> _startScanning() async {
    // Make sure Bluetooth is on
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
    }

    try {
      // Start scanning specifically for our UUID
      await FlutterBluePlus.startScan(
        withServices: [Guid(_venueUUID)],
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (results.isNotEmpty) {
          // Sort by RSSI (closest first, closer to 0 is better)
          results.sort((a, b) => b.rssi.compareTo(a.rssi));
          final closest = results.first;
          
          setState(() {
            _closestBeacon = closest;
            _updateRadarUI(closest.rssi);
          });
        } else {
          setState(() {
            _closestBeacon = null;
            _radarText = "Signal lost. Keep walking.";
            _radarColor = Colors.grey;
          });
        }
      });
      
      setState(() {
        _isScanning = true;
        _radarText = "Scanning for venue beacons...";
      });
    } catch (e) {
      debugPrint("Scanning Error: \$e");
    }
  }

  void _updateRadarUI(int rssi) {
    // RSSI is a negative number, usually between -30 (very close) and -100 (very far)
    if (rssi > -50) {
      _radarText = "You have arrived! (RSSI: \$rssi)";
      _radarColor = Colors.green;
    } else if (rssi > -65) {
      _radarText = "Very close! Look around. (RSSI: \$rssi)";
      _radarColor = Colors.lightGreen;
    } else if (rssi > -85) {
      _radarText = "Getting warmer... Keep going. (RSSI: \$rssi)";
      _radarColor = Colors.orange;
    } else {
      _radarText = "Far away. Head towards the venue. (RSSI: \$rssi)";
      _radarColor = Colors.red;
    }
  }

  Future<void> _stopScanning() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    
    setState(() {
      _isScanning = false;
      _closestBeacon = null;
      _radarText = "Radar Off";
      _radarColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Radar Navigation'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "How to use:\n1. Open app on a phone left in a classroom and tap 'Start Anchor'.\n2. Open app on a second phone and tap 'Start Scanner'.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            // ANCHOR CONTROLS
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("VENUE ANCHOR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _isBroadcasting ? "Broadcasting as Room 224 (Floor 1)" : "Idle",
                      style: TextStyle(color: _isBroadcasting ? Colors.green : Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _toggleBroadcasting,
                      icon: Icon(_isBroadcasting ? Icons.stop : Icons.sensors),
                      label: Text(_isBroadcasting ? "Stop Anchor" : "Start Anchor"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isBroadcasting ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            // SCANNER CONTROLS
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("NAVIGATOR RADAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _radarColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _radarColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.radar, size: 50, color: _radarColor),
                          const SizedBox(height: 10),
                          Text(
                            _radarText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: _radarColor.withValues(alpha: 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isBroadcasting ? null : _toggleScanning,
                      icon: Icon(_isScanning ? Icons.stop : Icons.track_changes),
                      label: Text(_isScanning ? "Stop Radar" : "Start Radar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
