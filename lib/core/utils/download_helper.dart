import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart';

Future<void> downloadInvoiceHtml({
  required String htmlContent,
  required String fileName,
}) async {
  return downloadInvoiceHtmlImpl(htmlContent: htmlContent, fileName: fileName);
}
