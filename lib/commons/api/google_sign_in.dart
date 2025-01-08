import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();
  static Future<GoogleSignInAccount?> signIn() {
    try {
      return _googleSignIn.signIn().onError((error, stackTrace) {
        return Future.error(error == null ? 'Sign in failed' : error);
      });
    } catch (e) {
      return Future.error("Cannot sign in");
    }
  }
  static Future<GoogleSignInAccount?> signOut() {
    try {
      return _googleSignIn.signOut();
    } catch (e) {
      return Future.error("Cannot sign out");
    }
  }
}
