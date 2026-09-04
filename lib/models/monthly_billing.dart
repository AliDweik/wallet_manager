class MonthlyBilling {
  final String id;
  final String name;
  final double amount;
  final int dueDay;
  final String? iconName;

  MonthlyBilling({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDay,
    this.iconName,
  });

  factory MonthlyBilling.create({
    required String name,
    required double amount,
    required int dueDay,
    String? iconName,
  }) {
    return MonthlyBilling(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      dueDay: dueDay,
      iconName: iconName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDay': dueDay,
      'iconName': iconName,
    };
  }

  factory MonthlyBilling.fromJson(Map<String, dynamic> json) {
    return MonthlyBilling(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['dueDay'] as int,
      iconName: json['iconName'] as String?,
    );
  }

  MonthlyBilling copyWith({
    String? name,
    double? amount,
    int? dueDay,
    String? category,
    String? iconName,
  }) {
    return MonthlyBilling(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      iconName: iconName ?? this.iconName,
    );
  }

  String get dueDateLabel => 'Day $dueDay';
}

extension MonthlyBillingDisplay on MonthlyBilling {
  String get iconKey => iconName ?? 'receipt_long';
}