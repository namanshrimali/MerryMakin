import 'rsvp.dart';
import 'comment.dart';

class RsvpSelection {
  final RSVPStatus rsvpStatus;
  final List<String> plusOnes;
  final Map<String, String>? questionnaireAnswers;
  final Comment? comment;

  RsvpSelection({
    required this.rsvpStatus,
    required this.plusOnes,
    this.questionnaireAnswers,
    this.comment,
  });

  factory RsvpSelection.fromMap(Map<String, dynamic> map) {
    return RsvpSelection(
      rsvpStatus: RSVPStatus.fromString(map['rsvpStatus']) ?? RSVPStatus.UNDECIDED,
      plusOnes: List<String>.from(map['plusOnes']),
      questionnaireAnswers: map['questionnaireAnswers'] != null ? Map<String, String>.from(map['questionnaireAnswers']) : null,
      comment: map['comment'] != null ? Comment.fromMap(map['comment']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rsvpStatus': rsvpStatus.name,
      'plusOnes': plusOnes,
      'questionnaireAnswers': questionnaireAnswers != null ? Map<String, String>.from(questionnaireAnswers!) : null,
      'comment': comment != null ? comment!.toMap() : null,
    };
  }
}
