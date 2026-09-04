enum TransactionType {
  expense,
  income
}

enum AccountType{
  cash,
  visa
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final AccountType account;
  final DateTime date;
  final String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.account,
    required this.date,
    this.note
  });

  factory Transaction.create({
    required double amount,
    required TransactionType type,
    required AccountType account,
    required DateTime date,
    String? note,
  }){
    return Transaction(
        id: DateTime
            .now()
            .microsecondsSinceEpoch
            .toString(),
        amount: amount,
        type: type,
        account: account,
        date: date,
        note: note
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'account': account.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      account: AccountType.values.firstWhere(
            (e) => e.name == json['account'],
        orElse: () => AccountType.cash,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Transaction copyWith({
    double? amount,
    TransactionType? type,
    AccountType? account,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      account: account ?? this.account,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }


  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  double get signedAmount => isExpense ? -amount : amount;
}

extension TransactionDisplay on Transaction {
  String get accountLabel {
    switch (account) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.visa:
        return 'Visa';
    }
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }
}