class AuthResult {
  final String accessToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  AuthResult({
    required this.accessToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory AuthResult.fromMap(Map<String, dynamic> map) {
    return AuthResult(
      accessToken: map['accessToken'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }
} 