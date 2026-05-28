Future<void> downloadInvoiceHtmlImpl({
  required String htmlContent,
  required String fileName,
}) async {
  // No-op for non-web platforms. File saving is handled by PdfService.
}
