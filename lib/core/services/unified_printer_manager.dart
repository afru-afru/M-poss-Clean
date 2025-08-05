import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'bluetooth_manager.dart';
import 'sunmi_printer_manager.dart';

enum PrinterType {
  bluetooth,
  sunmi,
}

class UnifiedPrinterManager {
  static final UnifiedPrinterManager _instance = UnifiedPrinterManager._internal();
  factory UnifiedPrinterManager() {
    return _instance;
  }
  UnifiedPrinterManager._internal();

  final BluetoothManager _bluetoothManager = BluetoothManager();
  final SunmiPrinterManager _sunmiManager = SunmiPrinterManager();
  
  PrinterType _currentPrinterType = PrinterType.bluetooth;
  bool _isConnected = false;

  PrinterType get currentPrinterType => _currentPrinterType;
  bool get isConnected => _isConnected;

  /// Set the current printer type
  void setPrinterType(PrinterType type) {
    _currentPrinterType = type;
    _isConnected = false; // Reset connection when switching printer types
  }

  /// Connect to the selected printer type
  Future<bool> connect({BluetoothInfo? bluetoothDevice}) async {
    switch (_currentPrinterType) {
      case PrinterType.bluetooth:
        if (bluetoothDevice != null) {
          _isConnected = await _bluetoothManager.connect(bluetoothDevice);
        } else {
          _isConnected = _bluetoothManager.isConnected;
        }
        break;
      case PrinterType.sunmi:
        _isConnected = await _sunmiManager.connect();
        break;
    }
    return _isConnected;
  }

  /// Disconnect from the current printer
  Future<bool> disconnect() async {
    switch (_currentPrinterType) {
      case PrinterType.bluetooth:
        // Bluetooth manager doesn't have a disconnect method, just reset state
        _bluetoothManager.isConnected = false;
        _bluetoothManager.selectedDevice = null;
        _isConnected = false;
        return true;
      case PrinterType.sunmi:
        _isConnected = await _sunmiManager.disconnect();
        return !_isConnected;
    }
  }

  /// Print invoice using the current printer type
  Future<bool> printInvoice(Map<String, dynamic> invoiceData) async {
    if (!_isConnected) return false;

    switch (_currentPrinterType) {
      case PrinterType.bluetooth:
        return await _printInvoiceBluetooth(invoiceData);
      case PrinterType.sunmi:
        return await _printInvoiceSunmi(invoiceData);
    }
  }

  /// Print invoice using Bluetooth printer
  Future<bool> _printInvoiceBluetooth(Map<String, dynamic> invoiceData) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Extract data from the API response structure
      final items = invoiceData['items'] as List<dynamic>? ?? [];
      final date = invoiceData['invoice_date'] != null
          ? DateTime.parse(invoiceData['invoice_date'])
          : DateTime.now();

      // Company information
      bytes += generator.text(
        'TIN: ${invoiceData['company_tin'] ?? 'N/A'}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        invoiceData['company_name'] ?? 'COMPANY NAME',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'A.A,SUBCITY KIRKOS',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'W-09,H.NO-1146/BMS 05C',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'DEMBEL GROUND FLOOR',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'TEL: N/A',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr(ch: '-');

      // Invoice details
      bytes += generator.text(
        'FS No. ${invoiceData['invoice_number'] ?? 'N/A'}',
      );
      bytes += generator.text(
        'Date: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      );
      bytes += generator.text(
        'Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}',
      );
      bytes += generator.text(
        'Customer: ${invoiceData['buyer_name'] ?? 'N/A'}',
      );
      bytes += generator.text(
        'Operator: ${invoiceData['company_name'] ?? 'N/A'}',
      );
      bytes += generator.hr(ch: '-');

      // Items header
      bytes += generator.text('Description          Qty   Price');
      bytes += generator.hr(ch: '-');

      // Items
      for (var item in items) {
        final String description = (item['description'] ?? 'Item').toString();
        final String qty = (item['quantity'] ?? 1).toString();
        final String unitPrice = (item['unit_price'] as num? ?? 0)
            .toStringAsFixed(2);
        final String totalAmount = (item['total_line_amount'] as num? ?? 0)
            .toStringAsFixed(2);

        bytes += generator.row([
          PosColumn(
            text: description.length > 18
                ? description.substring(0, 18)
                : description,
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '$qty x *$unitPrice',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        bytes += generator.text(
          '*$totalAmount',
          styles: const PosStyles(align: PosAlign.right),
        );
      }

      bytes += generator.hr(ch: '-');

      // Totals
      final num subtotal =
          (invoiceData['total_value'] as num? ?? 0) -
          (invoiceData['tax_value'] as num? ?? 0);
      final num tax = invoiceData['tax_value'] as num? ?? 0;

      bytes += generator.row([
        PosColumn(text: 'TXBL1', width: 6),
        PosColumn(
          text: '*${subtotal.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'TAX1 15.00%', width: 6),
        PosColumn(
          text: '*${tax.toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.hr(ch: '-');

      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 4,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text:
              '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}',
          width: 8,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
            align: PosAlign.right,
          ),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'CASH', width: 6),
        PosColumn(
          text:
              '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.hr(ch: '-');

      bytes += generator.row([
        PosColumn(text: 'ITEM #', width: 6),
        PosColumn(
          text: items.length.toString(),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.feed(1);
      bytes += generator.text(
        'ET FGB0016901',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(1);
      
      // Add QR code above TEST INVOICE
      final String qrData = 'INV:${invoiceData['invoice_number'] ?? 'N/A'}';
      bytes += generator.qrcode(qrData);
      bytes += generator.feed(1);
      
      bytes += generator.text(
        '--- TEST INVOICE ---',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Print
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      print('Bluetooth print error: $e');
      return false;
    }
  }

  /// Print invoice using Sunmi printer
  Future<bool> _printInvoiceSunmi(Map<String, dynamic> invoiceData) async {
    try {
      final items = invoiceData['items'] as List<dynamic>? ?? [];
      final date = invoiceData['invoice_date'] != null
          ? DateTime.parse(invoiceData['invoice_date'])
          : DateTime.now();

      // Company information
      await _sunmiManager.printText('TIN: ${invoiceData['company_tin'] ?? 'N/A'}', center: true);
      await _sunmiManager.printText(invoiceData['company_name'] ?? 'COMPANY NAME', bold: true, center: true);
      await _sunmiManager.printText('A.A,SUBCITY KIRKOS', center: true);
      await _sunmiManager.printText('W-09,H.NO-1146/BMS 05C', center: true);
      await _sunmiManager.printText('DEMBEL GROUND FLOOR', center: true);
      await _sunmiManager.printText('TEL: N/A', center: true);
      await _sunmiManager.printLine();

      // Invoice details
      await _sunmiManager.printText('FS No. ${invoiceData['invoice_number'] ?? 'N/A'}');
      await _sunmiManager.printText('Date: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}');
      await _sunmiManager.printText('Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}');
      await _sunmiManager.printText('Customer: ${invoiceData['buyer_name'] ?? 'N/A'}');
      await _sunmiManager.printText('Operator: ${invoiceData['company_name'] ?? 'N/A'}');
      await _sunmiManager.printLine();

      // Items header
      await _sunmiManager.printText('Description          Qty   Price');
      await _sunmiManager.printLine();

      // Items
      for (var item in items) {
        final String description = (item['description'] ?? 'Item').toString();
        final String qty = (item['quantity'] ?? 1).toString();
        final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
        final String totalAmount = (item['total_line_amount'] as num? ?? 0).toStringAsFixed(2);

        await _sunmiManager.printText('${description.length > 18 ? description.substring(0, 18) : description}');
        await _sunmiManager.printText('$qty x *$unitPrice');
        await _sunmiManager.printText('*$totalAmount');
      }

      await _sunmiManager.printLine();

      // Totals
      final num subtotal = (invoiceData['total_value'] as num? ?? 0) - (invoiceData['tax_value'] as num? ?? 0);
      final num tax = invoiceData['tax_value'] as num? ?? 0;

      await _sunmiManager.printText('TXBL1: *${subtotal.toStringAsFixed(2)}');
      await _sunmiManager.printText('TAX1 15.00%: *${tax.toStringAsFixed(2)}');
      await _sunmiManager.printLine();

      await _sunmiManager.printText('TOTAL: *${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}', bold: true);
      await _sunmiManager.printText('CASH: *${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}');
      await _sunmiManager.printLine();

      await _sunmiManager.printText('ITEM #: ${items.length}');
      await _sunmiManager.feedPaper(lines: 1);
      await _sunmiManager.printText('ET FGB0016901', center: true);
      await _sunmiManager.feedPaper(lines: 1);
      
      // Add QR code above TEST INVOICE
      final String qrData = 'INV:${invoiceData['invoice_number'] ?? 'N/A'}';
      await _sunmiManager.printQRCode(qrData, size: 200);
      await _sunmiManager.feedPaper(lines: 1);
      
      await _sunmiManager.printText('--- TEST INVOICE ---', center: true);
      await _sunmiManager.feedPaper(lines: 2);
      await _sunmiManager.cutPaper();

      return true;
    } catch (e) {
      print('Sunmi print error: $e');
      return false;
    }
  }

  /// Get available Bluetooth devices
  Future<List<BluetoothInfo>> getBluetoothDevices() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      print('Error getting Bluetooth devices: $e');
      return [];
    }
  }

  /// Get printer status
  Future<Map<String, dynamic>> getPrinterStatus() async {
    switch (_currentPrinterType) {
      case PrinterType.bluetooth:
        return {
          'type': 'bluetooth',
          'connected': _bluetoothManager.isConnected,
          'device': _bluetoothManager.selectedDevice?.name ?? 'None',
        };
      case PrinterType.sunmi:
        final status = await _sunmiManager.getPrinterStatus();
        status['type'] = 'sunmi';
        return status;
    }
  }

  /// Get selected Bluetooth device
  BluetoothInfo? getSelectedBluetoothDevice() {
    return _bluetoothManager.selectedDevice;
  }

  /// Dispose resources
  void dispose() {
    _sunmiManager.dispose();
  }
} 