import 'dart:html' as html;

class ReportHelper {
  static Future<void> downloadReport(String filename, String htmlContent) async {
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = filename;
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<void> openReport(String htmlContent) async {
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }
}
