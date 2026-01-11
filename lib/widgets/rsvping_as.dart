import 'package:flutter/material.dart';

import '../commons/models/user.dart';
import '../commons/utils/constants.dart';
import '../commons/widgets/cards/pro_card.dart';
import '../commons/widgets/pro_text.dart';
import '../commons/widgets/pro_user_avatar.dart';

class RSVPingAsWidget extends StatelessWidget {
  final User user;
  const RSVPingAsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProText('RSVPing as'),
            SizedBox(width: generalAppLevelPadding / 2),
            ProUserAvatar(
              user: user,
              radius: 20,
              canEdit: false,
            ),
            SizedBox(width: generalAppLevelPadding / 2),
            ProText(user.getFirstAndLastName()),
          ],
        ),
      ),
    );
  }
}