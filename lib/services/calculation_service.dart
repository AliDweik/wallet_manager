
import 'package:wallet_manager/models/app_data.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/utlils/formatters.dart';

class CalculationService {
  static double getTotalMoney(AppData data) {
    return data.cashBalance + data.visaBalance;
  }

  static double getTotalMonthlyBillings(AppData data) {
    return data.monthlyBillings.fold(0, (sum, billing) => sum + billing.amount);
  }

  static double getDailyLimit(AppData data) {
    final totalMoney = getTotalMoney(data);
    final totalBillings = getTotalMonthlyBillings(data);
    final daysInMonth = Formatters.getDaysInCurrentMonth();

    final availableMoney = totalMoney - data.savings - totalBillings;

    if (daysInMonth <= 0) return 0;

    return availableMoney / daysInMonth;
  }

  static double getTodaySpent(AppData data) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return data.transactions
        .where((t) {
      final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
      return transactionDate == today && t.isExpense;
    })
        .fold(0, (sum, t) => sum + t.amount);
  }

  static double getTodayIncome(AppData data) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return data.transactions
        .where((t) {
      final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
      return transactionDate == today && t.isIncome;
    })
        .fold(0, (sum, t) => sum + t.amount);
  }

  static double getRemainingToday(AppData data) {
    final dailyLimit = getDailyLimit(data);
    final todaySpent = getTodaySpent(data);
    return dailyLimit - todaySpent;
  }

  static double getMonthSpent(AppData data) {
    final now = DateTime.now();
    return data.transactions
        .where((t) {
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.isExpense;
    })
        .fold(0, (sum, t) => sum + t.amount);
  }

  static double getMonthIncome(AppData data) {
    final now = DateTime.now();
    return data.transactions
        .where((t) {
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.isIncome;
    })
        .fold(0, (sum, t) => sum + t.amount);
  }

  static double getDailyLimitProgress(AppData data) {
    final dailyLimit = getDailyLimit(data);
    final todaySpent = getTodaySpent(data);

    if (dailyLimit <= 0) return 0;

    final progress = todaySpent / dailyLimit;
    return progress.clamp(0.0, 1.0);
  }

  static List<Transaction> getRecentTransactions(AppData data, {int limit = 10}) {
    final sorted = List<Transaction>.from(data.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(limit).toList();
  }

  static bool isSalaryDay(AppData data) {
    final now = DateTime.now();
    return now.day == data.salaryDay;
  }

  static bool shouldPromptArchive(AppData data) {
    final now = DateTime.now();
    final currentMonth = data.currentMonth;

    if (currentMonth == null) return false;

    final currentMonthParts = currentMonth.split('-');
    final storedYear = int.parse(currentMonthParts[0]);
    final storedMonth = int.parse(currentMonthParts[1]);

    if (now.year != storedYear || now.month != storedMonth) {
      return true;
    }

    if (isSalaryDay(data) && data.lastArchiveDate == null) {
      return true;
    }

    return false;
  }

  static double calculateNewBalance(double currentBalance, Transaction transaction) {
    if (transaction.isExpense) {
      return currentBalance - transaction.amount;
    } else {
      return currentBalance + transaction.amount;
    }
  }

  static Map<String, dynamic> getArchiveSummary(AppData data) {
    return {
      'cashBalance': data.cashBalance,
      'visaBalance': data.visaBalance,
      'totalMoney': getTotalMoney(data),
      'transactionsCount': data.transactions.length,
      'savings': data.savings,
      'totalBillings': getTotalMonthlyBillings(data),
      'salaryAmount': data.salaryAmount,
      'salaryAccount': data.salaryAccount,
      'monthSpent': getMonthSpent(data),
      'monthIncome': getMonthIncome(data),
    };
  }
}