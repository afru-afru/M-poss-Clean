// bluetooth_manager.dart

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothManager {
  // Singleton setup
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() {
    return _instance;
  }
  BluetoothManager._internal();

  bool isConnected = false;
  BluetoothInfo? selectedDevice;

  Future<bool> connect(BluetoothInfo device) async {
    selectedDevice = device;
    isConnected = await PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
    return isConnected;
  }
}