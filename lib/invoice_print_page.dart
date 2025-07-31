// invoice_print_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'bluetooth_manager.dart'; // <-- Import the manager

class InvoicePrintPage extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const InvoicePrintPage({super.key, required this.invoiceData});

  @override
  State<InvoicePrintPage> createState() => _InvoicePrintPageState();
}

class _InvoicePrintPageState extends State<InvoicePrintPage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    setState(() => _isLoading = true);
    
    try {
      var bluetoothScanStatus = await Permission.bluetoothScan.request();
      var bluetoothConnectStatus = await Permission.bluetoothConnect.request();

      if (bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted) {
        _devices = await PrintBluetoothThermal.pairedBluetooths;
      } else {
        debugPrint("Bluetooth permissions not granted");
      }
    } catch (e) {
      debugPrint("Error getting Bluetooth devices: $e");
    }

    // MODIFIED: This is the corrected logic to prevent the dropdown error.
    // It finds the matching device in the new list.
    if (bluetoothManager.selectedDevice != null) {
      try {
        final savedDeviceMac = bluetoothManager.selectedDevice!.macAdress;
        _selectedDevice = _devices.firstWhere((d) => d.macAdress == savedDeviceMac);
      } catch (e) {
        // Handle case where the saved device is no longer in the list
        _selectedDevice = null;
        bluetoothManager.selectedDevice = null;
        bluetoothManager.isConnected = false;
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectToDevice() async {
    if (_selectedDevice != null) {
      setState(() => _isLoading = true);
      
      await bluetoothManager.connect(_selectedDevice!);
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bluetoothManager.isConnected ? 'Connected successfully!' : 'Connection failed!')),
        );
      }
    }
  }

  Future<void> _printReceipt() async {
    if (!bluetoothManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please connect to a printer first.')));
      return;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final seller = widget.invoiceData['seller'] as Map<String, dynamic>? ?? {};
    final items = widget.invoiceData['items'] as List<dynamic>? ?? [];
    final date = widget.invoiceData['invoice_date'] != null
        ? DateTime.parse(widget.invoiceData['invoice_date'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);
    
    bytes += generator.text('TIN: ${seller['tin'] ?? 'N/A'}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(seller['legal_name'] ?? 'SELLER NAME', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(seller['address_line_1'] ?? 'A.A,SUBCITY KIRKOS', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(seller['address_line_2'] ?? 'W-09,H.NO-1146/BMS 05C', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(seller['address_line_3'] ?? 'DEMBEL GROUND FLOOR', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TEL: ${seller['phone'] ?? 'N/A'}', styles: const PosStyles(align: PosAlign.center));
    
    bytes += generator.hr(ch: '-');
    bytes += generator.text('FS No. ${widget.invoiceData['document_number'] ?? 'N/A'}');
    bytes += generator.row([
      PosColumn(text: formattedDate, width: 6),
      PosColumn(text: formattedTime, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.text('Buyer\'s TIN: ${widget.invoiceData['buyer_tin'] ?? 'N/A'}');
    bytes += generator.text('Customer: ${widget.invoiceData['buyer_name'] ?? 'N/A'}');
    bytes += generator.text('Ref: ${widget.invoiceData['ref_number'] ?? 'N/A'}');
    bytes += generator.text('Operator: ${seller['legal_name'] ?? 'N/A'}');
    
    bytes += generator.hr(ch: '-');
    bytes += generator.text('Description          Qty   Price');
    bytes += generator.hr(ch: '-');

    for (var item in items) {
      final String description = item['description'] ?? 'Item';
      final String qty = (item['quantity'] ?? 1).toString();
      final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
      final String totalAmount = (item['total_line_amount'] as num? ?? 0).toStringAsFixed(2);
      
      bytes += generator.row([
        PosColumn(text: description, width: 6, styles: const PosStyles(align: PosAlign.left)),
        PosColumn(text: '$qty x *$unitPrice', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('*$totalAmount', styles: const PosStyles(align: PosAlign.right));
    }
    
    bytes += generator.hr(ch: '-');
    final double subtotal = (widget.invoiceData['total_value'] ?? 0) - (widget.invoiceData['tax_value'] ?? 0);
    final double tax = widget.invoiceData['tax_value'] ?? 0;
    
    bytes += generator.row([
      PosColumn(text: 'TXBL1', width: 6),
      PosColumn(text: '*${subtotal.toStringAsFixed(2)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'TAX1 15.00%', width: 6),
      PosColumn(text: '*${tax.toStringAsFixed(2)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 4, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(text: '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}', width: 8, styles: const PosStyles(bold: true, height: PosTextSize.size2, align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CASH', width: 6),
      PosColumn(text: '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    
    bytes += generator.hr(ch: '-');
    bytes += generator.row([
      PosColumn(text: 'ITEM #', width: 6),
      PosColumn(text: items.length.toString(), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    
    bytes += generator.feed(1);
    bytes += generator.text(widget.invoiceData['some_footer_code'] ?? 'ET FGB0016901', styles: const PosStyles(align: PosAlign.center));
   
   bytes += generator.feed(1);
    bytes += generator.text('--- TEST INVOICE ---', styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(2);
    bytes += generator.cut();


    final result = await PrintBluetoothThermal.writeBytes(bytes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ? 'Printed successfully!' : 'Failed to send print command.')),
      );
    }
  }

  String _generateReceiptText() {
    final seller = widget.invoiceData['seller'] as Map<String, dynamic>? ?? {};
    final items = widget.invoiceData['items'] as List<dynamic>? ?? [];
    final date = widget.invoiceData['invoice_date'] != null ? DateTime.parse(widget.invoiceData['invoice_date']) : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);
    
    StringBuffer receipt = StringBuffer();
    final String dashLine = '-' * 32;

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

    receipt.writeln(center('TIN: ${seller['tin'] ?? 'N/A'}'));
    receipt.writeln(center(seller['legal_name'] ?? 'SELLER NAME'));
    receipt.writeln(center(seller['address_line_1'] ?? 'A.A,SUBCITY KIRKOS'));
    receipt.writeln(center(seller['address_line_2'] ?? 'W-09,H.NO-1146/BMS 05C'));
    receipt.writeln(center(seller['address_line_3'] ?? 'DEMBEL GROUND FLOOR'));
    receipt.writeln(center('TEL: ${seller['phone'] ?? 'N/A'}'));
    receipt.writeln(dashLine);

    receipt.writeln('FS No. ${widget.invoiceData['document_number'] ?? 'N/A'}');
    receipt.writeln(twoColumn(formattedDate, formattedTime));
    receipt.writeln('Buyer\'s TIN: ${widget.invoiceData['buyer_tin'] ?? 'N/A'}');
    receipt.writeln('Customer: ${widget.invoiceData['buyer_name'] ?? 'N/A'}');
    receipt.writeln('Ref: ${widget.invoiceData['ref_number'] ?? 'N/A'}');
    receipt.writeln('Operator: ${seller['legal_name'] ?? 'N/A'}');
    
    receipt.writeln(dashLine);
    receipt.writeln('Description          Qty   Price');
    receipt.writeln(dashLine);

    for (var item in items) {
      final String description = item['description'] ?? 'Item';
      final String qty = (item['quantity'] ?? 1).toString();
      final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
      final String totalAmount = (item['total_line_amount'] as num? ?? 0).toStringAsFixed(2);
      
      receipt.writeln(twoColumn(description, '$qty x *$unitPrice'));
      receipt.writeln(('*$totalAmount').padLeft(32));
    }
    
    receipt.writeln(dashLine);
    
    final double subtotal = (widget.invoiceData['total_value'] ?? 0) - (widget.invoiceData['tax_value'] ?? 0);
    final double tax = widget.invoiceData['tax_value'] ?? 0;
    
    receipt.writeln(twoColumn('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
    receipt.writeln(twoColumn('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
    receipt.writeln(dashLine);
    receipt.writeln(twoColumn('TOTAL', '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));
    receipt.writeln(twoColumn('CASH', '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));
    receipt.writeln(dashLine);
    receipt.writeln(twoColumn('ITEM #', items.length.toString()));
    receipt.writeln();
    receipt.writeln(center(widget.invoiceData['some_footer_code'] ?? 'ET FGB0016901'));

    return receipt.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = bluetoothManager.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Invoice'),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: isConnected ? Colors.blue : Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _isLoading || !isConnected ? null : _printReceipt,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select a Bluetooth Printer:', style: TextStyle(fontWeight: FontWeight.bold)),
            _isLoading
                ? const CircularProgressIndicator()
                : DropdownButton<BluetoothInfo>(
                    hint: const Text('Select printer'),
                    value: _selectedDevice,
                    items: _devices.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text(device.name ?? 'Unknown Device'),
                      );
                    }).toList(),
                    onChanged: (device) {
                      setState(() {
                        _selectedDevice = device;
                      });
                    },
                  ),
            ElevatedButton(
              onPressed: _selectedDevice == null ? null : _connectToDevice,
              child: Text(isConnected ? 'Connected' : 'Connect'),
            ),
            const Divider(),
            const Text('Receipt Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Text(
                _generateReceiptText(),
                style: const TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}