import 'dart:async';
import 'package:flutter/services.dart';

class SunmiPrinterService {
  static const MethodChannel _channel = MethodChannel('sunmi_printer');
  static const EventChannel _eventChannel = EventChannel('sunmi_printer_events');

  static final SunmiPrinterService _instance = SunmiPrinterService._internal();
  factory SunmiPrinterService() {
    return _instance;
  }
  SunmiPrinterService._internal();

  bool _isConnected = false;
  bool _isInitialized = false;
  StreamSubscription? _eventSubscription;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

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

  Future<bool> printLine() async {
    if (!_isConnected) return false;
    try {
      return await _channel.invokeMethod('printLine');
    } on PlatformException catch (e) {
      print('Failed to print line: ${e.message}');
      return false;
    }
  }
  
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

  Future<bool> cutPaper() async {
    if (!_isConnected) return false;
    try {
      return await _channel.invokeMethod('cutPaper');
    } on PlatformException catch (e) {
      print('Failed to cut paper: ${e.message}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getPrinterStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get printer status: ${e.message}');
      return {};
    }
  }


  String _buildRow(String left, String right, {int width = 32}) {
    final int padding = width - left.length - right.length;
    final String middle = (padding > 0) ? ' ' * padding : ' ';
    return left + middle + right;
  }

  ///  This method now correctly formats the receipt layout.
  Future<bool> printInvoice(Map<String, dynamic> invoiceData) async {
    if (!_isConnected) {
      print('Sunmi printer not connected');
      return false;
    }

    try {
      // Company information - ALL CENTERED
      await printText('TIN: ${invoiceData['company_tin'] ?? 'N/A'}', center: true);
      await printText(invoiceData['company_name'] ?? 'COMPANY NAME', bold: true, center: true);
      await printText('A.A,SUBCITY KIRKOS', center: true);
      await printText('W-09,H.NO-1146/BMS 05C', center: true);
      await printText('DEMBEL GROUND FLOOR', center: true);
      await printText('TEL: N/A', center: true);
      await printLine();

      // Invoice details - LEFT ALIGNED
      await printText('FS No. ${invoiceData['invoice_number'] ?? 'N/A'}');
      await printText('Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}');
      await printText('Customer: ${invoiceData['buyer_name'] ?? 'N/A'}');
      await printText('Operator: ${invoiceData['company_name'] ?? 'N/A'}');
      await printLine();

      // Items header - Uses the row builder for proper alignment
      await printText(_buildRow('Description', 'Price'), bold: true);
      await printLine();

      // Items - Correctly formatted
      final items = invoiceData['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        String description = (item['description'] ?? 'Item').toString();
        if (description.length > 20) {
          description = description.substring(0, 20); // Truncate long descriptions
        }
        final String qty = (item['quantity'] ?? 1).toString();
        final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
        final String totalAmount = '*${(item['total_line_amount'] as num? ?? 0).toStringAsFixed(2)}';

        await printText(_buildRow(description, '')); // Print description on its own line
        await printText(_buildRow('  $qty x $unitPrice', totalAmount)); // Print price details on the next
      }
      await printLine();

      // Totals - Correctly formatted
      final num subtotal = (invoiceData['total_value'] as num? ?? 0) - (invoiceData['tax_value'] as num? ?? 0);
      final num tax = invoiceData['tax_value'] as num? ?? 0;

      await printText(_buildRow('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
      await printText(_buildRow('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
      await printLine();
      await printText(
        _buildRow('TOTAL', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'),
        bold: true,
      );
      await printText(
        _buildRow('CASH', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'),
      );
      await printLine();
      await printText(_buildRow('ITEM #', items.length.toString()));
      await feedPaper();

      // Final section - ALL CENTERED
      await printText('ET FGB0016901', center: true);
      await feedPaper();

      // Using the static QR code as requested in the previous prompt
      await printQRCode("https://portal.mor.gov.et/", size: 200);
      await feedPaper();
      
      await printText('--- TEST INVOICE ---', center: true);
      await feedPaper(lines: 2);
      await cutPaper();

      return true;
    } catch (e) {
      print('Sunmi print error: $e');
      return false;
    }
  }
  
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

  void _handleEvent(dynamic event) {
    if (event is Map) {
      final String type = event['type'] ?? '';
      switch (type) {
        case 'connected':
          _isConnected = true;
          print('Sunmi printer connected');
          break;
        case 'disconnected':
          _isConnected = false;
          print('Sunmi printer disconnected');
          break;
        // ... other event handlers
      }
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    disconnect();
  }
}