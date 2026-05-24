class ReportHelper {
  static Future<void> downloadReport(String filename, String htmlContent) async {
    throw UnsupportedError('Download não suportado nesta plataforma.');
  }

  static Future<void> openReport(String htmlContent) async {
    throw UnsupportedError('Abrir relatório não suportado nesta plataforma.');
  }
}
