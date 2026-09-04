import 'package:wallet_manager/models/monthly_billing.dart';
import 'package:wallet_manager/models/transaction.dart';

class AppData {
  double cashBalance;
  double visaBalance;

  double savings;
  List<MonthlyBilling> monthlyBillings;

  List<Transaction> transactions;

  double salaryAmount;
  int salaryDay;
  String salaryAccount;

  String? currentMonth;
  DateTime? lastArchiveDate;

  AppData({
    this.cashBalance = 0,
    this.visaBalance = 0,
    this.savings = 0,
    List<MonthlyBilling>? monthlyBillings,
    List<Transaction>? transactions,
    this.salaryAmount = 0,
    this.salaryDay = 28,
    this.salaryAccount = 'cash',
    this.currentMonth,
    this.lastArchiveDate,
  })  : monthlyBillings = monthlyBillings ?? [],
        transactions = transactions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'cashBalance': cashBalance,
      'visaBalance': visaBalance,
      'savings': savings,
      'monthlyBillings': monthlyBillings.map((b) => b.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'salaryAmount': salaryAmount,
      'salaryDay': salaryDay,
      'salaryAccount': salaryAccount,
      'currentMonth': currentMonth,
      'lastArchiveDate': lastArchiveDate?.toIso8601String(),
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      cashBalance: (json['cashBalance'] as num?)?.toDouble() ?? 0,
      visaBalance: (json['visaBalance'] as num?)?.toDouble() ?? 0,
      savings: (json['savings'] as num?)?.toDouble() ?? 0,
      monthlyBillings: (json['monthlyBillings'] as List?)
          ?.map((b) => MonthlyBilling.fromJson(b as Map<String, dynamic>))
          .toList() ?? [],
      transactions: (json['transactions'] as List?)
          ?.map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      salaryAmount: (json['salaryAmount'] as num?)?.toDouble() ?? 0,
      salaryDay: json['salaryDay'] as int? ?? 28,
      salaryAccount: json['salaryAccount'] as String? ?? 'cash',
      currentMonth: json['currentMonth'] as String?,
      lastArchiveDate: json['lastArchiveDate'] != null
          ? DateTime.parse(json['lastArchiveDate'] as String)
          : null,
    );
  }

  AppData copyWith({
    double? cashBalance,
    double? visaBalance,
    double? savings,
    List<MonthlyBilling>? monthlyBillings,
    List<Transaction>? transactions,
    double? salaryAmount,
    int? salaryDay,
    String? salaryAccount,
    String? currentMonth,
    DateTime? lastArchiveDate,
  }) {
    return AppData(
      cashBalance: cashBalance ?? this.cashBalance,
      visaBalance: visaBalance ?? this.visaBalance,
      savings: savings ?? this.savings,
      monthlyBillings: monthlyBillings ?? this.monthlyBillings,
      transactions: transactions ?? this.transactions,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      salaryDay: salaryDay ?? this.salaryDay,
      salaryAccount: salaryAccount ?? this.salaryAccount,
      currentMonth: currentMonth ?? this.currentMonth,
      lastArchiveDate: lastArchiveDate ?? this.lastArchiveDate,
    );
  }

  double get totalBalance => cashBalance + visaBalance;

  double get totalMonthlyBillings {
    return monthlyBillings.fold(0, (sum, billing) => sum + billing.amount);
  }

  int get totalTransactionsCount => transactions.length;

  void resetForNewMonth({bool keepBalances = true}) {
    transactions.clear();
    savings = 0;

    if (!keepBalances) {
      cashBalance = 0;
      visaBalance = 0;
    }

    final now = DateTime.now();
    currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    lastArchiveDate = now;
  }

  void addSalary() {
    if (salaryAccount == 'cash') {
      cashBalance += salaryAmount;
    } else {
      visaBalance += salaryAmount;
    }
  }
}