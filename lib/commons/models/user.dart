import '../utils/constants.dart';
import '../utils/string_utils.dart';

class User {
  String? id;
  String? givenName;
  String? familyName;
  String? username;
  String email;
  String? photoUrl;
  DateTime firstRegistered;
  DateTime timeStampWhenAuthorized;

  User({
    this.id,
    required this.email,
    required this.firstRegistered,
    required this.timeStampWhenAuthorized,
    this.photoUrl,
    this.givenName,
    this.familyName,
    this.username,
  });

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $userTableName (
        id TEXT,
        givenName TEXT,
        familyName TEXT,
        username TEXT,
        email TEXT PRIMARY KEY,
        photo_url TEXT,
        firstRegistered TEXT
        lastAccessed TEXT
      )
    ''';
  }

  String get userNameForDisplay {
    return username == null ? getEmailWithoutDomain(email) : username!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'givenName': givenName,
      'familyName': familyName,
      'email': email,
      'photo_url': photoUrl,
      'firstRegistered':
          firstRegistered.toIso8601String(), // Assuming ISO8601 format
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    User user = User(
      id: map['id'],
      givenName: map['givenName'],
      familyName: map['familyName'],
      username: map['username'],
      email: map['email'],
      photoUrl: map['photo_url'],
      firstRegistered: map['firstRegistered'] == null ? DateTime.now() : DateTime.parse(map['firstRegistered']),
      timeStampWhenAuthorized: map['lastAccessed'] == null ? DateTime.now() : DateTime.parse(map['lastAccessed']),
    );
    return user;
  }

  @override
  String toString() {
    return 'id: $id, email: $email, givenName: $givenName, familyName: $familyName username: $username, time: $timeStampWhenAuthorized';
  }
  
  String getFirstName() {
    return givenName == null ? 'Someone' : givenName!;
  }

    String getLastName() {
    return familyName == null ? 'Stranger' : familyName!;
  }

  String getFirstAndLastName() {
    // google gives first and last name together so have a validation
    return givenName != null && familyName == null ?  getFirstName() : '${getFirstName()} ${getLastName()}';
  }
}
