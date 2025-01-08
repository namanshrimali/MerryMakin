import '../utils/constants.dart';
import '../models/country_currency.dart';

class Cookie {
  final int? id;
  bool hasOnboarded;
  String? jwt;
  String? userId;
  CountryCurrency defaultCountryCurrency;
  final String preferences;

  Cookie({
    this.id,
    required this.hasOnboarded,
    this.jwt,
    this.userId,
    required this.preferences,
    required this.defaultCountryCurrency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jwt': jwt,
      'userId': userId,
      'hasOnboarded': hasOnboarded
          ? 1
          : 0, // SQLite doesn't have a boolean type, so we store as integer (0 or 1)
      'default_country_currency': defaultCountryCurrency.index,
      'preferences': preferences,
    };
  }

  factory Cookie.fromMap(Map<String, dynamic> map) {
    return Cookie(
      id: map['id'],
      defaultCountryCurrency: CountryCurrency.values[map['default_country_currency']],
      jwt: map['jwt'],
      userId: map['userId'],
      hasOnboarded: map['hasOnboarded'] == 1,
      preferences: map['preferences'],
    );
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $cookiesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hasOnboarded INTEGER,
        default_country_currency INTEGER,
        jwt TEXT,
        userId TEXT,
        preferences TEXT
      )
    ''';
  }
}
