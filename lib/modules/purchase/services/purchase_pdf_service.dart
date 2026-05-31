import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class PurchasePdfService {
  static const String companyName = 'Siddhivinayak Enterprise';
  static const String companyAddress =
      '114/80, Laxmanji Ravtaji Compound, Mandi Kuva Road,\nO/S Shahpur Gate, Near Municipal Quarter,\nKazipur Dariyapur, Ahmedabad – 380004';
  static const String companyPhone = '9974884444';
  static const String companyEmail = 'siddhivinayak0330@gmail.com';
  static const String companyGstin = '24BCTPC3372F1ZO';

  static String generatePurchaseHtml({
    required Map<String, dynamic> purchase,
    required List<Map<String, dynamic>> items,
  }) {
    final supplierName = purchase['supplierName'] as String? ?? '';
    final supplierMobile = purchase['supplierMobile'] as String? ?? '';
    final supplierGst = purchase['supplierGst'] as String? ?? '';
    final purchaseNumber = purchase['purchaseNumber'] as String? ?? '';
    final purchaseDate = _formatDateFull(DateTime.tryParse(purchase['purchaseDate'] as String? ?? '') ?? DateTime.now());
    final invoiceNumber = purchase['invoiceNumber'] as String? ?? '-';
    final invoiceDateStr = purchase['invoiceDate'] as String? ?? '';
    final invoiceDate = invoiceDateStr.isNotEmpty
        ? _formatDateFull(DateTime.parse(invoiceDateStr))
        : '-';
    final subtotal = (purchase['subtotal'] as num?)?.toDouble() ?? 0;
    final gstAmount = (purchase['gstAmount'] as num?)?.toDouble() ?? 0;
    final discountAmount = (purchase['discountAmount'] as num?)?.toDouble() ?? 0;
    final totalAmount = (purchase['totalAmount'] as num?)?.toDouble() ?? 0;
    final notes = purchase['notes'] as String? ?? '';

    final itemsRows = items.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final item = entry.value;
      final productName = item['productName'] as String? ?? '';
      final hsnCode = item['hsnCode'] as String? ?? '-';
      final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
      final price = (item['purchasePrice'] as num?)?.toDouble() ?? 0;
      final gst = (item['gstRate'] as num?)?.toDouble() ?? 0;
      final disc = (item['discountPercent'] as num?)?.toDouble() ?? 0;
      final total = (item['total'] as num?)?.toDouble() ?? 0;
      return '''
        <tr>
          <td class="num">$idx</td>
          <td>${_escapeHtml(productName)}${hsnCode != '-' ? '<br><span class="td-hsn">HSN: $hsnCode</span>' : ''}</td>
          <td class="right">${_formatNumber(qty)}</td>
          <td class="right">₹${_formatNumber(price)}</td>
          <td class="right">${_formatNumber(gst)}%</td>
          <td class="right">${_formatNumber(disc)}%</td>
          <td class="right">₹${_formatNumber(total)}</td>
        </tr>''';
    }).join('\n');

    final totalQty = items.fold<double>(0, (sum, i) => sum + ((i['quantity'] as num?)?.toDouble() ?? 0));
    final amountInWords = _numberToWordsIndian(totalAmount.round());

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Purchase Order – $companyName #$purchaseNumber</title>
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

    .purchase {
      background: var(--white);
      max-width: 860px;
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
    .header-brand .gstin {
      margin-top: 6px;
      font-size: .72rem;
      opacity: .75;
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
    .header-badge .doc-title {
      font-family: var(--font-head);
      font-size: 1.55rem;
      letter-spacing: 4px;
      text-transform: uppercase;
    }
    .header-badge .doc-num {
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

    table.items {
      width: 100%;
      border-collapse: collapse;
      font-size: .82rem;
    }
    table.items thead tr {
      background: var(--accent);
      color: var(--white);
    }
    table.items thead th {
      padding: 11px 14px;
      font-size: .6rem;
      letter-spacing: 1.8px;
      text-transform: uppercase;
      font-weight: 700;
      text-align: left;
    }
    table.items thead th.num { text-align: center; width: 36px; }
    table.items thead th.right { text-align: right; }
    table.items tbody tr {
      border-bottom: 1px solid var(--border);
    }
    table.items tbody tr:nth-child(even) {
      background: var(--accent-lite);
    }
    table.items tbody td {
      padding: 10px 14px;
      color: var(--ink);
      vertical-align: top;
    }
    table.items tbody td.num { text-align: center; color: var(--muted); }
    table.items tbody td.right { text-align: right; }
    table.items tbody td .td-hsn { font-size: .7rem; color: var(--light-muted); }
    table.items tfoot tr {
      background: var(--accent-lite);
      border-top: 2px solid var(--accent);
    }
    table.items tfoot td {
      padding: 10px 14px;
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
    .amount-words span { font-weight: 700; color: var(--ink); }

    .bottom-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
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
    }

    .generated-line {
      text-align: center;
      font-size: .68rem;
      color: var(--light-muted);
      padding: 10px 0 4px;
    }

    @media print {
      body { background: white; padding: 0; }
      .purchase { box-shadow: none; border: none; }
    }
  </style>
</head>
<body>

<div class="purchase">

  <div class="header">
    <div class="header-brand">
      <h1>$companyName</h1>
      <address>
        ${_escapeHtml(companyAddress).replaceAll('\n', '<br>')}<br>
        $companyPhone &nbsp;·&nbsp; $companyEmail
      </address>
      <p class="gstin">GSTIN: $companyGstin</p>
    </div>
    <div class="header-badge">
      <p class="label">Document Type</p>
      <p class="doc-title">Purchase Order</p>
      <p class="doc-num">#$purchaseNumber</p>
    </div>
  </div>

  <div class="meta-strip">
    <div class="meta-cell">
      <p class="mc-label">Purchase Date</p>
      <p class="mc-value">$purchaseDate</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Purchase No.</p>
      <p class="mc-value">$purchaseNumber</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Invoice No.</p>
      <p class="mc-value">$invoiceNumber</p>
    </div>
    <div class="meta-cell">
      <p class="mc-label">Invoice Date</p>
      <p class="mc-value">$invoiceDate</p>
    </div>
  </div>

  <div class="parties">
    <div class="party-block">
      <p class="pb-label">Issued By</p>
      <p class="pb-name">$companyName</p>
      <address>
        ${_escapeHtml(companyAddress).replaceAll('\n', '<br>')}<br>
        $companyPhone
      </address>
      <p class="pb-pan">GSTIN: $companyGstin</p>
    </div>
    <div class="party-block">
      <p class="pb-label">Supplier (M/S)</p>
      <p class="pb-name">${_escapeHtml(supplierName)}</p>
      <address>
        ${supplierMobile.isNotEmpty ? 'Phone: $supplierMobile' : ''}
      </address>
      ${supplierGst.isNotEmpty ? '<p class="pb-pan">GSTIN: ${_escapeHtml(supplierGst)}</p>' : ''}
    </div>
  </div>

  <table class="items">
    <thead>
      <tr>
        <th class="num">SR</th>
        <th>Product Description</th>
        <th class="right">QTY</th>
        <th class="right">Rate</th>
        <th class="right">GST</th>
        <th class="right">Disc</th>
        <th class="right">Amount</th>
      </tr>
    </thead>
    <tbody>
      $itemsRows
    </tbody>
    <tfoot>
      <tr>
        <td colspan="2"></td>
        <td class="right"><strong>Total</strong></td>
        <td class="right">${_formatNumber(totalQty)}</td>
        <td colspan="2"></td>
        <td class="right">₹${_formatNumber(totalAmount)}</td>
      </tr>
    </tfoot>
  </table>

  <div class="amount-words">
    Amount in Words: &nbsp;<span>Rupees ${_escapeHtml(amountInWords)} Only</span>
  </div>

  <div class="bottom-grid">
    <div class="bg-block">
      <p class="bg-title">Summary</p>
      <div class="sum-row">
        <span class="sr-label">Subtotal</span>
        <span class="sr-val">₹${_formatNumber(subtotal)}</span>
      </div>
      <div class="sum-row">
        <span class="sr-label">GST Amount</span>
        <span class="sr-val">₹${_formatNumber(gstAmount)}</span>
      </div>
      <div class="sum-row">
        <span class="sr-label">Discount</span>
        <span class="sr-val">₹${_formatNumber(discountAmount)}</span>
      </div>
      <div class="sum-row">
        <span class="sr-label">Grand Total</span>
        <span class="sr-val">₹${_formatNumber(totalAmount)}</span>
      </div>
    </div>

    <div class="bg-block">
      <p class="bg-title">Notes</p>
      <p style="font-size:.82rem;color:var(--muted);line-height:1.7;">
        ${notes.isNotEmpty ? _escapeHtml(notes) : 'No additional notes.'}
      </p>
    </div>
  </div>

  <div class="footer">
    <div class="footer-terms">
      This is a computer generated purchase order.
    </div>
    <div class="footer-sign">
      <p class="fs-for">For, $companyName · GSTIN: $companyGstin</p>
      <p class="fs-line">Authorised Signatory</p>
    </div>
  </div>

  <p class="generated-line">
    $companyEmail &nbsp;·&nbsp; Generated: $purchaseDate
  </p>

</div>

</body>
</html>''';
  }

  static String _formatNumber(double amount) {
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

  static String _formatDateFull(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static String _numberToWordsIndian(int number) {
    if (number == 0) return 'Zero';
    const units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
      'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = [
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
