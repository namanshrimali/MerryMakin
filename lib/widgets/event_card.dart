import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/widgets/pro_image_card.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';

import '../commons/models/user.dart';
import '../commons/utils/constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final double height;
  final double width;
  const EventCard(
      {super.key, required this.event, this.height = 300, this.width = 300});

  Widget buildImageCard(context) {
    return ProImageCard(
      imageUrl: event.imageUrl,
      imageHeight: height,
      width: width,
      title: event.name,
      radius: generalAppLevelPadding * 2,
      subtitle: ProText(
        event.formattedStartDateTime,
        // textStyle: const TextStyle(color: Colors.grey,),
        maxLines: 2,
      ),
      // thirdRow: _buildThirdRow(event),
      onTap: () {
        AppRouter.goToEventDetails(context, event.id!);
      },
    );
  }

  Widget buildStatusOverlay(context) {
    Icon icon;
    String? text = "";
    User user = AppFactory().cookiesService.locallyAvailableUserInfo!;
    if (event.isHostedByMe(user)) {
      icon = Icon(Icons.star, color: Colors.white);
      text = "Hosting";
    } else {
      RSVPStatus rsvpStatus = event.getRsvpStatusForUser(user);
      if (event.hasEventEnded()) {
        icon = Icon(rsvpStatus.getDisplayForPastInfo().$1);
        text = rsvpStatus.getDisplayForPastInfo().$2;
      } else {
        icon = Icon(rsvpStatus.getDisplayInfo().$1);
        text = rsvpStatus.getDisplayInfo().$2;
      }
    }
    return Positioned(
      top: generalAppLevelPadding,
      left: generalAppLevelPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
            ),
            child: Row(children: [
              IconButton(
                icon: icon,
                onPressed: () {},
              ),
              ProText(
                text,
                color: Colors.white,
              ),
              SizedBox(
                width: generalAppLevelPadding,
              )
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(children: [
          buildImageCard(context),
          buildStatusOverlay(context),
        ]),
        const Spacer(),
      ],
    );
  }

  Widget _buildThirdRow(Event event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ProText(
          'Hosts ',
          textStyle: TextStyle(
              // fontSize: 12,
              // color: Colors.grey,
              ),
        ),
        const SizedBox(width: 4),
        ...[
          for (final user in event.hosts)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ProUserAvatar(user: user),
            )
        ],
      ],
    );
  }
}
