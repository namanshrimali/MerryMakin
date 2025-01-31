import 'package:google_sign_in/google_sign_in.dart';
import 'package:merrymakin/commons/models/auth_result.dart';

class GoogleSignInWeb {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '961357098517-go46phft6fo0dov8bdkaem3bp6pd1vfn.apps.googleusercontent.com',    scopes: [
      'email',
      'profile',
    ],
  );

  static Future<AuthResult?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        return null;
      }

      // Get auth details
      final GoogleSignInAuthentication auth = await account.authentication;
      
      return AuthResult(
        accessToken: auth.accessToken!,
        email: account.email,
        displayName: account.displayName ?? '',
        photoUrl: account.photoUrl,
      );
    } catch (error) {
      print('Google Sign In Error: $error');
      return null;
    }
  }

  static Future<AuthResult?> signInSilently() async {
    try {
      // Check if already signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) {
        return null;
      }

      final GoogleSignInAccount? account = await _googleSignIn.signInSilently(
        suppressErrors: true,
      );
      
      if (account == null) {
        return null;
      }

      // Get auth details
      final GoogleSignInAuthentication auth = await account.authentication;
      
      return AuthResult(
        accessToken: auth.accessToken!,
        email: account.email,
        displayName: account.displayName ?? '',
        photoUrl: account.photoUrl,
      );
    } catch (error) {
      print('Google Silent Sign In Error: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Google Sign Out Error: $error');
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      print('Google Sign In Check Error: $error');
      return false;
    }
  }
}
