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
  String? authorities;

  User({
    this.id,
    required this.email,
    required this.firstRegistered,
    required this.timeStampWhenAuthorized,
    this.photoUrl,
    this.givenName,
    this.familyName,
    this.username,
    this.authorities,
  });

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $userTableName (
        id TEXT,
        givenName TEXT,
        familyName TEXT,
        username TEXT,
        email TEXT PRIMARY KEY,
        photoUrl TEXT,
        firstRegistered TEXT,
        authorities TEXT,
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
      'photoUrl': photoUrl,
      'firstRegistered':
          firstRegistered.toIso8601String(), // Assuming ISO8601 format
      'authorities': authorities ?? '',
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    User user = User(
      id: map['id'],
      givenName: map['givenName'],
      familyName: map['familyName'],
      username: map['username'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      firstRegistered: map['firstRegistered'] == null ? DateTime.now().toUtc() : DateTime.parse(map['firstRegistered']).toUtc(),
      timeStampWhenAuthorized: map['lastAccessed'] == null ? DateTime.now().toUtc() : DateTime.parse(map['lastAccessed']).toUtc(),
      authorities: map['authorities'] ?? '',
    );
    return user;
  }

  @override
  String toString() {
    return 'id: $id, email: $email, givenName: $givenName, familyName: $familyName username: $username, time: $timeStampWhenAuthorized, photoUrl: $photoUrl, authorities: $authorities';
  }

  static User clone(final User user) {
    return User(id: user.id, username: user.username, email: user.email, givenName: user.givenName, familyName: user.familyName, timeStampWhenAuthorized: user.timeStampWhenAuthorized, firstRegistered: user.firstRegistered, authorities: user.authorities);
  }
  
  String getFirstName() {
    return givenName == null ? 'Someone' : givenName!;
  }

    String getLastName() {
    return familyName == null ? 'Stranger' : familyName!;
  }

  List<String> getInitials() {
    return [givenName?[0] ?? '', familyName?[0] ?? ''];
  }

  String getFirstAndLastName() {
    // google gives first and last name together so have a validation
    return givenName != null && familyName == null ?  getFirstName() : '${getFirstName()} ${getLastName()}';
  }

  bool isUserAuthorized() {
    // todo: requires users to logout and login again to see the guest list
    return authorities!= null && authorities!.isNotEmpty && authorities!.contains('ROLE_USER');
  }
}
