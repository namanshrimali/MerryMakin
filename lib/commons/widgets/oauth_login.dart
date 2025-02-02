import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_sign_in_with_apple.dart';
import '../providers/user_provider.dart';
import '../models/spryly_services.dart';
import '../api/google_sign_in.dart';
import '../service/user_service.dart';
import '../utils/string_utils.dart';
import 'pro_snackbar.dart';
import '../models/user_request_dto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../api/google_sign_in_web.dart';
// import '../api/apple_sign_in_web.dart';

class OAuthLogin extends ConsumerStatefulWidget {
  final VoidCallback? onPressedCallback;
  final UserService userService;
  final String sprylyService;
  const OAuthLogin(
      {super.key,
      this.onPressedCallback,
      required this.userService,
      required this.sprylyService});

  @override
  ConsumerState<OAuthLogin> createState() => _OAuthLoginState();
}

class _OAuthLoginState extends ConsumerState<OAuthLogin> {
  String couldNotReachToOurServers =
      "Could not reach to our servers. You can sign in later in the app.";
  String couldNotReachAppleServer =
      "Could not reach to Apple servers. You can sign in later in the app.";
  // bool isLoading = false;
  Future _signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      UserRequestDTO userRequestDTO = UserRequestDTO(
          givenName: credential.givenName,
          familyName: credential.familyName,
          email: credential.email,
          sprylyServices: SprylyServices.MerryMakin);

      widget.userService
          .addOrUpdateUser(userRequestDTO, credential.authorizationCode,
              widget.sprylyService,
              isApple: true)
          .then((user) {
        if (user != null) {
          ref.read(userProvider.notifier).login(user);
        }
        showSnackBar(
          context,
          user == null
              ? couldNotReachToOurServers
              : 'Welcome ${user.userNameForDisplay}',
        );
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      }).onError((error, stackTrace) {
        showSnackBar(context, error.toString());
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future _signInWithGoogle() async {
    if (kIsWeb) {
      final result = await GoogleSignInWeb.signIn();
      if (result != null) {
        UserRequestDTO userRequestDTO = UserRequestDTO(
          givenName: result.displayName,
          username: getEmailWithoutDomain(result.email),
          email: result.email,
          photoUrl: result.photoUrl,
          sprylyServices: SprylyServices.MerryMakin,
        );

        try {
          final user = await widget.userService.addOrUpdateUser(
            userRequestDTO,
            result.accessToken,
            widget.sprylyService,
          );

          if (user != null) {
            ref.read(userProvider.notifier).login(user);
          }

          showSnackBar(
            context,
            user == null
                ? couldNotReachToOurServers
                : 'Welcome ${user.userNameForDisplay}',
          );
        } catch (error) {
          showSnackBar(context, error.toString());
        }
      }
    } else {
      GoogleSignInApi.signIn().then((result) {
        if (result != null) {
          result.authentication.then((googleSignInAuthentication) {
            if (googleSignInAuthentication.accessToken == null) {
              showSnackBar(context, "No access token received from google");
              return;
            }
            UserRequestDTO userRequestDTO = UserRequestDTO(
                givenName: result.displayName,
                username: getEmailWithoutDomain(result.email),
                email: result.email,
                photoUrl: result.photoUrl,
                sprylyServices: SprylyServices.MerryMakin);
            widget.userService
                .addOrUpdateUser(
                    userRequestDTO,
                    googleSignInAuthentication.accessToken!,
                    widget.sprylyService)
                .then((user) {
              if (user != null) {
                ref.read(userProvider.notifier).login(user);
              }
              showSnackBar(
                  context,
                  user == null
                      ? couldNotReachToOurServers
                      : 'Welcome ${user.userNameForDisplay}');
              if (widget.onPressedCallback != null) {
                widget.onPressedCallback!();
              }
            }).onError((error, stackTrace) {
              showSnackBar(context, error.toString());
              if (widget.onPressedCallback != null) {
                widget.onPressedCallback!();
              }
            });
          });
        }
      }).onError((error, stackTrace) {
        showSnackBar(
          context,
          error.toString(),
        );
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _signInWithGoogle,
          icon: SvgPicture.asset(
            'lib/commons/assets/google_sign_in_button.svg',
          ),
        ),
        if (!kIsWeb && Platform.isIOS)
          ProSignInWithAppleButton(
            onPressed: _signInWithApple,
          ),
      ],
    );

    // return Platform.isAndroid
    //     ? IconButton(
    //         onPressed: _signInWithGoogle,
    //         icon: SvgPicture.asset(
    //           'lib/commons/assets/google_sign_in_button.svg',
    //         ),
    //       )
    //     : ProSignInWithAppleButton(onPressed: _signInWithApple);
  }
}
