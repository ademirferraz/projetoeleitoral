import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportHelper {
  static Future<void> downloadReport(String filename, String htmlContent) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(htmlContent);
  }

  static Future<void> openReport(String htmlContent) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/relatorio_temp.html');
    await file.writeAsString(htmlContent);
  }
}
