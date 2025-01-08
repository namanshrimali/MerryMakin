import '../utils/constants.dart';

class GoalToTransaction {
  int? id;
  final int goalID;
  final int transactionID;

  GoalToTransaction(
    this.goalID,
    this.transactionID, {
    this.id,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalID': goalID,
      'transactionID': transactionID,
    };
  }
}
