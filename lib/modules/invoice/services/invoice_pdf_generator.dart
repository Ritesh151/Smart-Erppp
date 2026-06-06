import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';

class InvoicePdfGenerator {
  static const _companyName = 'Siddhivinayak Enterprise';
  static const _companyAddress =
      '114/80, Laxmanji Ravtaji Compound, Mandi Kuva Road,\nO/S Shahpur Gate, Near Municipal Quarter,\nKazipur Dariyapur, Ahmedabad \u2013 380004';
  static const _companyPhone = '9974884444';
  static const _companyEmail = 'siddhivinayak0330@gmail.com';
  static const _companyGstin = '24BCTPC3372F1ZO';
  static const _accentColor = PdfColor.fromInt(0xFF2B4C7E);
  static const _accentLite = PdfColor.fromInt(0xFFDCE8F8);
  static const _white88 = PdfColor.fromInt(0xE0FFFFFF);
  static const _white82 = PdfColor.fromInt(0xD1FFFFFF);
  static const _white70 = PdfColor.fromInt(0xB3FFFFFF);
  static const _white85 = PdfColor.fromInt(0xD9FFFFFF);
  static const _white60 = PdfColor.fromInt(0x99FFFFFF);
  static const _white75 = PdfColor.fromInt(0xBFFFFFFF);
  static const _white65 = PdfColor.fromInt(0xA6FFFFFF);

  static Future<Uint8List> generate({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(invoice),
          _buildMetaStrip(invoice),
          _buildParties(invoice),
          pw.SizedBox(height: 12),
          _buildItemsTable(items, invoice),
          _buildAmountInWords(invoice),
          _buildInternalCharges(invoice),
          _buildPaymentTerms(invoice),
          _buildBottomGrid(invoice),
          _buildFooter(invoice),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(InvoiceModel invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: pw.BoxDecoration(
        color: _accentColor,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(4),
          topRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_companyName,
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
                pw.SizedBox(height: 4),
                pw.Text(_companyAddress,
                    style: pw.TextStyle(
                        fontSize: 8, color: _white88)),
                pw.SizedBox(height: 3),
                pw.Text('$_companyPhone  \u00b7  $_companyEmail',
                    style: pw.TextStyle(
                        fontSize: 7.5, color: _white82)),
                pw.SizedBox(height: 4),
                pw.Text('GSTIN: $_companyGstin',
                    style: pw.TextStyle(
                        fontSize: 7, color: _white70)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('TAX INVOICE',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white)),
              pw.SizedBox(height: 4),
              pw.Text('#${invoice.invoiceNumber}',
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: _white85,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetaStrip(InvoiceModel invoice) {
    final invoiceDate = _formatDateFull(invoice.invoiceDate);
    final dueDate = _formatDateFull(invoice.dueDate);
    final buyerStatus = (invoice.customerGst != null &&
            invoice.customerGst!.trim().isNotEmpty)
        ? 'Registered'
        : 'URP';

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        children: [
          _metaCell('Date', invoiceDate),
          _metaCell('Invoice No.', invoice.invoiceNumber),
          _metaCell('Due Date', dueDate),
          _metaCell('Buyer Status', buyerStatus),
        ],
      ),
    );
  }

  static pw.Widget _metaCell(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            right: pw.BorderSide(color: PdfColors.grey300),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label.toUpperCase(),
                style: pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5)),
            pw.SizedBox(height: 3),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildParties(InvoiceModel invoice) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ISSUED BY',
                      style: pw.TextStyle(
                          fontSize: 6,
                          color: _accentColor,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2)),
                  pw.SizedBox(height: 6),
                  pw.Text(_companyName,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                  pw.Text(_companyAddress,
                      style: pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey700)),
                  pw.SizedBox(height: 3),
                  pw.Text(_companyPhone,
                      style: pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey700)),
                  pw.SizedBox(height: 4),
                  pw.Text('GSTIN: $_companyGstin',
                      style: pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey500)),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILLED TO',
                      style: pw.TextStyle(
                          fontSize: 6,
                          color: _accentColor,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2)),
                  pw.SizedBox(height: 6),
                  pw.Text(invoice.customerName,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  if (invoice.customerAddress != null &&
                      invoice.customerAddress!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(invoice.customerAddress!,
                        style: pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey700)),
                  ],
                  if (invoice.customerGst != null &&
                      invoice.customerGst!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text('GSTIN: ${invoice.customerGst!}',
                        style: pw.TextStyle(
                            fontSize: 7, color: PdfColors.grey500)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(
      List<InvoiceItemModel> items, InvoiceModel invoice) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _accentColor),
        children: [
          _th('SR', textAlign: pw.TextAlign.center),
          _th('Image', textAlign: pw.TextAlign.center),
          _th('Product'),
          _th('QTY', textAlign: pw.TextAlign.right),
          _th('Rate', textAlign: pw.TextAlign.right),
          _th('Amount', textAlign: pw.TextAlign.right),
        ],
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isEven = i.isEven;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? _accentLite : PdfColors.white,
          ),
          children: [
            _td((i + 1).toString(), textAlign: pw.TextAlign.center),
            _tdImage(item.imagePath),
            _tdProduct(item),
            _td(item.quantity.toInt().toString(),
                textAlign: pw.TextAlign.right),
            _td('Rs. ${_formatNumber(item.unitPrice)}',
                textAlign: pw.TextAlign.right),
            _td('Rs. ${_formatNumber(item.amount)}',
                textAlign: pw.TextAlign.right),
          ],
        ),
      );
    }

    final totalQty = items.fold<int>(0, (s, i) => s + i.quantity.toInt());
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _accentLite),
        children: [
          pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text('')),
          pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text('')),
          _td('Total', fontWeight: pw.FontWeight.bold),
          _td(totalQty.toString(),
              textAlign: pw.TextAlign.right,
              fontWeight: pw.FontWeight.bold),
          _td('Rs. ${_formatNumber(invoice.subtotal)}',
              textAlign: pw.TextAlign.right,
              fontWeight: pw.FontWeight.bold),
          _td('Rs. ${_formatNumber(invoice.subtotal)}',
              textAlign: pw.TextAlign.right,
              fontWeight: pw.FontWeight.bold),
        ],
      ),
    );

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: const pw.BorderSide(color: PdfColors.grey300),
          bottom: const pw.BorderSide(color: PdfColors.grey300),
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(32),
          1: const pw.FixedColumnWidth(48),
          2: const pw.FlexColumnWidth(),
          3: const pw.FixedColumnWidth(50),
          4: const pw.FixedColumnWidth(70),
          5: const pw.FixedColumnWidth(70),
        },
        children: rows,
      ),
    );
  }

  static pw.Widget _th(String text,
      {pw.TextAlign textAlign = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              letterSpacing: 1.2),
          textAlign: textAlign),
    );
  }

  static pw.Widget _td(String text,
      {pw.TextAlign textAlign = pw.TextAlign.left,
      pw.FontWeight? fontWeight}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: fontWeight ?? pw.FontWeight.normal,
          ),
          textAlign: textAlign),
    );
  }

  static pw.Widget _tdProduct(InvoiceItemModel item) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(item.productName,
              style: pw.TextStyle(
                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
          if (item.hsnCode != null && item.hsnCode!.trim().isNotEmpty)
            pw.Text('HSN: ${item.hsnCode!}',
                style:
                    pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  static pw.Widget _tdImage(String? imagePath) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      alignment: pw.Alignment.center,
      child: _buildProductThumbnail(imagePath),
    );
  }

  static pw.Widget _buildProductThumbnail(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return _noImagePlaceholder();
    }
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return _noImagePlaceholder();
      final bytes = file.readAsBytesSync();
      return pw.Image(pw.MemoryImage(bytes),
          width: 36, height: 36, fit: pw.BoxFit.cover);
    } catch (_) {
      return _noImagePlaceholder();
    }
  }

  static pw.Widget _noImagePlaceholder() {
    return pw.Container(
      width: 36,
      height: 36,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Center(
        child: pw.Text('N/A',
            style:
                pw.TextStyle(fontSize: 6, color: PdfColors.grey400)),
      ),
    );
  }

  static pw.Widget _buildAmountInWords(InvoiceModel invoice) {
    final roundedTotal = invoice.totalAmount.roundToDouble();
    final words = _numberToWordsIndian(roundedTotal.toInt());

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF9F4E8),
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
          top: pw.BorderSide(
              color: PdfColor.fromInt(0xFFD4B87A), width: 0.5),
        ),
      ),
      child: pw.Row(children: [
        pw.Text('Amount in Words: ',
            style:
                pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text('Rupees $words Only',
            style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black)),
      ]),
    );
  }

  static pw.Widget _buildPaymentTerms(InvoiceModel invoice) {
    final hasPaymentTerms = invoice.paymentDays > 0 || invoice.paymentMonths > 0;
    final hasDescription = invoice.paymentTermDescription != null &&
        invoice.paymentTermDescription!.trim().isNotEmpty;
    final hasCustomNotes = invoice.customPaymentNotes != null &&
        invoice.customPaymentNotes!.trim().isNotEmpty;
    if (!hasPaymentTerms && !hasCustomNotes) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PAYMENT TERMS',
              style: pw.TextStyle(
                  fontSize: 6,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentColor,
                  letterSpacing: 1.5)),
          pw.SizedBox(height: 6),
          if (hasDescription)
            pw.Text(invoice.paymentTermDescription!,
                style: pw.TextStyle(
                    fontSize: 7.5, color: PdfColors.black, height: 1.6)),
          if (hasCustomNotes) ...[
            if (hasDescription) pw.SizedBox(height: 4),
            pw.Text('Additional Payment Conditions:',
                style: pw.TextStyle(
                    fontSize: 6.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600)),
            pw.SizedBox(height: 2),
            pw.Text(invoice.customPaymentNotes!,
                style: pw.TextStyle(
                    fontSize: 7.5, color: PdfColors.black, height: 1.5)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInternalCharges(InvoiceModel invoice) {
    final charges = invoice.internalCharges;
    if (charges.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ADDITIONAL CHARGES',
              style: pw.TextStyle(
                  fontSize: 6,
                  fontWeight: pw.FontWeight.bold,
                  color: _accentColor,
                  letterSpacing: 1.5)),
          pw.SizedBox(height: 6),
          ...charges.map((charge) {
            final items = <pw.Widget>[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(charge.chargeName,
                          style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black)),
                      if (charge.chargeDescription != null &&
                          charge.chargeDescription!.trim().isNotEmpty)
                        pw.Text(charge.chargeDescription!,
                            style: pw.TextStyle(
                                fontSize: 6.5,
                                color: PdfColors.grey500)),
                    ],
                  ),
                  pw.Text('Rs. ${_formatNumber(charge.chargeAmount)}',
                      style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black)),
                ],
              ),
              pw.SizedBox(height: 4),
            ];
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: items,
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildBottomGrid(InvoiceModel invoice) {
    final totalTax = invoice.taxAmount;
    final cgst = totalTax / 2;
    final sgst = totalTax / 2;
    const igst = 0.0;
    final discount = invoice.discountAmount;
    final internalChargesTotal = invoice.internalChargesTotal;
    final grandTotal = invoice.totalAmount;
    final roundedGrandTotal = grandTotal.roundToDouble();
    final roundOff = roundedGrandTotal - grandTotal;

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey300),
          right: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _gridTitle('GST BREAKUP'),
                  pw.SizedBox(height: 6),
                  _gstRow('CGST @ 9%', cgst),
                  _gstRow('SGST @ 9%', sgst),
                  _gstRow('IGST @ 18%', igst),
                  _gstRow('Round Off', roundOff),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _gridTitle('BANK DETAILS'),
                  pw.SizedBox(height: 6),
                  _bankRow('Bank', invoice.bankName ?? 'Indian Bank'),
                  _bankRow('Branch', invoice.branchName ?? 'Usmanpura'),
                  _bankRow('IFSC', invoice.ifscCode ?? 'IDIB000A666'),
                  _bankRow(
                      'A/C No.', invoice.accountNumber ?? '7648102905'),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(14),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _gridTitle('SUMMARY'),
                  pw.SizedBox(height: 6),
                  _sumRow('Subtotal', invoice.subtotal),
                  _sumRow('CGST @ 9%', cgst),
                  _sumRow('SGST @ 9%', sgst),
                  if (internalChargesTotal > 0) _sumRow('Internal Charges', internalChargesTotal),
                  if (discount > 0) _sumRow('Discount', -discount),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  _sumRow('Grand Total', roundedGrandTotal,
                      isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _gridTitle(String title) {
    return pw.Text(title,
        style: pw.TextStyle(
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
            color: _accentColor,
            letterSpacing: 1.5));
  }

  static pw.Widget _gstRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
          pw.Text('Rs. ${_formatNumber(amount)}',
              style: pw.TextStyle(
                  fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _bankRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(children: [
        pw.Text('$label: ',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
      ]),
    );
  }

  static pw.Widget _sumRow(String label, double amount,
      {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: isTotal ? 9 : 7.5,
                  fontWeight:
                      isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: isTotal ? _accentColor : PdfColors.grey600)),
          pw.Text('Rs. ${_formatNumber(amount)}',
              style: pw.TextStyle(
                  fontSize: isTotal ? 9 : 7.5,
                  fontWeight: isTotal
                      ? pw.FontWeight.bold
                      : pw.FontWeight.bold,
                  color: isTotal ? _accentColor : PdfColors.black)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(InvoiceModel invoice) {
    String getTerms() {
      final terms = invoice.termsAndConditions;
      if (terms != null && terms.trim().isNotEmpty) {
        return terms;
      }
      return 'Goods once sold will not be taken back or exchanged.\n'
          'Goods despatched at buyer\'s risk.\n'
          '18% interest will be charged on overdue payment.\n'
          'Subject to Ahmedabad jurisdiction.';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: pw.BoxDecoration(
        color: _accentColor,
        borderRadius: const pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(4),
          bottomRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('TERMS & CONDITIONS',
                    style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                        color: _white60,
                        letterSpacing: 1.5)),
                pw.SizedBox(height: 3),
                pw.Text(getTerms(),
                    style: pw.TextStyle(
                        fontSize: 7, color: _white82)),
              ],
            ),
          ),
          pw.SizedBox(width: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('For, $_companyName',
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: _white65,
                      fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 4),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColor.fromInt(0x80FFFFFF),
                        width: 0.8),
                  ),
                ),
                child: pw.Text('Authorised Signatory',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: _white75,
                        fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDateFull(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
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
