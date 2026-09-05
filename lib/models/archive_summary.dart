class ArchiveSummary {
  final String fileName;
  final String monthYear;
  final double totalBalance;
  final double cashBalance;
  final double visaBalance;
  final double savings;
  final int transactionsCount;
  final DateTime? archivedAt;

  ArchiveSummary({
    required this.fileName,
    required this.monthYear,
    required this.totalBalance,
    required this.cashBalance,
    required this.visaBalance,
    required this.savings,
    required this.transactionsCount,
    this.archivedAt,
  });

  String get monthYearDisplay {
    try {
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return _formatMonthYear(date);
      }
    } catch (e) {
      // fallback
    }
    return monthYear;
  }

  String get totalBalanceDisplay => '\$${totalBalance.toStringAsFixed(2)}';
  String get cashBalanceDisplay => '\$${cashBalance.toStringAsFixed(2)}';
  String get visaBalanceDisplay => '\$${visaBalance.toStringAsFixed(2)}';
  String get savingsDisplay => '\$${savings.toStringAsFixed(2)}';

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}