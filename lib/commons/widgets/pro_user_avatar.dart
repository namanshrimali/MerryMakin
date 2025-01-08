import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/pro_text.dart';

class ProUserAvatar extends StatelessWidget {
  final User user;
  final double radius;
  const ProUserAvatar(
      {super.key,
      required this.user,
      this.radius = 12,});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(user.photoUrl ?? ''),
      onBackgroundImageError: (_, __) {},
      child: user.photoUrl == null
          ? ProText(
              '${user.getFirstName()[0]}${user.getLastName()[0]}',
              textStyle: const TextStyle(fontSize: 10),
            )
          : null,
    );
  }
}
