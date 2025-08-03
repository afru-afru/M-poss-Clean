// lib/receipt_generator.dart

import 'dart:convert';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptGenerator {
  static Future<List<int>> generateBluetoothReceiptBytes(
      Map<String, dynamic> invoiceData) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // --- Receipt content generation ---
    // Extract data
    final items = invoiceData['items'] as List<dynamic>? ?? [];
    final date = invoiceData['invoice_date'] != null
        ? DateTime.parse(invoiceData['invoice_date'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

    // ... (All other company, invoice, and item details remain the same) ...
    // Company information
    bytes += generator.text(
      'TIN: ${invoiceData['company_tin'] ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      invoiceData['company_name'] ?? 'COMPANY NAME',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text('A.A,SUBCITY KIRKOS', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('W-09,H.NO-1146/BMS 05C', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('DEMBEL GROUND FLOOR', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TEL: N/A', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-');

    // Invoice details
    bytes += generator.text('FS No. ${invoiceData['invoice_number'] ?? 'N/A'}');
    bytes += generator.row([
      PosColumn(text: formattedDate, width: 6),
      PosColumn(text: formattedTime, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.text('Buyer\'s TIN: ${invoiceData['buyer_tin'] ?? 'N/A'}');
    bytes += generator.text('Customer: ${invoiceData['buyer_name'] ?? 'N/A'}');
    bytes += generator.text('Operator: ${invoiceData['company_name'] ?? 'N/A'}');
    bytes += generator.hr(ch: '-');

    // Items header
    bytes += generator.text('Description          Qty   Price');
    bytes += generator.hr(ch: '-');

    // Items
    for (var item in items) {
      final String description = (item['description'] ?? 'Item').toString();
      final String qty = (item['quantity'] ?? 1).toString();
      final String unitPrice = (item['unit_price'] as num? ?? 0).toStringAsFixed(2);
      final String totalAmount = (item['total_line_amount'] as num? ?? 0).toStringAsFixed(2);

      bytes += generator.row([
        PosColumn(
          text: description.length > 18 ? description.substring(0, 18) : description,
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(text: '$qty x *$unitPrice', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.text('*$totalAmount', styles: const PosStyles(align: PosAlign.right));
    }

    bytes += generator.hr(ch: '-');

    // Totals
    final num subtotal = (invoiceData['total_value'] as num? ?? 0) - (invoiceData['tax_value'] as num? ?? 0);
    final num tax = invoiceData['tax_value'] as num? ?? 0;

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
      PosColumn(
        text: '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}',
        width: 8,
        styles: const PosStyles(bold: true, height: PosTextSize.size2, align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'CASH', width: 6),
      PosColumn(text: '*${(invoiceData['total_value'] as num? ?? 0).toStringAsFixed(2)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.hr(ch: '-');

    bytes += generator.row([
      PosColumn(text: 'ITEM #', width: 6),
      PosColumn(text: items.length.toString(), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.feed(1);

    // **** Using the static QR code as requested ****
    bytes += generator.qrcode('https://portal.mor.gov.et/', size: QRSize.size5);
    bytes += generator.feed(1);
    
    bytes += generator.text('ET FGB0016901', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.text('--- TEST INVOICE ---', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}