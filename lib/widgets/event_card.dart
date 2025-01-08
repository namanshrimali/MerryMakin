import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/widgets/pro_image_card.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ProImageCard(
      imageUrl: event.imageUrl,
      title: event.name,
      subtitle: event.formattedStartDateTime,
      thirdRow: _buildThirdRow(event),
      onTap: () {
        context.push('/${event.id}');
      },
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
