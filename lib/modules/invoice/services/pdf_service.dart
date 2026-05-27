import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/templates/invoice_template.dart';

class PdfService {
  Future<String> generateHtml({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    return InvoiceTemplate.generate(invoice: invoice, items: items);
  }

  Future<String> saveHtmlToFile({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    try {
      final html = await generateHtml(invoice: invoice, items: items);
      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${directory.path}/invoices');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      final fileName = '${invoice.invoiceNumber.replaceAll('/', '_')}.html';
      final file = File('${invoicesDir.path}/$fileName');
      await file.writeAsString(html);

      Logger.success('Invoice HTML saved: ${file.path}');
      return file.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to save invoice HTML', e, stackTrace);
      rethrow;
    }
  }

  Future<String> exportToPdf({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    // TODO: Implement actual PDF generation using pdf package
    // For now, save as HTML which can be opened in browser and printed to PDF
    return saveHtmlToFile(invoice: invoice, items: items);
  }
}
