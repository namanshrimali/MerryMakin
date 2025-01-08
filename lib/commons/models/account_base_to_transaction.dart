import '../utils/constants.dart';

class AccountBaseToMoneyTransaction {
  int? id;
  int accountId;
  int transactionId;

  AccountBaseToMoneyTransaction({
    this.id,
    required this.accountId,
    required this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'transactionId': transactionId,
    };
  }

  factory AccountBaseToMoneyTransaction.fromMap(Map<String, dynamic> map) {
    return AccountBaseToMoneyTransaction(
      id: map['id'],
      accountId: map['accountId'],
      transactionId: map['transactionId'],
    );
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $accountBaseToTransactionsTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER,
        transactionId INTEGER
        )
    ''';
  }
}
