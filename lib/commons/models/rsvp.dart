import 'package:flutter/material.dart';

enum RSVPStatus {
  GOING,
  MAYBE,
  NOT_GOING,
  UNDECIDED;

  (IconData, String) getDisplayInfo() {
    switch (this) {
      case RSVPStatus.GOING:
        return (Icons.thumb_up, 'Going');
      case RSVPStatus.MAYBE:
        return (Icons.swap_horiz, 'Maybe');
      case RSVPStatus.NOT_GOING:
        return (Icons.thumb_down, 'Can\'t Go');
      case RSVPStatus.UNDECIDED:
        return (Icons.person, 'Undecided');
    }
  }

  static RSVPStatus? fromString(String? status) {
    if (status == null) {
      return null;
    }
    return RSVPStatus.values.firstWhere((element) => element.name == status);
  }
}
