class AccountBaseToBalance {
  int? id;
  int accountId;
  int balanceId;

  AccountBaseToBalance({
    this.id,
    required this.accountId,
    required this.balanceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'balanceId': balanceId,
    };
  }

  factory AccountBaseToBalance.fromMap(Map<String, dynamic> map) {
    return AccountBaseToBalance(
      id: map['id'],
      accountId: map['accountId'],
      balanceId: map['balanceId'],
    );
  }

  static String getCreateTableSchema(String tableName) {
    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER,
        balanceId INTEGER,
        UNIQUE(accountId, balanceId)
        )
    ''';
  }
}
