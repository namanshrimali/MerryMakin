import '../models/rsvp.dart';
import '../models/user.dart';

class Attendee {
  final User user;
  final RSVPStatus rsvpStatus;
  final DateTime rsvpDate;
  final List<String>? plusOnes;
  Map<String, String>? questionnaireAnswers;

  Attendee({
    required this.user,
    required this.rsvpStatus,
    required this.rsvpDate,
    this.plusOnes = const [],
    this.questionnaireAnswers,
  });

  factory Attendee.fromMap(final Map<String, dynamic> map) {
    return Attendee(
      user: User.fromMap(map['user']),
      rsvpStatus: RSVPStatus.values.firstWhere((e) => e.name == map['rsvpStatus']),
      rsvpDate: DateTime.parse(map['rsvpDate']),
      plusOnes: map['plusOnes'] != null ? List<String>.from(map['plusOnes']) : [],
      questionnaireAnswers: map['questionnaireAnswers'] != null ? Map<String, String>.from(map['questionnaireAnswers']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'rsvpStatus': rsvpStatus.name,
      'rsvpDate': rsvpDate.toIso8601String(),
      'plusOnes': plusOnes,
      'questionnaireAnswers': questionnaireAnswers,
    };
  }
}
