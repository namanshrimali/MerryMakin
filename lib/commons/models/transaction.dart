import '../utils/date_time.dart';
import '../models/account_base.dart';
import '../models/country_currency.dart';
import '../models/goal.dart';
import '../models/transaction_categories.dart';
import '../models/frequency.dart';
import '../models/transaction_type.dart';

class MoneyTransaction {
  int? id;
  String title;
  double amount;
  Frequency frequency;
  TransactionType transactionType;
  TransactionCategory transactionCategory;
  CountryCurrency countryCurrency;
  DateTime time;
  Goal? goal;
  AccountBase? accountBase;

  MoneyTransaction(
      {this.id,
      required this.title,
      required this.amount,
      required this.frequency,
      required this.transactionType,
      required this.transactionCategory,
      required this.time,
      required this.countryCurrency,
      this.goal,
      this.accountBase});

  MoneyTransaction.withTransactionType({
    required this.transactionType,
    required this.countryCurrency,
    this.id,
    this.title = '',
    this.amount = 0.0,
    this.frequency = Frequency.once,
    this.transactionCategory = TransactionCategory.none,
    required this.time,
    this.goal,
    this.accountBase
  });

  MoneyTransaction updateWith(MoneyTransaction newTransaction) {
    amount = newTransaction.amount;
    title = newTransaction.title;
    frequency = newTransaction.frequency;
    transactionCategory = newTransaction.transactionCategory;
    time = newTransaction.time;
    countryCurrency = newTransaction.countryCurrency;
    goal = goal;
    accountBase = accountBase;
    return this;
  }

  double getMonthlyAmountByFrequency() {
    switch (frequency) {
      case Frequency.daily:
        return amount * getDaysInMonth(DateTime.now());
      case Frequency.weekly:
        return amount * getWeeksInMonth(DateTime.now());
      case Frequency.biWeekly:
        return amount * getTwoWeeksInMonth(DateTime.now());
      case Frequency.monthly:
        return amount;
      case Frequency.quarterly:
        return amount / 4;
      default:
        return amount / 12;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'country_currency': countryCurrency.index,
      'transaction_category': transactionCategory.index,
      'transaction_type': transactionType.index,
      'time': time.toIso8601String(), // Assuming ISO8601 format
      'frequency': frequency.index, // Store the index of the enum
    };
  }

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
    return MoneyTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      time: DateTime.parse(map['time']),
      countryCurrency: CountryCurrency.values[map['country_currency']],
      transactionCategory:
          TransactionCategory.values[map['transaction_category']],
      transactionType: TransactionType.values[map['transaction_type']],
      frequency:
          Frequency.values[map['frequency']], // Retrieve the enum from index
    );
  }

  static String getCreateTableSchema(String tableName) {
    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        frequency INTEGER,
        transaction_type INTEGER,
        transaction_category INTEGER,
        country_currency INTEGER,
        time TEXT
        )
    ''';
  }

  String toString() {
    return 'id: ${this.id}, title: ${this.title}, amount: ${this.amount}, frequency: ${this.frequency}, transactionType: ${this.transactionType}, transactionCategory: ${this.transactionCategory} time: ${this.time} country_currency: ${this.countryCurrency}';
  }
}
