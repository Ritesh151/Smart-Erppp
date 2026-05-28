import 'dart:io';

import 'package:SmartERP/core/models/invoice_item_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  Future<String> saveHtmlToFile({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    try {
      final html = _generateInvoiceHtml(invoice, items);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.html',
      );
      await file.writeAsString(html);
      Logger.success(
          'Invoice HTML saved: ${file.path}');
      return file.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to save invoice HTML', e, stackTrace);
      rethrow;
    }
  }

  String _generateInvoiceHtml(
    InvoiceModel invoice,
    List<InvoiceItemModel> items,
  ) {
    final itemsRows = items.map((item) {
      final discountAmt = item.discountAmount;
      final taxableAmt = item.taxableAmount;
      final gstAmt = item.taxAmount;

      return '''
      <tr>
        <td>${item.productName}</td>
        <td>${item.hsnCode ?? '-'}</td>
        <td>${item.quantity}</td>
        <td>${item.unit}</td>
        <td>${_formatCurrency(item.unitPrice)}</td>
        <td>${item.discountRate}%</td>
        <td>${item.taxRate}%</td>
        <td>${_formatCurrency(item.amount)}</td>
      </tr>''';
    }).join('\n');

    final amountInWords = _numberToWords(invoice.totalAmount.toInt());

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invoice ${invoice.invoiceNumber}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size: 12px; color: #333; line-height: 1.5; padding: 20px; }
    .invoice-box { max-width: 800px; margin: 0 auto; padding: 30px; border: 1px solid #ddd; background: #fff; }
    .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #2c3e50; }
    .company-info h1 { font-size: 24px; color: #2c3e50; margin-bottom: 5px; }
    .company-info p { font-size: 11px; color: #666; }
    .invoice-title { text-align: right; }
    .invoice-title h2 { font-size: 20px; color: #2c3e50; }
    .invoice-title p { font-size: 12px; color: #666; margin-top: 5px; }
    .details { display: flex; justify-content: space-between; margin-bottom: 25px; }
    .details .bill-to, .details .invoice-details { width: 48%; }
    .details h3 { font-size: 13px; color: #2c3e50; margin-bottom: 8px; text-transform: uppercase; }
    .details p { font-size: 11px; color: #555; margin-bottom: 3px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    table thead th { background: #2c3e50; color: #fff; font-size: 11px; padding: 10px 8px; text-align: left; text-transform: uppercase; }
    table tbody td { padding: 8px; border-bottom: 1px solid #ddd; font-size: 11px; }
    table tbody tr:nth-child(even) { background: #f9f9f9; }
    table tbody tr:last-child td { border-bottom: 2px solid #2c3e50; }
    .totals { width: 300px; margin-left: auto; }
    .totals table { margin-bottom: 0; }
    .totals td { padding: 6px 8px; font-size: 11px; }
    .totals td:last-child { text-align: right; }
    .totals .grand-total td { font-size: 15px; font-weight: bold; color: #2c3e50; border-top: 2px solid #2c3e50; padding-top: 8px; }
    .amount-in-words { margin-top: 15px; font-size: 11px; color: #555; }
    .amount-in-words strong { color: #2c3e50; }
    .terms { margin-top: 25px; padding-top: 15px; border-top: 1px solid #ddd; }
    .terms h4 { font-size: 12px; color: #2c3e50; margin-bottom: 5px; }
    .terms p { font-size: 11px; color: #666; }
    .footer { margin-top: 30px; text-align: center; font-size: 10px; color: #999; }
    @media print { body { padding: 0; } .invoice-box { border: none; } }
  </style>
</head>
<body>
  <div class="invoice-box">
    <div class="header">
      <div class="company-info">
        <h1>Your Company Name</h1>
        <p>123 Business Street, City, State - 123456</p>
        <p>Phone: +91-9876543210 | Email: info@company.com</p>
        <p>GST: 12ABCDE1234F1Z5</p>
      </div>
      <div class="invoice-title">
        <h2>INVOICE</h2>
        <p><strong>${invoice.invoiceNumber}</strong></p>
      </div>
    </div>

    <div class="details">
      <div class="bill-to">
        <h3>Bill To</h3>
        <p><strong>${invoice.customerName}</strong></p>
        ${invoice.customerAddress != null ? '<p>${invoice.customerAddress}</p>' : ''}
        ${invoice.customerEmail != null ? '<p>${invoice.customerEmail}</p>' : ''}
        ${invoice.customerPhone != null ? '<p>${invoice.customerPhone}</p>' : ''}
        ${invoice.customerGst != null ? '<p>GST: ${invoice.customerGst}</p>' : ''}
      </div>
      <div class="invoice-details">
        <h3>Invoice Details</h3>
        <p><strong>Invoice Date:</strong> ${_formatDate(invoice.invoiceDate)}</p>
        <p><strong>Due Date:</strong> ${_formatDate(invoice.dueDate)}</p>
        <p><strong>Status:</strong> ${invoice.status.name.toUpperCase()}</p>
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Product</th>
          <th>HSN</th>
          <th>Qty</th>
          <th>Unit</th>
          <th>Rate</th>
          <th>Disc%</th>
          <th>GST%</th>
          <th>Amount</th>
        </tr>
      </thead>
      <tbody>
        $itemsRows
      </tbody>
    </table>

    <div class="totals">
      <table>
        <tr><td>Subtotal</td><td>${_formatCurrency(invoice.subtotal)}</td></tr>
        <tr><td>Tax Amount</td><td>${_formatCurrency(invoice.taxAmount)}</td></tr>
        <tr><td>Discount</td><td>${_formatCurrency(invoice.discountAmount)}</td></tr>
        <tr class="grand-total"><td>Grand Total</td><td>${_formatCurrency(invoice.totalAmount)}</td></tr>
      </table>
    </div>

    <div class="amount-in-words">
      <p><strong>Amount in Words:</strong> $amountInWords</p>
    </div>

    ${invoice.termsAndConditions != null ? '''
    <div class="terms">
      <h4>Terms & Conditions</h4>
      <p>${invoice.termsAndConditions}</p>
    </div>''' : ''}

    ${invoice.notes != null ? '''
    <div class="terms">
      <h4>Notes</h4>
      <p>${invoice.notes}</p>
    </div>''' : ''}

    <div class="footer">
      <p>This is a computer-generated invoice. No signature is required.</p>
    </div>
  </div>
</body>
</html>''';
  }

  String _formatCurrency(double amount) {
    return '₹ ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String convertBelowThousand(int n) {
      if (n == 0) return '';
      if (n < 20) return units[n];
      if (n < 100) {
        final t = tens[n ~/ 10];
        final u = units[n % 10];
        return u.isEmpty ? t : '$t $u';
      }
      final h = units[n ~/ 100];
      final r = n % 100;
      return r == 0 ? '$h Hundred' : '$h Hundred ${convertBelowThousand(r)}';
    }

    String result = '';
    if (number >= 10000000) {
      final c = number ~/ 10000000;
      result += '${convertBelowThousand(c)} Crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      final l = number ~/ 100000;
      result += '${convertBelowThousand(l)} Lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      final t = number ~/ 1000;
      result += '${convertBelowThousand(t)} Thousand ';
      number %= 1000;
    }
    result += convertBelowThousand(number);
    return result.trim() + ' Rupees Only';
  }
}
