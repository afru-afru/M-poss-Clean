import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'dart:convert';
import 'bluetooth_manager.dart';
import 'sunmi_printer_service.dart';
import 'print_receipt.dart';

class InvoicePrintPage extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const InvoicePrintPage({super.key, required this.invoiceData});

  @override
  State<InvoicePrintPage> createState() => _InvoicePrintPageState();
}

class _InvoicePrintPageState extends State<InvoicePrintPage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  final SunmiPrinterService _sunmiService = SunmiPrinterService();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isPrinting = false;
  bool _useSunmiPrinter = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  @override
  void dispose() {
    _sunmiService.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Check if permissions are granted
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    final bluetoothStatus = await Permission.bluetooth.status;
    final locationStatus = await Permission.location.status;

    if (bluetoothScanStatus.isDenied ||
        bluetoothConnectStatus.isDenied ||
        bluetoothStatus.isDenied ||
        locationStatus.isDenied) {
      // Show permission request dialog
      if (mounted) {
        _showInitialPermissionDialog();
      }
    } else {
      // Permissions are granted, initialize Bluetooth
      _initBluetooth();
    }
  }

  void _showInitialPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs Bluetooth and Location permissions to connect to thermal printers. '
            'These permissions are required for the printing functionality to work properly.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initBluetooth(); // Try anyway
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestPermissions();
              },
              child: const Text('Grant Permissions'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetooth.request();
      await Permission.location.request();
      await Permission.locationWhenInUse.request();

      // Initialize Bluetooth after requesting permissions
      _initBluetooth();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      _initBluetooth(); // Try anyway
    }
  }

  Future<void> _initBluetooth() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // First check if permissions are already granted
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      final bluetoothStatus = await Permission.bluetooth.status;
      final locationStatus = await Permission.location.status;

      // If any permission is denied, request them
      if (bluetoothScanStatus.isDenied ||
          bluetoothConnectStatus.isDenied ||
          bluetoothStatus.isDenied ||
          locationStatus.isDenied) {
        // Request permissions one by one
        await Permission.bluetoothScan.request();
        await Permission.bluetoothConnect.request();
        await Permission.bluetooth.request();
        await Permission.location.request();
        await Permission.locationWhenInUse.request();
      }

      // Check final status
      final finalBluetoothScanStatus = await Permission.bluetoothScan.status;
      final finalBluetoothConnectStatus =
          await Permission.bluetoothConnect.status;
      final finalBluetoothStatus = await Permission.bluetooth.status;
      final finalLocationStatus = await Permission.location.status;

      bool allGranted =
          finalBluetoothScanStatus.isGranted &&
          finalBluetoothConnectStatus.isGranted &&
          finalBluetoothStatus.isGranted &&
          finalLocationStatus.isGranted;

      if (allGranted) {
        // Get paired devices
        final devices = await PrintBluetoothThermal.pairedBluetooths;
        if (mounted) {
          setState(() {
            _devices = devices;
          });
        }
      } else {
        if (mounted) {
          _showSnackBar(
            "Bluetooth permissions not granted. Please grant all permissions in settings.",
            isError: true,
          );
          // Show dialog to open settings
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint("Error getting Bluetooth devices: $e");
      if (mounted) {
        _showSnackBar("Error getting Bluetooth devices: $e", isError: true);
      }
    }

    // Restore previously selected device
    if (bluetoothManager.selectedDevice != null && _devices.isNotEmpty) {
      try {
        final savedDeviceMac = bluetoothManager.selectedDevice!.macAdress;
        _selectedDevice = _devices.firstWhere(
          (d) => d.macAdress == savedDeviceMac,
        );
      } catch (e) {
        // Device not found in current list
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
    if (_isConnecting) return;

    setState(() => _isConnecting = true);

    try {
      bool connected = false;
      
      if (_useSunmiPrinter) {
        connected = await _sunmiService.connect();
      } else {
        if (_selectedDevice == null) {
          _showSnackBar('Please select a Bluetooth device first.', isError: true);
          return;
        }
        connected = await bluetoothManager.connect(_selectedDevice!);
      }

      if (mounted) {
        _showSnackBar(
          connected ? 'Connected successfully!' : 'Connection failed!',
          isError: !connected,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

 Future<void> _printReceipt() async {
    bool isConnected = _useSunmiPrinter ? _sunmiService.isConnected : bluetoothManager.isConnected;
    
    if (!isConnected || _isPrinting) {
      _showSnackBar('Please connect to a printer first.');
      return;
    }

    setState(() => _isPrinting = true);

    try {
      bool result = false;
      
      if (_useSunmiPrinter) {
        // Sunmi logic remains unchanged
        result = await _sunmiService.printInvoice(widget.invoiceData);
      } else {
        // **** SIMPLIFIED BLUETOOTH LOGIC ****
        // Generate the receipt bytes using the new class
        final List<int> bytes = await ReceiptGenerator.generateBluetoothReceiptBytes(widget.invoiceData);
        // Write bytes to the printer
        result = await PrintBluetoothThermal.writeBytes(bytes);
      }

      if (mounted) {
        _showSnackBar(
          result ? 'Receipt printed successfully!' : 'Failed to print receipt.',
          isError: !result,
        );
      }
    } catch (e) {
      debugPrint('Print error: $e');
      if (mounted) {
        _showSnackBar('Print error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }





  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _generateReceiptText() {
    final StringBuffer receipt = StringBuffer();
    const String dashLine = '--------------------------------';
    final items = widget.invoiceData['items'] as List<dynamic>? ?? [];
    final date = widget.invoiceData['invoice_date'] != null
        ? DateTime.parse(widget.invoiceData['invoice_date'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

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

    receipt.writeln(
      center('TIN: ${widget.invoiceData['company_tin'] ?? 'N/A'}'),
    );
    receipt.writeln(
      center(widget.invoiceData['company_name'] ?? 'COMPANY NAME'),
    );
    receipt.writeln(center('A.A,SUBCITY KIRKOS'));
    receipt.writeln(center('W-09,H.NO-1146/BMS 05C'));
    receipt.writeln(center('DEMBEL GROUND FLOOR'));
    receipt.writeln(center('TEL: N/A'));
    receipt.writeln(dashLine);
    receipt.writeln('FS No. ${widget.invoiceData['invoice_number'] ?? 'N/A'}');
    receipt.writeln(twoColumn(formattedDate, formattedTime));
    receipt.writeln(
      'Buyer\'s TIN: ${widget.invoiceData['buyer_tin'] ?? 'N/A'}',
    );
    receipt.writeln('Customer: ${widget.invoiceData['buyer_name'] ?? 'N/A'}');
    receipt.writeln('Operator: ${widget.invoiceData['company_name'] ?? 'N/A'}');
    receipt.writeln(dashLine);
    receipt.writeln('Description          Qty   Price');
    receipt.writeln(dashLine);

    for (var item in items) {
      final String description = (item['description'] ?? 'Item').toString();
      final String qty = (item['quantity'] ?? 1).toString();
      final String unitPrice = (item['unit_price'] as num? ?? 0)
          .toStringAsFixed(2);
      final String totalAmount = (item['total_line_amount'] as num? ?? 0)
          .toStringAsFixed(2);

      receipt.writeln(twoColumn(description, '$qty x *$unitPrice'));
      receipt.writeln(('*$totalAmount').padLeft(32));
    }

    receipt.writeln(dashLine);

    final double subtotal =
        (widget.invoiceData['total_value'] ?? 0) -
        (widget.invoiceData['tax_value'] ?? 0);
    final double tax = widget.invoiceData['tax_value'] ?? 0;

    receipt.writeln(twoColumn('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
    receipt.writeln(twoColumn('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
    receipt.writeln(dashLine);
    receipt.writeln(
      twoColumn(
        'TOTAL',
        '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}',
      ),
    );
    receipt.writeln(
      twoColumn(
        'CASH',
        '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}',
      ),
    );
    receipt.writeln(dashLine);
    receipt.writeln(twoColumn('ITEM #', items.length.toString()));
    receipt.writeln();
    receipt.writeln(center('ET FGB0016901'));

    receipt.writeln();
    receipt.writeln(center('--- TEST INVOICE ---'));

    return receipt.toString();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app needs Bluetooth and Location permissions to connect to printers. '
            'Please grant these permissions in the app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = _useSunmiPrinter ? _sunmiService.isConnected : bluetoothManager.isConnected;
    final items = widget.invoiceData['items'] as List<dynamic>? ?? [];
    final date = widget.invoiceData['invoice_date'] != null
        ? DateTime.parse(widget.invoiceData['invoice_date'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3C8B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Print Invoice',
          style: TextStyle(
            color: Color(0xFF1A3C8B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected
                        ? Colors.green.shade800
                        : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF1A3C8B)),
            onPressed: _isLoading || !isConnected ? null : _printReceipt,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F6F8), Color(0xFFE8F0FE)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const SizedBox(height: 16),

              // Bluetooth Printer Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.print,
                            color: Color(0xFF1A3C8B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Printer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1A3C8B),
                          ),
                        ),
                        const Spacer(),
                        // Printer Type Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _useSunmiPrinter = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !_useSunmiPrinter ? const Color(0xFF1A3C8B) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Bluetooth',
                                    style: TextStyle(
                                      color: !_useSunmiPrinter ? Colors.white : Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _useSunmiPrinter = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _useSunmiPrinter ? const Color(0xFF1A3C8B) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Sunmi',
                                    style: TextStyle(
                                      color: _useSunmiPrinter ? Colors.white : Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1A3C8B),
                            ),
                          )
                        : _useSunmiPrinter
                        ? _buildSunmiSection()
                        : _buildBluetoothSection(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Invoice Details Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color(0xFF1A3C8B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Invoice Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1A3C8B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Company Info
                    _buildDetailSection('Company Information', [
                      {
                        'label': 'Name',
                        'value': widget.invoiceData['company_name'] ?? 'N/A',
                      },
                      {
                        'label': 'TIN',
                        'value': widget.invoiceData['company_tin'] ?? 'N/A',
                      },
                    ], Icons.business),

                    const SizedBox(height: 16),

                    // Buyer Info
                    _buildDetailSection('Customer Information', [
                      {
                        'label': 'Name',
                        'value': widget.invoiceData['buyer_name'] ?? 'N/A',
                      },
                      {
                        'label': 'TIN',
                        'value': widget.invoiceData['buyer_tin'] ?? 'N/A',
                      },
                    ], Icons.person),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Items Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory,
                            color: Color(0xFF1A3C8B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1A3C8B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...items
                        .map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['description'] ?? 'Item',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: ${item['quantity']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${(item['unit_price'] as num? ?? 0).toStringAsFixed(2)} ETB',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(item['total_line_amount'] as num? ?? 0).toStringAsFixed(2)} ETB',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1A3C8B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Financial Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calculate,
                            color: Color(0xFF1A3C8B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Financial Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1A3C8B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Subtotal',
                      '${((widget.invoiceData['total_value'] ?? 0) - (widget.invoiceData['tax_value'] ?? 0)).toStringAsFixed(2)} ETB',
                    ),
                    _buildSummaryRow(
                      'Tax (15%)',
                      '+ ${(widget.invoiceData['tax_value'] ?? 0).toStringAsFixed(2)} ETB',
                    ),
                    const Divider(height: 32),
                    _buildSummaryRow(
                      'Total Amount',
                      '${(widget.invoiceData['total_value'] ?? 0).toStringAsFixed(2)} ETB',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // QR Code Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C8B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code,
                            color: Color(0xFF1A3C8B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'QR Code',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1A3C8B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: widget.invoiceData['qr'] != null
                            ? Image.memory(
                                base64Decode(widget.invoiceData['qr']),
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'QR Code not available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Test Invoice Label
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '--- TEST INVOICE ---',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    List<Map<String, String>> details,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A3C8B), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A3C8B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details
              .map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detail['label']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          detail['value']!,
                          // overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF1A3C8B) : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF1A3C8B) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothSection() {
    return _devices.isEmpty
        ? Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.bluetooth_disabled,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Bluetooth devices found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please ensure Bluetooth is enabled and devices are paired',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _initBluetooth,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Request Permissions & Refresh',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C8B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: DropdownButton<BluetoothInfo>(
                  isExpanded: true,
                  hint: const Text('Select printer'),
                  value: _selectedDevice,
                  underline: Container(),
                  items: _devices.map((device) {
                    return DropdownMenuItem(
                      value: device,
                      child: Row(
                        children: [
                          const Icon(Icons.print, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              device.name ?? 'Unknown Device',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (device) {
                    setState(() {
                      _selectedDevice = device;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedDevice == null
                      ? null
                      : _connectToDevice,
                  icon: Icon(
                    bluetoothManager.isConnected
                        ? Icons.check_circle
                        : Icons.bluetooth,
                    color: Colors.white,
                  ),
                  label: Text(
                    bluetoothManager.isConnected
                        ? 'Connected'
                        : 'Connect to Printer',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bluetoothManager.isConnected
                        ? Colors.green
                        : const Color(0xFF1A3C8B),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildSunmiSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.print,
                size: 48,
                color: const Color(0xFF1A3C8B),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sunmi Printer',
                style: TextStyle(
                  color: Color(0xFF1A3C8B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect to the built-in Sunmi printer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _connectToDevice,
            icon: Icon(
              _sunmiService.isConnected
                  ? Icons.check_circle
                  : Icons.print,
              color: Colors.white,
            ),
            label: Text(
              _sunmiService.isConnected
                  ? 'Connected'
                  : 'Connect to Sunmi Printer',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _sunmiService.isConnected
                  ? Colors.green
                  : const Color(0xFF1A3C8B),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
