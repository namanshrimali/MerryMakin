import './spryly_services.dart';

class UserRequestDTO {
  String? givenName;
  String? familyName;
  String? username;
  String? email;
  String? photoUrl;
  SprylyServices sprylyServices;

  UserRequestDTO({
    this.givenName,
    this.familyName,
    this.username,
    this.email,
    this.photoUrl,
    required this.sprylyServices,
  });

  Map<String, dynamic> toMap() {
    return {
      'givenName': givenName,
      'familyName': familyName,
      'userName': username,
      'email': email,
      'photo_url': photoUrl,
      'spryly_service': sprylyServices.name
    };
  }

  String toString() {
    return 'email: ${this.email}, givenName: ${this.givenName}, familyName: ${this.familyName} username: ${this.username}';
  }
}
