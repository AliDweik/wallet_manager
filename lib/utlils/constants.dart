class AppConstants {
  static const String activeDataFile = 'current_month.json';
  static const String archivePrefix = 'archive_';

  // Default values
  static const double defaultSalaryAmount = 0;
  static const int defaultSalaryDay = 28;
  static const String defaultSalaryAccount = 'cash';

  // Archive file naming
  static String getArchiveFileName(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final fileName = '${archivePrefix}${year}_$month.json';
    print('📦 Archive file name generated: $fileName');
    return fileName;
  }
}