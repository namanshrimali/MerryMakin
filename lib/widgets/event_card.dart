import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/widgets/pro_image_card.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/config/router.dart';

import '../commons/utils/constants.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final double height;
  const EventCard({super.key, required this.event, this.height = 300});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProImageCard(
          imageUrl: event.imageUrl,
          imageHeight: height * 0.6,
          title: event.name,
          subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.access_time, size: generalAppLevelPadding),
            const SizedBox(width: generalAppLevelPadding / 2),
            Expanded(
              child: ProText(
                event.formattedStartDateTime,
                textStyle: const TextStyle(color: Colors.grey,),
                maxLines: 2,
              ),
            ),
          ],
        ),
        thirdRow: _buildThirdRow(event),
        onTap: () {
            AppRouter.goToEventDetails(context, event.id!);
          },
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildThirdRow(Event event) {
    return Row(
      children: [
        const ProText(
          'Hosts ',
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey,
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
