import 'dart:html' as html;

Future<void> downloadInvoiceHtmlImpl({
  required String htmlContent,
  required String fileName,
}) async {
  final blob = html.Blob([htmlContent], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
