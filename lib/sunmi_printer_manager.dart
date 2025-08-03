import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class SunmiPrinterManager {
  static const MethodChannel _channel = MethodChannel('sunmi_printer');
  static const EventChannel _eventChannel = EventChannel('sunmi_printer_events');
  
  // Singleton setup
  static final SunmiPrinterManager _instance = SunmiPrinterManager._internal();
  factory SunmiPrinterManager() {
    return _instance;
  }
  SunmiPrinterManager._internal();

  bool _isConnected = false;
  bool _isInitialized = false;
  StreamSubscription? _eventSubscription;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  /// Initialize the Sunmi printer
  Future<bool> initialize() async {
    try {
      final bool result = await _channel.invokeMethod('initialize');
      _isInitialized = result;
      
      if (result) {
        _listenToEvents();
      }
      
      return result;
    } on PlatformException catch (e) {
      print('Failed to initialize Sunmi printer: ${e.message}');
      return false;
    }
  }

  /// Connect to Sunmi printer
  Future<bool> connect() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      final bool result = await _channel.invokeMethod('connect');
      _isConnected = result;
      return result;
    } on PlatformException catch (e) {
      print('Failed to connect to Sunmi printer: ${e.message}');
      return false;
    }
  }

  /// Disconnect from Sunmi printer
  Future<bool> disconnect() async {
    try {
      final bool result = await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _eventSubscription?.cancel();
      return result;
    } on PlatformException catch (e) {
      print('Failed to disconnect from Sunmi printer: ${e.message}');
      return false;
    }
  }

  /// Print text
  Future<bool> printText(String text, {bool bold = false, bool center = false}) async {
    if (!_isConnected) return false;

    try {
      final Map<String, dynamic> params = {
        'text': text,
        'bold': bold,
        'center': center,
      };
      return await _channel.invokeMethod('printText', params);
    } on PlatformException catch (e) {
      print('Failed to print text: ${e.message}');
      return false;
    }
  }

  /// Print line
  Future<bool> printLine() async {
    if (!_isConnected) return false;

    try {
      return await _channel.invokeMethod('printLine');
    } on PlatformException catch (e) {
      print('Failed to print line: ${e.message}');
      return false;
    }
  }

  /// Print QR code
  Future<bool> printQRCode(String data, {int size = 200}) async {
    if (!_isConnected) return false;

    try {
      final Map<String, dynamic> params = {
        'data': data,
        'size': size,
      };
      return await _channel.invokeMethod('printQRCode', params);
    } on PlatformException catch (e) {
      print('Failed to print QR code: ${e.message}');
      return false;
    }
  }

  /// Print barcode
  Future<bool> printBarcode(String data, {int height = 100}) async {
    if (!_isConnected) return false;

    try {
      final Map<String, dynamic> params = {
        'data': data,
        'height': height,
      };
      return await _channel.invokeMethod('printBarcode', params);
    } on PlatformException catch (e) {
      print('Failed to print barcode: ${e.message}');
      return false;
    }
  }

  /// Print image
  Future<bool> printImage(Uint8List imageData, {int width = 384}) async {
    if (!_isConnected) return false;

    try {
      final Map<String, dynamic> params = {
        'imageData': imageData,
        'width': width,
      };
      return await _channel.invokeMethod('printImage', params);
    } on PlatformException catch (e) {
      print('Failed to print image: ${e.message}');
      return false;
    }
  }

  /// Feed paper
  Future<bool> feedPaper({int lines = 1}) async {
    if (!_isConnected) return false;

    try {
      final Map<String, dynamic> params = {
        'lines': lines,
      };
      return await _channel.invokeMethod('feedPaper', params);
    } on PlatformException catch (e) {
      print('Failed to feed paper: ${e.message}');
      return false;
    }
  }

  /// Cut paper
  Future<bool> cutPaper() async {
    if (!_isConnected) return false;

    try {
      return await _channel.invokeMethod('cutPaper');
    } on PlatformException catch (e) {
      print('Failed to cut paper: ${e.message}');
      return false;
    }
  }

  /// Get printer status
  Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getPrinterStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get printer status: ${e.message}');
      return {};
    }
  }

  /// Listen to printer events
  void _listenToEvents() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _handleEvent(event);
      },
      onError: (dynamic error) {
        print('Sunmi printer event error: $error');
      },
    );
  }

  /// Handle printer events
  void _handleEvent(dynamic event) {
    if (event is Map) {
      final String type = event['type'] ?? '';
      final dynamic data = event['data'];

      switch (type) {
        case 'connected':
          _isConnected = true;
          print('Sunmi printer connected');
          break;
        case 'disconnected':
          _isConnected = false;
          print('Sunmi printer disconnected');
          break;
        case 'error':
          print('Sunmi printer error: $data');
          break;
        case 'status':
          print('Sunmi printer status: $data');
          break;
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _eventSubscription?.cancel();
    disconnect();
  }
} 