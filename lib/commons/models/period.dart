enum Period {
  PT_1M,
  PT_5M,
  PT_1H,
  PT_1D,
  PT_30D,
  PT_1Y
}

extension PeriodExtension on Period {
  int getNumberOfMinutes() {
    switch (this) {
      case Period.PT_1M:
        return 1; // 1 minute
      case Period.PT_5M:
        return 5; // 5 minutes
      case Period.PT_1H:
        return 60; // 1 hour = 60 minutes
      case Period.PT_1D:
        return 1440; // 1 day = 24 hours = 1440 minutes
      case Period.PT_30D:
        return 30 * 1440; // 30 days = 30 * 1440 minutes
      case Period.PT_1Y:
        return 365 * 1440; // 1 year = 365 * 1440 minutes
      default:
        return 0;
    }
  }
  int getNumberOfDays() {
    switch (this) {
      case Period.PT_1M:
        return 0; // 1 minute doesn't correspond to a whole day
      case Period.PT_5M:
        return 0; // 5 minutes doesn't correspond to a whole day
      case Period.PT_1H:
        return 0; // 1 hour doesn't correspond to a whole day
      case Period.PT_1D:
        return 1; // 1 day
      case Period.PT_30D:
        return 30; // 30 days
      case Period.PT_1Y:
        return 365; // 1 year (non-leap year)
      default:
        return 0;
    }
  }
}