class TextBlastRequest {
  final String message;
  final List<String> rsvpStatuses;
  final String? gifUrl;

  TextBlastRequest({required this.message, required this.rsvpStatuses, this.gifUrl});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'rsvpStatuses': rsvpStatuses,
      'gifUrl': gifUrl,
    };
  }
}