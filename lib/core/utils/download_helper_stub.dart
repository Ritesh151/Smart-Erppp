import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> downloadInvoiceHtmlImpl({
  required String htmlContent,
  required String fileName,
}) async {
  final directory = await getDownloadsDirectory() ??
      await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(htmlContent);
}
