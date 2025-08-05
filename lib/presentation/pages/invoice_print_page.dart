import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../../core/services/bluetooth_manager.dart';
import '../../core/services/sunmi_printer_service.dart';
import '../../core/services/print_receipt.dart';

class InvoicePrintPage extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const InvoicePrintPage({super.key, required this.invoiceData});

  @override
  State<InvoicePrintPage> createState() => _InvoicePrintPageState();
}

class _InvoicePrintPageState extends State<InvoicePrintPage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  final SunmiPrinterService _sunmiService = SunmiPrinterService();
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _autoConnectToSunmi();
  }

  Future<void> _autoConnectToSunmi() async {
    try {
      print('Starting automatic Sunmi printer connection...');
      
      // First check if Sunmi printer is available
      final available = await _sunmiService.checkAvailability();
      print('Sunmi printer available: $available');
      
      if (available) {
        // Auto-connect to Sunmi printer
        final connected = await _sunmiService.autoConnect();
        print('Sunmi auto-connect result: $connected');
        
        if (connected && mounted) {
          setState(() {});
          _showSnackBar('Automatically connected to Sunmi printer! Click print to print invoice.', isError: false);
        } else if (mounted) {
          _showSnackBar('Sunmi printer available but connection failed. Please try manually.', isError: true);
        }
      } else {
        print('Sunmi printer not available on this device');
        if (mounted) {
          _showSnackBar('Sunmi printer not available. Using Bluetooth instead.', isError: false);
        }
      }
    } catch (e) {
      print('Error in auto-connect to Sunmi: $e');
      if (mounted) {
        _showSnackBar('Error checking Sunmi printer: $e', isError: true);
      }
    }
  }

  // @override
  // void dispose() {
  //   _sunmiService.dispose();
  //   super.dispose();
  // }

  /// Update UI when printer connection state changes
  void _updatePrinterState() {
    if (mounted) {
      setState(() {
        // Update the UI to reflect current connection state
      });
    }
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
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> _printReceipt() async {
    // Check if any printer is connected
    bool isConnected = _sunmiService.isConnected || bluetoothManager.isConnected;
    
    if (!isConnected) {
      _showSnackBar('No printer connected. Please select a printer from the app bar.', isError: true);
      return;
    }

    if (_isPrinting) {
      _showSnackBar('Printing in progress...', isError: true);
      return;
    }

    setState(() => _isPrinting = true);

    try {
      bool result = false;
      
      // Automatically use Sunmi printer if connected, otherwise use Bluetooth
      if (_sunmiService.isConnected) {
        print('Printing with Sunmi printer...');
        result = await _sunmiService.printInvoice(widget.invoiceData);
      } else if (bluetoothManager.isConnected) {
        print('Printing with Bluetooth printer...');
        // Generate the receipt bytes using the new class
        final List<int> bytes = await ReceiptGenerator.generateBluetoothReceiptBytes(widget.invoiceData);
        // Write bytes to the printer
        result = await PrintBluetoothThermal.writeBytes(bytes);
      } else {
        _showSnackBar('No printer connected', isError: true);
        return;
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

  void _showPrinterSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Printer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.print, color: Color(0xFF1A3C8B)),
                title: const Text('Sunmi Printer'),
                subtitle: Text(_sunmiService.isConnected ? 'Connected (Auto)' : 'Not Connected'),
                trailing: _sunmiService.isConnected 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  if (!_sunmiService.isConnected) {
                    await _sunmiService.autoConnect();
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Color(0xFF1A3C8B)),
                title: const Text('Bluetooth Printer'),
                subtitle: Text(bluetoothManager.isConnected ? 'Connected' : 'Not Connected'),
                trailing: bluetoothManager.isConnected 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _showBluetoothDeviceSelection();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBluetoothDeviceSelection() async {
    try {
      // Use the correct method from print_bluetooth_thermal package
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      if (devices.isEmpty) {
        _showSnackBar('No Bluetooth devices found', isError: true);
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Bluetooth Device'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.macAdress ?? 'No MAC Address'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final connected = await bluetoothManager.connect(device);
                      setState(() {});
                      _showSnackBar(
                        connected ? 'Connected to ${device.name}' : 'Failed to connect',
                        isError: !connected,
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showSnackBar('Error getting Bluetooth devices: $e', isError: true);
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

    // Company information
    receipt.writeln(center('TIN: ${widget.invoiceData['company_tin'] ?? 'N/A'}'));
    receipt.writeln(center(widget.invoiceData['company_name'] ?? 'COMPANY NAME'));
    receipt.writeln(center('A.A,SUBCITY KIRKOS'));
    receipt.writeln(center('W-09,H.NO-1146/BMS 05C'));
    receipt.writeln(center('DEMBEL GROUND FLOOR'));
    receipt.writeln(center('TEL: N/A'));
    receipt.writeln(dashLine);

    // Invoice details
    receipt.writeln('FS No. ${widget.invoiceData['invoice_number'] ?? 'N/A'}');
    receipt.writeln('Buyer\'s TIN: ${widget.invoiceData['buyer_tin'] ?? 'N/A'}');
    receipt.writeln('Customer: ${widget.invoiceData['buyer_name'] ?? 'N/A'}');
    receipt.writeln('Operator: ${widget.invoiceData['company_name'] ?? 'N/A'}');
    receipt.writeln(dashLine);

    // Items header
    receipt.writeln(twoColumn('Description', 'Price'));
    receipt.writeln(dashLine);

    // Items
    for (var item in items) {
      String description = (item['description'] ?? 'Item').toString();
      if (description.length > 20) {
        description = description.substring(0, 20);
      }
      final String qty = (item['quantity'] ?? 1).toString();
      final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
      final String totalAmount = '*${(item['total_line_amount'] as num? ?? 0).toStringAsFixed(2)}';

      receipt.writeln(description);
      receipt.writeln(twoColumn('  $qty x $unitPrice', totalAmount));
    }
    receipt.writeln(dashLine);

    // Totals
    final num subtotal = (widget.invoiceData['total_value'] as num? ?? 0) - (widget.invoiceData['tax_value'] as num? ?? 0);
    final num tax = widget.invoiceData['tax_value'] as num? ?? 0;

    receipt.writeln(twoColumn('TXBL1', '*${subtotal.toStringAsFixed(2)}'));
    receipt.writeln(twoColumn('TAX1 15.00%', '*${tax.toStringAsFixed(2)}'));
    receipt.writeln(dashLine);
    receipt.writeln(twoColumn('TOTAL', '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));
    receipt.writeln(twoColumn('CASH', '*${(widget.invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}'));
    receipt.writeln(dashLine);
    receipt.writeln(twoColumn('ITEM #', items.length.toString()));

    // Final section
    receipt.writeln(center('ET FGB0016901'));
    receipt.writeln(center('--- TEST INVOICE ---'));

    return receipt.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = _sunmiService.isConnected || bluetoothManager.isConnected;
    final items = widget.invoiceData['items'] as List<dynamic>? ?? [];
    final date = widget.invoiceData['invoice_date'] != null
        ? DateTime.parse(widget.invoiceData['invoice_date'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3C8B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Print Invoice',
          style: TextStyle(color: Color(0xFF1A3C8B), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Printer selection button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.print, color: Color(0xFF1A3C8B)),
                if (_sunmiService.isConnected || bluetoothManager.isConnected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showPrinterSelectionDialog,
            tooltip: 'Select Printer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Section
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
                          Icons.receipt,
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
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.print, color: Color(0xFF1A3C8B)),
                        onPressed: _isPrinting ? null : _printReceipt,
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
                  const SizedBox(height: 16),
                  // Connection Status Indicator
                  if (_sunmiService.isConnected || bluetoothManager.isConnected)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_sunmiService.isConnected || bluetoothManager.isConnected) 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_sunmiService.isConnected || bluetoothManager.isConnected) 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_sunmiService.isConnected || bluetoothManager.isConnected) 
                                ? Icons.check_circle
                                : Icons.warning,
                            color: (_sunmiService.isConnected || bluetoothManager.isConnected) 
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _sunmiService.isConnected 
                                  ? 'Connected to Sunmi printer (Auto)'
                                  : bluetoothManager.isConnected
                                      ? 'Connected to Bluetooth printer'
                                      : 'No printer connected',
                              style: TextStyle(
                                color: (_sunmiService.isConnected || bluetoothManager.isConnected) 
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
}
