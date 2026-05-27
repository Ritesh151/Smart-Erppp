import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';

class InvoiceTemplate {
  static String generate({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) {
    final itemsHtml = items.map((item) => '''
      <tr>
        <td style="padding: 8px; border-bottom: 1px solid #eee;">${item.productName}</td>
        <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: center;">${item.quantity.toInt()}</td>
        <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: right;">₹${item.unitPrice.toStringAsFixed(2)}</td>
        <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: center;">${item.taxRate.toStringAsFixed(0)}%</td>
        <td style="padding: 8px; border-bottom: 1px solid #eee; text-align: right;">₹${item.subtotal.toStringAsFixed(2)}</td>
      </tr>
    ''').join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 14px; color: #333; padding: 40px; }
    .header { display: flex; justify-content: space-between; align-items: start; margin-bottom: 40px; }
    .brand h1 { color: #1976d2; font-size: 28px; margin-bottom: 4px; }
    .brand p { color: #666; font-size: 12px; }
    .invoice-meta { text-align: right; }
    .invoice-meta h2 { color: #333; font-size: 22px; margin-bottom: 8px; }
    .invoice-meta p { color: #666; font-size: 13px; margin-bottom: 2px; }
    .status { 
      display: inline-block; padding: 4px 12px; border-radius: 4px; 
      font-size: 12px; font-weight: bold; text-transform: uppercase;
      background: ${_statusColor(invoice.status)}; color: white;
    }
    .section { margin-bottom: 24px; }
    .section-title { font-size: 14px; font-weight: 600; color: #1976d2; margin-bottom: 12px; text-transform: uppercase; }
    .customer-info p { color: #555; font-size: 13px; line-height: 1.6; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
    th { background: #f5f5f5; padding: 10px 8px; text-align: left; font-size: 12px; font-weight: 600; color: #555; text-transform: uppercase; }
    td { padding: 10px 8px; font-size: 13px; }
    .totals { width: 300px; margin-left: auto; }
    .totals tr td { padding: 6px 8px; }
    .totals tr td:last-child { text-align: right; }
    .totals .grand-total td { font-weight: bold; font-size: 16px; border-top: 2px solid #333; padding-top: 10px; }
    .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #888; text-align: center; }
    .notes { margin-top: 24px; padding: 16px; background: #f9f9f9; border-radius: 4px; }
    .notes p { font-size: 13px; color: #555; }
  </style>
</head>
<body>
  <div class="header">
    <div class="brand">
      <h1>SmartERP</h1>
      <p>Siddhivinayak Enterprise</p>
    </div>
    <div class="invoice-meta">
      <h2>${invoice.invoiceNumber}</h2>
      <p>Date: ${_formatDate(invoice.invoiceDate)}</p>
      <p>Due Date: ${_formatDate(invoice.dueDate)}</p>
      <p style="margin-top: 8px;"><span class="status">${invoice.status.name}</span></p>
    </div>
  </div>

  <div class="section">
    <div class="section-title">Bill To</div>
    <div class="customer-info">
      <p><strong>${invoice.customerName}</strong></p>
      ${invoice.customerAddress != null ? '<p>${invoice.customerAddress}</p>' : ''}
      ${invoice.customerPhone != null ? '<p>Phone: ${invoice.customerPhone}</p>' : ''}
      ${invoice.customerEmail != null ? '<p>Email: ${invoice.customerEmail}</p>' : ''}
      ${invoice.customerGst != null ? '<p>GST: ${invoice.customerGst}</p>' : ''}
    </div>
  </div>

  <div class="section">
    <div class="section-title">Items</div>
    <table>
      <thead>
        <tr>
          <th>Item</th>
          <th style="text-align: center;">Qty</th>
          <th style="text-align: right;">Price</th>
          <th style="text-align: center;">GST</th>
          <th style="text-align: right;">Total</th>
        </tr>
      </thead>
      <tbody>
        $itemsHtml
      </tbody>
    </table>
  </div>

  <table class="totals">
    <tr><td>Subtotal</td><td>₹${invoice.subtotal.toStringAsFixed(2)}</td></tr>
    <tr><td>Tax</td><td>₹${invoice.taxAmount.toStringAsFixed(2)}</td></tr>
    ${invoice.discountAmount > 0 ? '<tr><td>Discount</td><td>-₹${invoice.discountAmount.toStringAsFixed(2)}</td></tr>' : ''}
    ${invoice.paidAmount > 0 ? '<tr><td>Paid</td><td>-₹${invoice.paidAmount.toStringAsFixed(2)}</td></tr>' : ''}
    <tr class="grand-total"><td>Total</td><td>₹${invoice.totalAmount.toStringAsFixed(2)}</td></tr>
  </table>

  ${_buildNotes(invoice)}

  <div class="footer">
    <p>Thank you for your business!</p>
    <p>SmartERP — Siddhivinayak Enterprise</p>
  </div>
</body>
</html>
''';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return '#9e9e9e';
      case InvoiceStatus.sent: return '#1976d2';
      case InvoiceStatus.paid: return '#388e3c';
      case InvoiceStatus.partiallyPaid: return '#f57c00';
      case InvoiceStatus.overdue: return '#d32f2f';
      case InvoiceStatus.cancelled: return '#616161';
    }
  }

  static String _buildNotes(InvoiceModel invoice) {
    if (invoice.notes == null && invoice.termsAndConditions == null) return '';
    final notes = StringBuffer();
    notes.writeln('<div class="notes">');
    if (invoice.notes != null) {
      notes.writeln('<p><strong>Notes:</strong></p>');
      notes.writeln('<p>${invoice.notes}</p>');
    }
    if (invoice.termsAndConditions != null) {
      notes.writeln('<p><strong>Terms & Conditions:</strong></p>');
      notes.writeln('<p>${invoice.termsAndConditions}</p>');
    }
    notes.writeln('</div>');
    return notes.toString();
  }
}
