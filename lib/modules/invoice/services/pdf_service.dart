import 'dart:io';

import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static const String companyName = 'Siddhivinayak Enterprise';
  static const String companyAddress =
      '114/80, Laxmanji Ravtaji Compound, Mandi Kuva Road,\nO/S Shahpur Gate, Near Municipal Quarter,\nKazipur Dariyapur, Ahmedabad – 380004';
  static const String companyPhone = '9974884444';
  static const String companyEmail = 'siddhivinayak0330@gmail.com';
  static const String companyGstin = '24BCTPC3372F1ZO';

  Future<String> saveHtmlToFile({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    try {
      final html = await generateInvoiceHtml(invoice: invoice, items: items);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.html',
      );
      await file.writeAsString(html);
      Logger.success('Invoice HTML saved: ${file.path}');
      return file.path;
    } catch (e, stackTrace) {
      Logger.error('Failed to save invoice HTML', e, stackTrace);
      rethrow;
    }
  }

  Future<String> generateInvoiceHtml({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    final subtotal = invoice.subtotal;
    final totalTax = invoice.taxAmount;
    final cgst = totalTax / 2;
    final sgst = totalTax / 2;
    const igst = 0.0;
    final discount = invoice.discountAmount;
    final internalChargesTotal = invoice.internalChargesTotal;
    final grandTotal = invoice.totalAmount;
    final roundedGrandTotal = grandTotal.roundToDouble();
    final roundOff = roundedGrandTotal - grandTotal;

    final invoiceDate = _formatDateFull(invoice.invoiceDate);
    final amountInWords = _numberToWordsIndian(roundedGrandTotal.toInt());

    final imageHtml = <String>[];
    for (final item in items) {
      String imgTag;
      if (item.imagePath != null && item.imagePath!.trim().isNotEmpty) {
        try {
          final file = File(item.imagePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final base64 = _base64Encode(bytes);
            final ext = item.imagePath!.split('.').last.toLowerCase();
            final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
            imgTag =
                '<img src="data:$mime;base64,$base64" class="prod-img" alt="${_escapeHtml(item.productName)}" />';
          } else {
            imgTag = _placeholderImage();
          }
        } catch (_) {
          imgTag = _placeholderImage();
        }
      } else {
        imgTag = _placeholderImage();
      }
      imageHtml.add(imgTag);
    }

    String getTerms() {
      final terms = invoice.termsAndConditions;
      if (terms != null && terms.trim().isNotEmpty) {
        final lines = terms.split('\n').where((l) => l.trim().isNotEmpty);
        return lines.map((l) => '› ${_escapeHtml(l.trim())}').join(' &nbsp;\n');
      }
      return '';
    }

    final termsContent = getTerms();

    final itemsRows = items.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final item = entry.value;
      final img = imageHtml[idx - 1];
      return '''
        <tr>
          <td class="num">$idx</td>
          <td class="td-img-col">$img</td>
          <td>
            <div class="td-desc">${_escapeHtml(item.productName)}</div>
            ${item.hsnCode != null ? '<div class="td-hsn">HSN: ${_escapeHtml(item.hsnCode!)}</div>' : ''}
          </td>
          <td class="right">${item.quantity.toInt()}</td>
          <td class="right">₹${_formatNumber(item.unitPrice)}</td>
          <td class="right">₹${_formatNumber(item.amount)}</td>
        </tr>''';
    }).join('\n');

    final totalQty = items.fold<int>(0, (sum, i) => sum + i.quantity.toInt());

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Tax Invoice – $companyName #${invoice.invoiceNumber}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Source+Sans+3:wght@300;400;600;700&display=swap');

    :root {
      --ink: #1a1a1a;
      --muted: #555555;
      --light-muted: #888888;
      --accent: #2b4c7e;
      --accent-lite: #dce8f8;
      --border: #c8d4e3;
      --bg: #f4f7fb;
      --white: #ffffff;
      --font-body: 'Source Sans 3', sans-serif;
      --font-head: 'Playfair Display', serif;
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      font-family: var(--font-body);
      color: var(--ink);
      padding: 32px 16px;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }

    .invoice {
      background: var(--white);
      max-width: 900px;
      margin: 0 auto;
      border: 1px solid var(--border);
      border-radius: 4px;
      overflow: hidden;
      box-shadow: 0 4px 28px rgba(43,76,126,.10);
    }

    .header {
      background: var(--accent);
      padding: 28px 36px 22px;
      color: var(--white);
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 20px;
    }
    .header-brand h1 {
      font-family: var(--font-head);
      font-size: 1.55rem;
      letter-spacing: .5px;
      line-height: 1.2;
    }
    .header-brand address {
      font-style: normal;
      font-size: .78rem;
      margin-top: 6px;
      opacity: .88;
      line-height: 1.6;
    }
    .header-brand address a {
      color: inherit;
      text-decoration: none;
      opacity: .9;
    }
    .header-brand .gstin {
      margin-top: 6px;
      font-size: .72rem;
      opacity: .75;
      letter-spacing: .4px;
    }
    .header-badge {
      text-align: right;
      flex-shrink: 0;
    }
    .header-badge .label {
      font-size: .65rem;
      letter-spacing: 2.5px;
      text-transform: uppercase;
      opacity: .7;
    }
    .header-badge .invoice-title {
      font-family: var(--font-head);
      font-size: 1.55rem;
      letter-spacing: 4px;
      text-transform: uppercase;
    }
    .header-badge .inv-num {
      margin-top: 4px;
      font-size: .85rem;
      opacity: .85;
      font-weight: 600;
    }

    .meta-strip {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      border-bottom: 1px solid var(--border);
    }
    .meta-cell {
      padding: 14px 20px;
      border-right: 1px solid var(--border);
    }
    .meta-cell:last-child { border-right: none; }
    .meta-cell .mc-label {
      font-size: .6rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: var(--light-muted);
      font-weight: 700;
    }
    .meta-cell .mc-value {
      margin-top: 4px;
      font-size: .88rem;
      font-weight: 600;
      color: var(--ink);
    }

    .parties {
      display: grid;
      grid-template-columns: 1fr 1fr;
      border-bottom: 1px solid var(--border);
    }
    .party-block {
      padding: 18px 24px;
    }
    .party-block + .party-block {
      border-left: 1px solid var(--border);
    }
    .party-block .pb-label {
      font-size: .6rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: var(--accent);
      font-weight: 700;
      margin-bottom: 8px;
    }
    .party-block .pb-name {
      font-size: .98rem;
      font-weight: 700;
      color: var(--ink);
    }
    .party-block address {
      font-style: normal;
      font-size: .82rem;
      color: var(--muted);
      line-height: 1.65;
      margin-top: 4px;
    }
    .party-block .pb-pan {
      margin-top: 6px;
      font-size: .75rem;
      color: var(--light-muted);
    }

    .items-section { padding: 0; }

    table.items {
      width: 100%;
      border-collapse: collapse;
      font-size: .83rem;
    }
    table.items thead tr {
      background: var(--accent);
      color: var(--white);
    }
    table.items thead th {
      padding: 11px 12px;
      font-size: .62rem;
      letter-spacing: 1.8px;
      text-transform: uppercase;
      font-weight: 700;
      text-align: left;
    }
    table.items thead th.num { text-align: center; width: 36px; }
    table.items thead th.img-col { width: 68px; text-align: center; }
    table.items thead th.right { text-align: right; }

    table.items tbody tr {
      border-bottom: 1px solid var(--border);
    }
    table.items tbody tr:nth-child(even) {
      background: var(--accent-lite);
    }
    table.items tbody td {
      padding: 10px 12px;
      color: var(--ink);
      vertical-align: middle;
    }
    table.items tbody td.num { text-align: center; color: var(--muted); }
    table.items tbody td.right { text-align: right; }
    table.items tbody td .td-desc { font-weight: 600; }
    table.items tbody td .td-hsn { font-size: .72rem; color: var(--light-muted); margin-top: 2px; }

    .prod-img {
      width: 56px;
      height: 56px;
      object-fit: cover;
      border-radius: 4px;
      border: 1px solid var(--border);
      display: block;
      background: var(--bg);
    }
    .prod-placeholder {
      width: 56px;
      height: 56px;
      border-radius: 4px;
      border: 1px dashed var(--border);
      display: flex;
      align-items: center;
      justify-content: center;
      background: var(--bg);
      color: var(--light-muted);
      font-size: .5rem;
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    table.items tfoot tr {
      background: var(--accent-lite);
      border-top: 2px solid var(--accent);
    }
    table.items tfoot td {
      padding: 10px 12px;
      font-weight: 700;
      font-size: .85rem;
    }
    table.items tfoot td.right { text-align: right; }

    .amount-words {
      padding: 12px 24px;
      background: #f9f4e8;
      border-top: 1px dashed #d4b87a;
      border-bottom: 1px dashed #d4b87a;
      font-size: .82rem;
      color: var(--muted);
    }
    .amount-words span {
      font-weight: 700;
      color: var(--ink);
    }

    .bottom-grid {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      border-top: 1px solid var(--border);
    }
    .bg-block {
      padding: 18px 22px;
      border-right: 1px solid var(--border);
    }
    .bg-block:last-child { border-right: none; }
    .bg-block .bg-title {
      font-size: .6rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: var(--accent);
      font-weight: 700;
      margin-bottom: 10px;
    }

    .gst-row {
      display: flex;
      justify-content: space-between;
      font-size: .82rem;
      padding: 4px 0;
      border-bottom: 1px dotted var(--border);
    }
    .gst-row:last-child { border-bottom: none; }
    .gst-row .gr-label { color: var(--muted); }
    .gst-row .gr-val { font-weight: 600; }
    .gst-row.zero .gr-val { color: var(--light-muted); }

    .bank-row {
      display: flex;
      gap: 8px;
      font-size: .82rem;
      padding: 3px 0;
    }
    .bank-row .br-label {
      color: var(--light-muted);
      font-size: .75rem;
      min-width: 52px;
    }
    .bank-row .br-val { font-weight: 600; }

    .sum-row {
      display: flex;
      justify-content: space-between;
      font-size: .82rem;
      padding: 4px 0;
      border-bottom: 1px dotted var(--border);
    }
    .sum-row:last-child {
      border-bottom: none;
      margin-top: 6px;
      padding-top: 8px;
      font-size: 1rem;
      font-weight: 700;
      color: var(--accent);
    }
    .sum-row .sr-label { color: var(--muted); }
    .sum-row .sr-val { font-weight: 600; }
    .sum-row:last-child .sr-label,
    .sum-row:last-child .sr-val { color: var(--accent); }

    .footer {
      background: var(--accent);
      color: var(--white);
      padding: 16px 28px;
      display: flex;
      justify-content: space-between;
      align-items: flex-end;
      gap: 20px;
    }
    .footer-terms {
      font-size: .72rem;
      opacity: .82;
      line-height: 1.7;
      max-width: 520px;
    }
    .footer-terms .ft-head {
      font-size: .62rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      font-weight: 700;
      opacity: .6;
      margin-bottom: 4px;
    }
    .footer-sign {
      text-align: right;
      flex-shrink: 0;
    }
    .footer-sign .fs-for {
      font-size: .68rem;
      opacity: .65;
      margin-bottom: 34px;
      font-style: italic;
    }
    .footer-sign .fs-line {
      border-top: 1px solid rgba(255,255,255,.5);
      padding-top: 6px;
      font-size: .72rem;
      opacity: .75;
      font-weight: 600;
      letter-spacing: .5px;
    }

    .generated-line {
      text-align: center;
      font-size: .68rem;
      color: var(--light-muted);
      padding: 10px 0 4px;
    }

    @media print {
      body { background: white; padding: 0; }
      .invoice { box-shadow: none; border: none; }
    }
  </style>
</head>
<body>

<div class="invoice">

  <div class="header">
    <div class="header-brand">
      <h1>$companyName</h1>
      <address>
        ${companyAddress.replaceAll('\n', '<br>')}<br>
        <a href="tel:$companyPhone">$companyPhone</a> &nbsp;·&nbsp;
        <a href="mailto:$companyEmail">$companyEmail</a>
      </address>
      <p class="gstin">GSTIN: $companyGstin</p>
    </div>
    <div class="header-badge">
      <p class="label">Document Type</p>
      <p class="invoice-title">Tax Invoice</p>
      <p class="inv-num">#${invoice.invoiceNumber}</p>
    </div>
  </div>

  <div class="meta-strip">
    <div class="meta-cell">
      <p class="mc-label">Date</p>
      <p class="mc-value">$invoiceDate</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Invoice No.</p>
      <p class="mc-value">${invoice.invoiceNumber}</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Delivery At</p>
      <p class="mc-value">${_escapeHtml(invoice.customerAddress?.split(',').last.trim() ?? invoice.customerName)}</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Buyer Status</p>
      <p class="mc-value">${invoice.customerGst != null && invoice.customerGst!.isNotEmpty ? 'Registered' : 'URP'}</p>
    </div>
  </div>

  <div class="parties">
    <div class="party-block">
      <p class="pb-label">Issued By</p>
      <p class="pb-name">$companyName</p>
      <address>
        ${companyAddress.replaceAll('\n', '<br>')}<br>
        $companyPhone
      </address>
      <p class="pb-pan">GSTIN: $companyGstin</p>
    </div>
    <div class="party-block">
      <p class="pb-label">Billed To (M/S)</p>
      <p class="pb-name">${_escapeHtml(invoice.customerName)}</p>
      <address>
        ${invoice.customerAddress != null ? _escapeHtml(invoice.customerAddress!) : ''}
      </address>
      ${invoice.customerGst != null ? '<p class="pb-pan">GSTIN: ${_escapeHtml(invoice.customerGst!)}</p>' : ''}
    </div>
  </div>

  <div class="items-section">
    <table class="items">
      <thead>
        <tr>
          <th class="num">SR</th>
          <th class="img-col">Image</th>
          <th>Product Description</th>
          <th class="right">QTY</th>
          <th class="right">Rate</th>
          <th class="right">Amount</th>
        </tr>
      </thead>
      <tbody>
        $itemsRows
      </tbody>
      <tfoot>
        <tr>
          <td colspan="2"></td>
          <td><strong>Total</strong></td>
          <td class="right">$totalQty</td>
          <td class="right">₹${_formatNumber(subtotal)}</td>
          <td class="right">₹${_formatNumber(subtotal)}</td>
        </tr>
      </tfoot>
    </table>
  </div>

  <div class="amount-words">
    Amount in Words: &nbsp;<span>Rupees ${_escapeHtml(amountInWords)} Only</span>
  </div>

  ${_buildInternalChargesHtml(invoice)}

  ${_buildPaymentTermsHtml(invoice)}

  <div class="bottom-grid">
    <div class="bg-block">
      <p class="bg-title">GST Breakup</p>
      <div class="gst-row">
        <span class="gr-label">CGST @ 9%</span>
        <span class="gr-val">₹${_formatNumber(cgst)}</span>
      </div>
      <div class="gst-row">
        <span class="gr-label">SGST @ 9%</span>
        <span class="gr-val">₹${_formatNumber(sgst)}</span>
      </div>
      <div class="gst-row zero">
        <span class="gr-label">IGST @ 18%</span>
        <span class="gr-val">₹${_formatNumber(igst)}</span>
      </div>
      <div class="gst-row${roundOff == 0 ? ' zero' : ''}">
        <span class="gr-label">Round Off</span>
        <span class="gr-val">₹${roundOff >= 0 ? '+' : ''}${roundOff.toStringAsFixed(2)}</span>
      </div>
    </div>

    <div class="bg-block">
      <p class="bg-title">Bank Details</p>
      <div class="bank-row">
        <span class="br-label">Bank</span>
        <span class="br-val">${_escapeHtml(invoice.bankName ?? 'Indian Bank')}</span>
      </div>
      <div class="bank-row">
        <span class="br-label">Branch</span>
        <span class="br-val">${_escapeHtml(invoice.branchName ?? 'Usmanpura')}</span>
      </div>
      <div class="bank-row">
        <span class="br-label">IFSC</span>
        <span class="br-val">${_escapeHtml(invoice.ifscCode ?? 'IDIB000A666')}</span>
      </div>
      <div class="bank-row">
        <span class="br-label">A/C No.</span>
        <span class="br-val">${_escapeHtml(invoice.accountNumber ?? '7648102905')}</span>
      </div>
    </div>

    <div class="bg-block">
      <p class="bg-title">Summary</p>
      <div class="sum-row">
        <span class="sr-label">Subtotal</span>
        <span class="sr-val">₹${_formatNumber(subtotal)}</span>
      </div>
      <div class="sum-row">
        <span class="sr-label">CGST @ 9%</span>
        <span class="sr-val">₹${_formatNumber(cgst)}</span>
      </div>
       <div class="sum-row">
          <span class="sr-label">SGST @ 9%</span>
          <span class="sr-val">₹${_formatNumber(sgst)}</span>
        </div>
        ${internalChargesTotal > 0 ? '''
        <div class="sum-row">
          <span class="sr-label">Internal Charges</span>
          <span class="sr-val">₹${_formatNumber(internalChargesTotal)}</span>
        </div>''' : ''}
        <div class="sum-row">
          <span class="sr-label">Grand Total</span>
        <span class="sr-val">₹${_formatNumber(roundedGrandTotal)}</span>
      </div>
    </div>
  </div>

  <div class="footer">
    <div class="footer-terms">
      <p class="ft-head">Terms &amp; Conditions</p>
      ${termsContent.isNotEmpty ? termsContent : '› Goods once sold will not be taken back or exchanged. &nbsp;› Goods despatched at buyer\'s risk. &nbsp;› 18% interest will be charged on overdue payment. &nbsp;› Subject to Ahmedabad jurisdiction.'}
    </div>
    <div class="footer-sign">
      <p class="fs-for">For, $companyName · GSTIN: $companyGstin</p>
      <p class="fs-line">Authorised Signatory</p>
    </div>
  </div>

  <p class="generated-line">
    $companyEmail &nbsp;·&nbsp; Generated: $invoiceDate
  </p>

</div>

</body>
</html>''';
  }

  String _placeholderImage() {
    return '<div class="prod-placeholder">No<br>Image</div>';
  }

  String _base64Encode(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b1 = bytes[i];
      final b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      final triple = (b1 << 16) | (b2 << 8) | b3;
      buffer.write(chars[(triple >> 18) & 0x3F]);
      buffer.write(chars[(triple >> 12) & 0x3F]);
      if (i + 1 < bytes.length) {
        buffer.write(chars[(triple >> 6) & 0x3F]);
      } else {
        buffer.write('=');
      }
      if (i + 2 < bytes.length) {
        buffer.write(chars[triple & 0x3F]);
      } else {
        buffer.write('=');
      }
    }
    return buffer.toString();
  }

  String _formatNumber(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      count++;
      buffer.write(intPart[i]);
      if (count == 3 && i > 0) {
        buffer.write(',');
        count = 0;
      } else if (count == 2 && i > 0 && intPart.length > 3) {
        final remaining = i;
        if (remaining >= 2) {
          buffer.write(',');
          count = 0;
        }
      }
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '$formatted.$decPart';
  }

  String _formatDateFull(DateTime date) {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _buildInternalChargesHtml(InvoiceModel invoice) {
    final charges = invoice.internalCharges;
    if (charges.isEmpty) return '';

    final rows = charges.map((c) {
      final desc = c.chargeDescription != null && c.chargeDescription!.trim().isNotEmpty
          ? '<p style="font-size:0.78rem;color:var(--muted);margin-top:2px;">${_escapeHtml(c.chargeDescription!)}</p>'
          : '';
      return '''
        <div class="ic-row">
          <div>
            <span class="ic-name">${_escapeHtml(c.chargeName)}</span>$desc
          </div>
          <span class="ic-amount">₹${_formatNumber(c.chargeAmount)}</span>
        </div>''';
    }).join('\n');

    return '''
  <div style="padding: 14px 24px; border-left: 1px solid var(--border); border-right: 1px solid var(--border); border-top: 1px dashed var(--border);">
    <p style="font-size:0.6rem;letter-spacing:2px;text-transform:uppercase;color:var(--accent);font-weight:700;margin-bottom:8px;">Additional Charges</p>
    $rows
    <style>
      .ic-row {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        padding: 6px 0;
        border-bottom: 1px dotted var(--border);
        font-size: .82rem;
      }
      .ic-row:last-child { border-bottom: none; }
      .ic-name { font-weight: 600; color: var(--ink); }
      .ic-amount { font-weight: 700; color: var(--ink); white-space: nowrap; }
    </style>
  </div>''';
  }

  String _buildPaymentTermsHtml(InvoiceModel invoice) {
    final hasPaymentTerms = invoice.paymentDays > 0 || invoice.paymentMonths > 0;
    final hasDescription = invoice.paymentTermDescription != null &&
        invoice.paymentTermDescription!.trim().isNotEmpty;
    final hasCustomNotes = invoice.customPaymentNotes != null &&
        invoice.customPaymentNotes!.trim().isNotEmpty;
    if (!hasPaymentTerms && !hasCustomNotes) return '';

    final buf = StringBuffer();
    buf.write('''
  <div style="padding: 14px 24px; border-left: 1px solid var(--border); border-right: 1px solid var(--border);">
    <p style="font-size:0.6rem;letter-spacing:2px;text-transform:uppercase;color:var(--accent);font-weight:700;margin-bottom:8px;">Payment Terms</p>''');

    if (hasDescription) {
      buf.write('''
    <p style="font-size:0.82rem;color:var(--ink);line-height:1.6;margin-bottom:${hasCustomNotes ? '8' : '0'}px;">${_escapeHtml(invoice.paymentTermDescription!)}</p>''');
    }

    if (hasCustomNotes) {
      buf.write('''
    <p style="font-size:0.68rem;font-weight:700;color:var(--muted);margin-top:${hasDescription ? '6' : '0'}px;margin-bottom:4px;">Additional Payment Conditions:</p>
    <p style="font-size:0.82rem;color:var(--ink);line-height:1.5;">${_escapeHtml(invoice.customPaymentNotes!)}</p>''');
    }

    buf.write('''
  </div>''');
    return buf.toString();
  }

  String _numberToWordsIndian(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
      'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
      'Eighty', 'Ninety'
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
    return result.trim();
  }
}
