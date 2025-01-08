import '../models/rsvp.dart';
import '../models/user.dart';

class Attendee {
  final User user;
  final RSVPStatus rsvpStatus;
  final DateTime rsvpDate;

  Attendee({
    required this.user,
    required this.rsvpStatus,
    required this.rsvpDate,
  });

  factory Attendee.fromMap(final Map<String, dynamic> map) {
    return Attendee(
      user: User.fromMap(map['user']),
      rsvpStatus: RSVPStatus.values.firstWhere((e) => e.name == map['rsvpStatus']),
      rsvpDate: DateTime.parse(map['rsvpDate']),
    );
  }
}
