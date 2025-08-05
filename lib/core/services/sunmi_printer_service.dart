import 'dart:async';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:sunmi_printerx/sunmi_printerx.dart';
import 'package:sunmi_printerx/align.dart';
import 'package:sunmi_printerx/printer.dart';

class SunmiPrinterService {
  static final SunmiPrinterService _instance = SunmiPrinterService._internal();
  factory SunmiPrinterService() {
    return _instance;
  }
  SunmiPrinterService._internal();

  final SunmiPrinterX _sunmiPrinter = SunmiPrinterX();
  bool _isConnected = false;
  bool _isInitialized = false;
  bool _isAvailable = false;
  List<Printer> _availablePrinters = [];
  Printer? _currentPrinter;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;

  /// Check if Sunmi printer is available on the device
  Future<bool> checkAvailability() async {
    try {
      print('Checking Sunmi printer availability...');
      
      // Get available printers
      _availablePrinters = await _sunmiPrinter.getPrinters();
      _isAvailable = _availablePrinters.isNotEmpty;
      
      print('Sunmi printer availability check result: $_isAvailable');
      print('Found ${_availablePrinters.length} printers: ${_availablePrinters.map((p) => p.name).join(', ')}');
      
      return _isAvailable;
    } catch (e) {
      print('Failed to check Sunmi printer availability: $e');
      _isAvailable = false;
      return false;
    }
  }

  /// Automatically connect to Sunmi printer if available
  Future<bool> autoConnect() async {
    try {
      print('Starting automatic Sunmi printer connection...');
      
      // First check if Sunmi printer is available
      final available = await checkAvailability();
      if (!available) {
        print('Sunmi printer not available on this device');
        return false;
      }

      print('Sunmi printer is available, initializing...');
      
      // Initialize if not already initialized
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          print('Failed to initialize Sunmi printer');
          return false;
        }
      }

      print('Sunmi printer initialized, connecting to first available printer...');
      
      // Connect to the first available printer
      if (_availablePrinters.isNotEmpty) {
        _currentPrinter = _availablePrinters.first;
        _isConnected = true; // The SDK doesn't have explicit connect, we just select the printer
        print('Automatically connected to Sunmi printer: ${_currentPrinter!.name}');
        return true;
      } else {
        print('No printers available to connect to');
        return false;
      }
    } catch (e) {
      print('Error in autoConnect: $e');
      return false;
    }
  }



  Future<bool> initialize() async {
    try {
      print('Initializing Sunmi printer service...');
      // The SDK doesn't have an explicit initialize method, so we just mark as initialized
      _isInitialized = true;
      print('Sunmi printer service initialized');
      return true;
    } catch (e) {
      print('Failed to initialize Sunmi printer: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      print('Disconnecting from Sunmi printer...');
      _isConnected = false;
      _currentPrinter = null;
      return true;
    } catch (e) {
      print('Failed to disconnect from Sunmi printer: $e');
      return false;
    }
  }

  Future<bool> printText(String text, {bool bold = false, bool center = false, int height =1}) async {
    if (!_isConnected || _currentPrinter == null) return false;
    try {
      print('Printing text: "$text" (bold: $bold, center: $center)');
      
      // Use the printer's printText method with proper parameters
      await _currentPrinter!.printText(
        text,
        bold: bold,
        align: center ? Align.center : Align.left,
        textHeightRatio: height
      );
      
      return true;
    } catch (e) {
      print('Failed to print text: $e');
      return false;
    }
  }

  Future<bool> printLine() async {
    if (!_isConnected || _currentPrinter == null) return false;
    try {
      print('Printing line separator');
      await _currentPrinter!.printText('--------------------------------');
      return true;
    } catch (e) {
      print('Failed to print line: $e');
      return false;
    }
  }
  
  // Future<bool> printQRCode(String data, {int size = 200}) async {
  //   if (!_isConnected || _currentPrinter == null) return false;
  //   try {
  //     print('Printing QR code: $data (size: $size)');
  //     // The SDK doesn't have direct QR code printing, so we'll use ESC/POS commands
  //     final commands = Uint8List.fromList([
  //       0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00, // QR Code: Select the model
  //       0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, size, // QR Code: Set the size of module
  //       0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30, // QR Code: Set error correction level
  //       0x1D, 0x28, 0x6B, 0x0B, 0x00, 0x31, 0x50, 0x30, ...data.codeUnits, // QR Code: Store the data in the symbol storage area
  //       0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30, // QR Code: Print the symbol data in the symbol storage area
  //     ]);
  //     await _currentPrinter!.printEscPosCommands(commands);
  //     return true;
  //   } catch (e) {
  //     print('Failed to print QR code: $e');
  //     return false;
  //   }
  // }

  Future<bool> feedPaper({int lines = 1}) async {
    if (!_isConnected || _currentPrinter == null) return false;
    try {
      print('Feeding paper: $lines lines');
      for (int i = 0; i < lines; i++) {
        await _currentPrinter!.printText('\n');
      }
      return true;
    } catch (e) {
      print('Failed to feed paper: $e');
      return false;
    }
  }

  Future<bool> cutPaper() async {
    if (!_isConnected || _currentPrinter == null) return false;
    try {
      print('Cutting paper');
      // Use ESC/POS command to cut paper
      final commands = Uint8List.fromList([0x1D, 0x56, 0x00]); // Cut paper command
      await _currentPrinter!.printEscPosCommands(commands);
      return true;
    } catch (e) {
      print('Failed to cut paper: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getPrinterStatus() async {
    try {
      print('Getting printer status...');
      if (_currentPrinter != null) {
        final status = await _currentPrinter!.getStatus();
        return {
          'status': status,
          'connected': _isConnected,
          'initialized': _isInitialized,
          'available': _isAvailable,
          'printerCount': _availablePrinters.length,
          'currentPrinter': _currentPrinter!.name,
        };
      } else {
        return {
          'status': -1,
          'connected': false,
          'initialized': false,
          'available': _isAvailable,
          'printerCount': _availablePrinters.length,
          'error': 'No printer selected',
        };
      }
    } catch (e) {
      print('Failed to get printer status: $e');
      return {
        'status': -1,
        'connected': false,
        'initialized': false,
        'error': e.toString(),
      };
    }
  }


  // String _buildRow(String left, String right, {int width = 32}) {
  //   final int padding = width - left.length - right.length;
  //   final String middle = (padding > 0) ? ' ' * padding : ' ';
  //   return left + middle + right;
  // }

 String _buildRowFormatted(List<String> columns, List<int> columnWidths, List<Align> alignments) {
    final List<String> formattedColumns = [];
    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];
      final width = columnWidths[i];
      final align = alignments[i];

      if (align == Align.right) {
        formattedColumns.add(column.padLeft(width));
      } else if (align == Align.center) {
        final padding = (width - column.length) ~/ 2;
        final leftPadding = ' ' * padding;
        final rightPadding = ' ' * (width - column.length - padding);
        formattedColumns.add(leftPadding + column + rightPadding);
      } else { // Align.left
        formattedColumns.add(column.padRight(width));
      }
    }
    return formattedColumns.join();
  }




    String center(String text, {int width = 32}) {
      if (text.length >= width) return text;
      int padding = (width - text.length) ~/ 2;
      return ' ' * padding + text;
    }

    String twoColumn(String left, String right, {int width = 32}) {
      int rightPadding = width - left.length - right.length;
      if (rightPadding < 0) rightPadding = 0;
      return left + ' ' * rightPadding + right;
    }

  ///  This method now correctly formats the receipt layout to match the previous Bluetooth layout.
  // Future<bool> printInvoice(Map<String, dynamic> invoiceData) async {
  //   if (!_isConnected || _currentPrinter == null) {
  //     print('Sunmi printer not connected');
  //     return false;
  //   }

  //   try {
  //     // --- 1. Header (Centered) ---
  //     await _currentPrinter!.printText('TIN: ${invoiceData['company_tin'] ?? 'N/A'}', align: Align.center);
  //     await _currentPrinter!.printText(invoiceData['company_name'] ?? 'COMPANY NAME', bold: true, align: Align.center);
  //     await _currentPrinter!.printText('A.A,SUBCITY KIRKOS', align: Align.center);
  //     await _currentPrinter!.printText('W-09,H.NO-1146/BMS 05C', align: Align.center);
  //     await _currentPrinter!.printText('DEMBEL GROUND FLOOR', align: Align.center);
  //     await _currentPrinter!.printText('TEL-${invoiceData['company_phone'] ?? 'N/A'}', align: Align.center);
  //     await _currentPrinter!.printText('\n');

  //     // --- 2. FS No. and Date/Time (Two Columns) ---
  //     final fsNoLine = _buildRowFormatted(
  //       ['FS No. ${invoiceData['invoice_number'] ?? 'N/A'}', '1 6'],
  //       [16, 16],
  //       [Align.left, Align.right],
  //     );
  //     await _currentPrinter!.printText(fsNoLine);

  //     // --- 3. Customer Info (Left Aligned) ---
  //     await _currentPrinter!.printText('Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}');
  //     await _currentPrinter!.printText('Customer: ${invoiceData['buyer_name'] ?? 'N/A'}');
  //     await _currentPrinter!.printText('Ref: ${invoiceData['reference'] ?? 'N/A'}');
  //     await _currentPrinter!.printText('Operator: ${invoiceData['operator_name'] ?? 'N/A'}');
  //     await _currentPrinter!.printText('\n');

  //     // --- 4. Items Header (Three Columns) ---
  //     final itemHeader = _buildRowFormatted(
  //       ['Description', 'Qty', 'Price'],
  //       [18, 5, 9],
  //       [Align.left, Align.center, Align.right],
  //     );
  //     await _currentPrinter!.printText(itemHeader);
  //     await _currentPrinter!.printText('--------------------------------');

  //     // --- 5. Item Lines ---
  //     final items = invoiceData['items'] as List<dynamic>? ?? [];
  //     for (var item in items) {
  //       final String description = item['description'] ?? 'Item';
  //       final String qty = (item['quantity'] ?? 1).toString();
  //       final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
  //       final String lineTotal = (item['total_line_amount'] as num? ?? 0).toStringAsFixed(2);

  //       await _currentPrinter!.printText(description);
  //       final itemLine = _buildRowFormatted(
  //         ['', '$qty x *$unitPrice', '*$lineTotal'],
  //         [9, 13, 10],
  //         [Align.left, Align.right, Align.right],
  //       );
  //       await _currentPrinter!.printText(itemLine);
  //     }
  //     await _currentPrinter!.printText('--------------------------------');

  //     // --- 6. Totals ---
  //     final num subtotal = (invoiceData['total_value'] as num? ?? 0) - (invoiceData['tax_value'] as num? ?? 0);
  //     final num tax = invoiceData['tax_value'] as num? ?? 0;

  //     await _currentPrinter!.printText(_buildRow('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
  //     await _currentPrinter!.printText(_buildRow('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
  //     await _currentPrinter!.printText('\n');

  //     // --- 7. Grand Total ---
  //     await _currentPrinter!.printText(
  //       _buildRow('TOTAL', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'),
  //       bold: true,
  //     );

  //     // --- 8. Payment Details ---
  //     await _currentPrinter!.printText(_buildRow('CASH', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));
  //     await _currentPrinter!.printText(_buildRow('ITEM #', items.length.toString()));
  //     await _currentPrinter!.printText('\n');

  //     // --- 9. Footer ---
  //     await _currentPrinter!.printText('ET FGB0016901', align: Align.center);
  //     await _currentPrinter!.printText('\n');

  //     // --- Finalize and Cut Paper ---
  //     for (int i = 0; i < 3; i++) {
  //         await _currentPrinter!.printText('\n');
  //     }
  //     final cutCommand = Uint8List.fromList([0x1D, 0x56, 0x00]);
  //     await _currentPrinter!.printEscPosCommands(cutCommand);

  //     return true;
  //   } catch (e) {
  //     print('Sunmi print error: $e');
  //     return false;
  //   }
  // }


  String _center(String text, {int width = 32}) {
    if (text.length >= width) return text;
    int padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  String _twoColumn(String left, String right, {int width = 32}) {
    int rightPadding = width - left.length - right.length;
    if (rightPadding < 0) rightPadding = 0;
    return left + ' ' * rightPadding + right;
  }
  
  // This helper from the previous solution is also kept as it's very useful.
  String _buildRow(String left, String right, {int width = 32}) {
    final int padding = width - left.length - right.length;
    final String middle = (padding > 0) ? ' ' * padding : ' ';
    return left + middle + right;
  }


  Future<bool> printInvoice(Map<String, dynamic> invoiceData) async { // FIX #2: Added 'async'
    if (!_isConnected || _currentPrinter == null) {
      print('Sunmi printer not connected');
      return false;
    }

    try {
      final items = invoiceData['items'] as List<dynamic>? ?? [];

      // --- Header ---
      // We use the built-in align parameter for centering, which is more reliable.
      await _currentPrinter!.printText(_center('TIN: ${invoiceData['company_tin'] ?? 'N/A'}'));
         
      await _currentPrinter!.printText(_center(invoiceData['company_name'] ?? 'COMPANY NAME' ));
      await _currentPrinter!.printText(_center('A.A,SUBCITY KIRKOS'), bold: true);
      await _currentPrinter!.printText(_center('W-09,H.NO-1146/BMS 05C'));
      await _currentPrinter!.printText(_center('DEMBEL GROUND FLOOR'));
      await _currentPrinter!.printText(_center('TEL: ${invoiceData['company_phone'] ?? 'N/A'}'));
      await _currentPrinter!.printText('--------------------------------');
      await _currentPrinter!.printText('\n');

      // --- Invoice details ---
      // This section from your target receipt had specific alignment, so we use _buildRow.
      final DateTime invoiceDate = invoiceData['invoice_date'] != null
          ? DateTime.parse(invoiceData['invoice_date'])
          : DateTime.now();
      final String formattedDate = DateFormat('dd/MM/yyyy').format(invoiceDate);
      final String formattedTime = DateFormat('HH:mm').format(invoiceDate);

      await _currentPrinter!.printText(_buildRow('FS No. ${invoiceData['invoice_number'] ?? 'N/A'}', '$formattedDate $formattedTime'));
      await _currentPrinter!.printText('Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}');
      await _currentPrinter!.printText('Customer: ${invoiceData['buyer_name'] ?? 'N/A'}');
      await _currentPrinter!.printText('Operator: ${invoiceData['operator_name'] ?? 'N/A'}');
      await _currentPrinter!.printText('--------------------------------');

      // --- Items header ---
      await _currentPrinter!.printText(_buildRow('Description', 'Qty   Price'));
      await _currentPrinter!.printText('--------------------------------');

      // --- Items ---
      for (var item in items) {
        String description = (item['description'] ?? 'Item').toString();
        if (description.length > 20) {
          description = description.substring(0, 20);
        }
        final String qty = (item['quantity'] ?? 1).toString();
        final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
        final String totalAmount = '*${(item['total_line_amount'] as num? ?? 0).toStringAsFixed(2)}';

        await _currentPrinter!.printText(_buildRow('$description', '$qty x $unitPrice', width: 32));
        await _currentPrinter!.printText(_twoColumn('  ', totalAmount));
      }
      await _currentPrinter!.printText('--------------------------------');

      // --- Totals ---
      final num subtotal = (invoiceData['total_value'] as num? ?? 0) - (invoiceData['tax_value'] as num? ?? 0);
      final num tax = invoiceData['tax_value'] as num? ?? 0;
       await _currentPrinter!.printText('\n');

      await _currentPrinter!.printText(_twoColumn('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
      await _currentPrinter!.printText(_twoColumn('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
      await _currentPrinter!.printText('--------------------------------');
      await _currentPrinter!.printText(_twoColumn('TOTAL', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'), bold: true, );
      await _currentPrinter!.printText(_twoColumn('CASH', '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));



      await _currentPrinter!.printText('--------------------------------');
      await _currentPrinter!.printText(_twoColumn('ITEM #', items.length.toString()));
      await _currentPrinter!.printText('\n');
       await _currentPrinter!.printText(_center('ET FGB0016901'));
            await _currentPrinter!.printQrCode('https://portal.mor.gov.et/');


      // --- Final section ---
       await _currentPrinter!.printText('\n');
     
      await _currentPrinter!.printText(_center('--- TEST INVOICE ---'));
      
      // FIX #3: Added feed and cut commands
      await _currentPrinter!.printText('\n\n\n'); // Feed paper
      final cutCommand = Uint8List.fromList([0x1D, 0x56, 0x00]);
      await _currentPrinter!.printEscPosCommands(cutCommand);

      // FIX #4: Return a boolean value, not a string.
      return true;
    } catch (e) {
      print('Sunmi print error: $e');
      return false;
    }
  }

  // FIX #5: The dispose method is now correctly placed inside the class.
  void dispose() {
    disconnect();
  }
}