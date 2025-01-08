class AccountBalance {
  int? id;
  double available;
  double current;
  double limit;
  String isoCurrencyCode;
  String unofficialCurrencyCode;
  DateTime lastUpdatedDatetime;

  AccountBalance({
    this.id,
    required this.available,
    required this.current,
    required this.limit,
    required this.isoCurrencyCode,
    required this.unofficialCurrencyCode,
    required this.lastUpdatedDatetime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'available': available,
      'current': current,
      'account_limit': limit,
      'isoCurrencyCode': isoCurrencyCode,
      'unofficialCurrencyCode': unofficialCurrencyCode,
      'lastUpdatedDatetime':
          lastUpdatedDatetime.toIso8601String(), // Assuming ISO8601 format
    };
  }

  String toString() {
    return "'id': ${id}, 'available': ${available}, 'current': ${current}, 'account_limit': ${limit}, 'isoCurrencyCode': ${isoCurrencyCode}, 'unofficialCurrencyCode': ${unofficialCurrencyCode}, 'lastUpdatedDatetime': ${lastUpdatedDatetime},";
  }

  factory AccountBalance.fromMap(Map<String, dynamic> map) {
    return AccountBalance(
      id: map['id'],
      available: map['available'],
      current: map['current'],
      limit: map['account_limit'],
      isoCurrencyCode: map['isoCurrencyCode'],
      unofficialCurrencyCode: map['unofficialCurrencyCode'],
      lastUpdatedDatetime: DateTime.parse(map['lastUpdatedDatetime']),
    );
  }

  static String getCreateTableSchema(String tableName) {
    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        available REAL,
        current REAL,
        account_limit REAL,
        isoCurrencyCode TEXT,
        unofficialCurrencyCode TEXT,
        lastUpdatedDatetime TEXT
        )
    ''';
  }
}
