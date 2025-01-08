enum Frequency {
  once,
  daily,
  weekly,
  biWeekly,
  monthly,
  quarterly,
  half_yearly,
  yearly,
  tillNow,
}

List<Frequency> getAllFrequencies() {
  return Frequency.values;
}

extension FrequencyExtensions on Frequency {
  String getFrequencyString() {
    switch (this) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.biWeekly:
        return 'Bi Weekly';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.quarterly:
        return 'Quaterly';
      case Frequency.yearly:
        return 'Yearly';
      case Frequency.tillNow:
        return 'ALL';
      default:
        return '';
    }
  }

  String getFrequencyShortString() {
    switch (this) {
      case Frequency.daily:
        return '/ day';
      case Frequency.weekly:
        return '/ wk';
      case Frequency.biWeekly:
        return '/ bi-wk';
      case Frequency.monthly:
        return '/ mo';
      case Frequency.quarterly:
        return '/ qtr';
      case Frequency.yearly:
        return '/ yr';
      default:
        return '';
    }
  }
}

Frequency getFrequencyFromString(String frequencyString) {
  switch (frequencyString) {
    case 'Daily':
      return Frequency.daily;
    case 'Weekly':
      return Frequency.weekly;
    case 'Bi Weekly':
      return Frequency.biWeekly;
    case 'Monthly':
      return Frequency.monthly;
    case 'Quarterly':
      return Frequency.quarterly;
    case 'Yearly':
      return Frequency.yearly;
    case 'ALL':
      return Frequency.tillNow;
    default:
      return Frequency
          .daily; // Default to a specific enum value for unmatched strings
  }
}
