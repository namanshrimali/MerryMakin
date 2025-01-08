import 'dart:math';

import '../utils/constants.dart';
import '../utils/date_time.dart';
import '../models/transaction.dart';

class Goal {
  int? id;
  String title;
  double totalGoalAmount;
  // double currentFulfilled;
  double incomeAllocationPercentage;
  DateTime targetDate;
  late DateTime createdAtDate;
  late List<MoneyTransaction> transactions;

  Goal({
    this.id,
    required this.title,
    required this.totalGoalAmount,
    // this.currentFulfilled = 0,
    required this.targetDate,
    createdAtDate,
    this.incomeAllocationPercentage = 0,
    List<MoneyTransaction>? transactions,
  }) {
    this.transactions = transactions ?? [];
    this.createdAtDate = createdAtDate ?? DateTime.now();
  }

  Goal updateWith(Goal newGoal) {
    title = newGoal.title;
    totalGoalAmount = newGoal.totalGoalAmount;
    // currentFulfilled = newGoal.currentFulfilled;
    targetDate = newGoal.targetDate;
    incomeAllocationPercentage = newGoal.incomeAllocationPercentage;
    return this;
  }

  static String goalToTransactionTableSchema() {
    return '''
          CREATE TABLE  IF NOT EXISTS $goalsToTransactionsTableName (
            goal_id INTEGER,
            transaction_id INTEGER,
            FOREIGN KEY (goal_id) REFERENCES $goalsTableName(id),
            FOREIGN KEY (transaction_id) REFERENCES $transactionsTableName(id),
            PRIMARY KEY (goal_id, transaction_id)
          )
        ''';
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $goalsTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        total_goal_amount REAL,
        current_fulfilled REAL,
        target_date TEXT,
        created_at_date TEXT,
        income_allocation_percentage REAL
      )
    ''';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'total_goal_amount': totalGoalAmount,
      'income_allocation_percentage': incomeAllocationPercentage,
      // 'current_fulfilled': currentFulfilled,
      'created_at_date': createdAtDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(), // Assuming ISO8601 format
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      incomeAllocationPercentage: map['income_allocation_percentage'],
      totalGoalAmount: map['total_goal_amount'],
      // currentFulfilled: map['current_fulfilled'],
      createdAtDate: DateTime.parse(map['created_at_date']),
      targetDate: DateTime.parse(map['target_date']), // Assuming ISO8601 format
    );
  }

  double get currentFulfilled {
    double total =  transactions.fold(0.0, (total, transaction) => total + transaction.amount);
    return total;
  }

  double get fulfilledWithinThisMonth {
    return transactions.where((transaction) => isOnSameMonth(DateTime.now(), transaction.time)).fold(0.0, (total, transaction) => total + transaction.amount);
  }

  double get monthlyAmountToBeSaved {
    return (totalGoalAmount - currentFulfilled)/max(getMonthsTillDate(targetDate), 1); 
  }

  bool isAccomplished() {
    return currentFulfilled >= totalGoalAmount;
  }
}
