import '../models/account_balance.dart';
import '../models/account_subtype.dart';
import '../models/account_type.dart';

class AccountBase {
  int? id;
  String? accountId;
  AccountBalance? balances;
  String mask;
  String name;
  String officialName;
  AccountType type;
  AccountSubtype subtype;

  AccountBase({
    this.id,
    this.accountId,
    this.balances,
    required this.mask,
    required this.name,
    required this.officialName,
    required this.type,
    required this.subtype,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'mask': mask,
      'name': name,
      'officialName': officialName,
      'type': type.index,
      'subtype': subtype.index,
    };
  }
  
  void setAccountTypeAndSubtypeFromAccountSubtype(final AccountSubtype accountSubtype) {
    this.subtype = accountSubtype;
    this.type = getAccountTypeFromSubtype(accountSubtype);
  }

  String toString() {
    return "'id': ${id}, 'accountId': ${accountId}, 'mask': ${mask}, 'name': ${name}, 'officialName': ${officialName}, 'type': ${type.index}, 'subtype': ${subtype.index}, 'balances' : ${balances?.toString()}";
  }

  factory AccountBase.fromMap(Map<String, dynamic> map) {
    return AccountBase(
      id: map['id'],
      accountId: map['accountId'],
      mask: map['mask'],
      name: map['name'],
      officialName: map['officialName'],
      type: AccountType.values[map['type']],
      subtype: AccountSubtype.values[map['subtype']],
    );
  }

  static String getCreateTableSchema(String tableName) {
    return '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId TEXT,
        mask TEXT,
        name TEXT,
        officialName TEXT,
        frequency INTEGER,
        type INTEGER,
        subtype INTEGER
        )
    ''';
  }
}
