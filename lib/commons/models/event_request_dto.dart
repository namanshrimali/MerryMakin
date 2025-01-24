import 'comment.dart';

class EventRequestDTO {
  String? id;
  String name;
  String imageUrl;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? description;
  String? location;
  int? spots; // number of spots available
  double? costPerSpot;
  String? countryCurrency;
  List<String> hostEmails; // email of hosts
  List<String>? attendeeEmails; // email of attendees
  DateTime createdAt;
  DateTime updatedAt;
  List<Comment>? comments;
  String? dressCode;
  String? foodSituation;
  bool isGuestListHidden;
  bool isGuestCountHidden;
  List<EventRequestDTO> subEvents;
  String? theme;
  String? effect;
  String? font;

  EventRequestDTO({
    this.id,
    required this.name,
    this.description,
    this.startDateTime,
    required this.hostEmails,
    this.attendeeEmails,
    this.endDateTime,
    this.spots,
    this.costPerSpot,
    this.countryCurrency,
    this.imageUrl = '',
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.comments,
    this.dressCode,
    this.foodSituation,
    this.isGuestListHidden = false,
    this.isGuestCountHidden = false,
    this.subEvents = const [],
    this.theme,
    this.effect,
    this.font,
  });

  @override
  String toString() {
    return '''Event{
      id: $id,
      name: $name,
      imageUrl: $imageUrl,
      startDateTime: $startDateTime,
      endDateTime: $endDateTime,
      description: $description,
      location: $location,
      spots: $spots,
      costPerSpot: $costPerSpot,
      countryCurrency: $countryCurrency,
      hosts: ${hostEmails.map((h) => h.toString()).toList()},
      guests: ${attendeeEmails?.map((a) => a.toString()).toList()},
      createdAt: $createdAt,
      updatedAt: $updatedAt,
      comments: ${comments?.map((c) => c.toString()).toList()},
      dressCode: $dressCode,
      foodSituation: $foodSituation,
      isGuestListHidden: $isGuestListHidden,
      isGuestCountHidden: $isGuestCountHidden,
      subEvents: ${subEvents.map((e) => e.toString()).toList()},
      theme: $theme,
      effect: $effect,
      font: $font
    }''';
  }

  // factory EventRequestDTO.fromMap(Map<String, dynamic> map) {
  //   return EventRequestDTO(
  //     id: map['id'],
  //     name: map['name'],
  //     imageUrl: map['imageUrl'],
  //     description: map['description'],
  //     location: map['location'],
  //     spots: map['spots'],
  //     costPerSpot: map['costPerSpot'],
  //     startDateTime: map['startDateTime'].toString().isEmpty ? null : DateTime.parse(map['startDateTime']),
  //     endDateTime: map['endDateTime'].toString().isEmpty ? null :  DateTime.parse(map['endDateTime']),
  //     createdAt: DateTime.parse(map['createdAt']),
  //     updatedAt: DateTime.parse(map['updatedAt']),
  //     countryCurrency: CountryCurrency.values[map['country_currency']],
  //     hosts: [],
  //     attendees: [],
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description ?? '',
      'location': location ?? '',
      'spots': spots ?? 0,
      'costPerSpot': costPerSpot ?? 0.0,
      'startDateTime': startDateTime?.toIso8601String() ?? '',
      'endDateTime': endDateTime?.toIso8601String() ?? '',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'countryCurrency': countryCurrency,
      'hostEmails': hostEmails,
      'attendeeEmails': attendeeEmails,
      'comments': comments?.map((c) => c.toMap()).toList(),
      'dressCode': dressCode ?? '',
      'foodSituation': foodSituation ?? '',
      'isGuestListHidden': isGuestListHidden ? 1 : 0,
      'isGuestCountHidden': isGuestCountHidden ? 1 : 0,
      'subEvents': subEvents.map((e) => e.toMap()).toList(),
      'theme': theme,
      'effect': effect,
      'font': font,
    };
  }
}
