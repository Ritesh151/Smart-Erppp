import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/download_helper.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/invoice_pdf_generator.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/pdf_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/widgets/export_success_dialog.dart';

class InvoiceExportService {
  final PdfService _pdfService = PdfService();

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _generateDefaultFileName(
      InvoiceModel invoice, String extension) {
    final dateStr =
        '${invoice.invoiceDate.day.toString().padLeft(2, '0')}-'
        '${invoice.invoiceDate.month.toString().padLeft(2, '0')}-'
        '${invoice.invoiceDate.year}';
    final invNum = invoice.invoiceNumber.replaceAll(RegExp(r'[/\\]'), '-');
    final customerName = invoice.customerName.trim().replaceAll(' ', '');
    final safeName = _sanitizeFileName(customerName);
    final safeInvNum = _sanitizeFileName(invNum);
    return '${safeInvNum}_${safeName}_$dateStr.$extension';
  }

  Future<bool> _ensureDirectory(String path) async {
    final dir = File(path).parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return true;
  }

  Future<void> exportAsPdf({
    required BuildContext context,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    final defaultFileName = _generateDefaultFileName(invoice, 'pdf');

    try {
      if (kIsWeb) {
        final htmlContent = await _pdfService.generateInvoiceHtml(
            invoice: invoice, items: items);
        await downloadInvoiceHtml(
            htmlContent: htmlContent, fileName: defaultFileName);
        if (context.mounted) {
          _showSuccess(context, defaultFileName, '');
        }
        return;
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Invoice as PDF',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final savePath = result.endsWith('.pdf') ? result : '$result.pdf';
      await _ensureDirectory(savePath);

      final pdfBytes =
          await InvoicePdfGenerator.generate(invoice: invoice, items: items);
      await File(savePath).writeAsBytes(pdfBytes);

      if (context.mounted) {
        _showSuccess(context, savePath.split(Platform.pathSeparator).last,
            savePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to export PDF', e.toString());
      }
    }
  }

  Future<void> exportAsHtml({
    required BuildContext context,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    final defaultFileName = _generateDefaultFileName(invoice, 'html');

    try {
      final htmlContent = await _pdfService.generateInvoiceHtml(
          invoice: invoice, items: items);

      if (kIsWeb) {
        await downloadInvoiceHtml(
            htmlContent: htmlContent, fileName: defaultFileName);
        if (context.mounted) {
          _showSuccess(context, defaultFileName, '');
        }
        return;
      }

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Invoice as HTML',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['html'],
      );

      if (result == null) return;

      final savePath = result.endsWith('.html') ? result : '$result.html';
      await _ensureDirectory(savePath);
      await File(savePath).writeAsString(htmlContent);

      if (context.mounted) {
        _showSuccess(context, savePath.split(Platform.pathSeparator).last,
            savePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to export HTML', e.toString());
      }
    }
  }

  void _showSuccess(
      BuildContext context, String fileName, String filePath) {
    showDialog<void>(
      context: context,
      builder: (_) => ExportSuccessDialog(
        filePath: filePath.isNotEmpty ? filePath : fileName,
        fileType: 'Invoice',
      ),
    );
  }

  void _showError(
      BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFEF4444), size: 22),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F6EF7),
            ),
            child: const Text('OK',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
