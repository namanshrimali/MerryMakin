// import 'dart:async';
// import 'dart:html' as html;
// import 'dart:convert';
// import 'dart:math';
// import 'package:merrymakin/commons/models/auth_result.dart';

// class AppleSignInWeb {
//   static const String _clientId = 'com.namanshrimali.merrymakin';  // e.g., com.your.app.id
//   static const String _redirectUri = 'YOUR_REDIRECT_URI';  // Must be registered with Apple
//   static const List<String> _scopes = ['email', 'name'];

//   static Future<AuthResult?> signIn() async {
//     try {
//       // Generate random state for security
//       final state = _generateRandomString(32);
      
//       // Store state in session storage for verification
//       html.window.sessionStorage['apple_auth_state'] = state;

//       // Construct Apple authorization URL
//       final authUrl = Uri.https('appleid.apple.com', '/auth/authorize', {
//         'response_type': 'code id_token',
//         'client_id': _clientId,
//         'redirect_uri': _redirectUri,
//         'state': state,
//         'scope': _scopes.join(' '),
//         'response_mode': 'form_post',
//       });

//       // Open Apple sign-in in a popup
//       final width = 500;
//       final height = 600;
//       final left = (html.window.screen?.width ?? 1024) ~/ 2 - width ~/ 2;
//       final top = (html.window.screen?.height ?? 768) ~/ 2 - height ~/ 2;

//       final popup = html.window.open(
//         authUrl.toString(),
//         'apple_sign_in',
//         'width=$width,height=$height,left=$left,top=$top,toolbar=no,location=no',
//       );

//       // Listen for the response
//       final completer = Completer<AuthResult?>();
      
//       html.window.onMessage.listen((event) {
//         if (event.origin == Uri.parse(_redirectUri).origin) {
//           final data = json.decode(event.data);
          
//           // Verify state
//           if (data['state'] != state) {
//             completer.complete(null);
//             return;
//           }

//           if (data['error'] != null) {
//             completer.complete(null);
//             return;
//           }

//           // Parse user info from ID token
//           final userInfo = _parseIdToken(data['id_token']);
          
//           completer.complete(AuthResult(
//             accessToken: data['code'],
//             email: userInfo['email'] ?? '',
//             displayName: [
//               userInfo['firstName'],
//               userInfo['lastName']
//             ].where((s) => s != null).join(' '),
//             photoUrl: null,
//           ));

//           popup.close();
//         }
//       });

//       return await completer.future;
//     } catch (e) {
//       print('Apple Sign In Error: $e');
//       return null;
//     }
//   }

//   static String _generateRandomString(int length) {
//     const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     final random = Random.secure();
//     return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
//   }

//   static Map<String, dynamic> _parseIdToken(String idToken) {
//     try {
//       final parts = idToken.split('.');
//       if (parts.length != 3) {
//         return {};
//       }

//       final payload = parts[1];
//       final normalized = base64Url.normalize(payload);
//       final resp = utf8.decode(base64Url.decode(normalized));
//       return json.decode(resp);
//     } catch (e) {
//       print('Error parsing ID token: $e');
//       return {};
//     }
//   }
// } 