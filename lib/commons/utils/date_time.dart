import 'dart:math';

import 'package:intl/intl.dart';
import '../models/frequency.dart';

int compareDates(DateTime date1, DateTime date2) {
  if (date1.year < date2.year ||
      (date1.year == date2.year && date1.month < date2.month) ||
      (date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day < date2.day)) {
    return -1; // date1 is before date2
  } else if (date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day) {
    return 0; // date1 is the same as date2
  } else {
    return 1; // date1 is after date2
  }
}

int getDaysInMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month + 1, 0).day;
}

int getWeeksInMonth(DateTime dateTime) {
  int totalDaysInMonth = getDaysInMonth(dateTime);
  return ((totalDaysInMonth - 1) / 7).ceil();
}

int getTwoWeeksInMonth(DateTime dateTime) {
  int totalDaysInMonth = getDaysInMonth(dateTime);
  return (totalDaysInMonth / 14).floor();
}

String prettifyDate(DateTime dateTime) {
  return DateFormat.yMd().format(dateTime);
}

String prettifyDateWithoutYear(DateTime dateTime) {
  return '${getMonthName(dateTime.month)} ${dateTime.day}';
}

String prettifyDateInFull(DateTime dateTime) {
  return '${getShortMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
}

String prettifyDateWithTime(DateTime dateTime) {
  final hour = dateTime.hour == 12 || dateTime.hour == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'pm' : 'am';
  return '${prettifyDate(dateTime)} $hour:$minute$period';
}

String getPrettyRangeForWeekDate(DateTime weekDate) {
  DateTime startOfWeek =
      weekDate.subtract(Duration(days: weekDate.weekday - 1));
  DateTime endOfWeek = weekDate.add(Duration(days: 7 - weekDate.weekday));

  return getPrettyDateRanges(startOfWeek, endOfWeek);
}

String getPrettyDateRanges(DateTime startDate, DateTime endDate) {
  return startDate.month == endDate.month
      ? '${getMonthName(startDate.month).substring(0, 3)} ${startDate.day} - ${endDate.day}'
      : '${getMonthName(startDate.month).substring(0, 3)} ${startDate.day} - ${getMonthName(endDate.month).substring(0, 3)} ${endDate.day}';
}

String getShortMonthName(int monthIndex) {
  return getMonthName(monthIndex).substring(0, 3);
}

String getMonthName(int monthIndex) {
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[monthIndex - 1];
}

int getMonthsTillDate(DateTime selectedDate) {
  DateTime currentDate = DateTime.now();
  int totalMonths = (selectedDate.year - currentDate.year) * 12 +
      selectedDate.month -
      currentDate.month;

  if (selectedDate.day < currentDate.day) {
    totalMonths--;
  }
  return totalMonths;
}

bool isOnSameDay(DateTime date1, DateTime date2) {
  return date1.day == date2.day &&
      date1.month == date2.month &&
      date1.year == date2.year;
}

bool isOnSameMonth(DateTime date1, DateTime date2) {
  return date1.month == date2.month && date1.year == date2.year;
}

bool isOnSameYear(DateTime date1, DateTime date2) {
  return date1.year == date2.year;
}

DateTime getStartOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime getEndOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day + 1)
      .subtract(const Duration(milliseconds: 1));
}

DateTime getStartOfWeekDate(DateTime weekDate) {
  return getStartOfDay(weekDate.subtract(Duration(days: weekDate.weekday - 1)));
}

DateTime getEndOfWeekDate(DateTime weekDate) {
  return getEndOfDay(weekDate.add(Duration(days: 7 - weekDate.weekday)));
}

DateTime getWeekDateBeforeWeeks(DateTime weekDate, int numberOfWeeksAgo, {bool startOfTime = true, bool endOfTime = false}) {
  DateTime dateTime = weekDate.subtract(Duration(days: numberOfWeeksAgo * 7));
  return startOfTime? getStartOfDay(dateTime) : dateTime;
}

String getPrettyDateRangesForGivenFrequency(
    DateTime dateTime, Frequency frequency) {
  if (frequency == Frequency.weekly) {
    return getPrettyRangeForWeekDate(dateTime);
  } else if (frequency == Frequency.monthly) {
    return getMonthName(dateTime.month);
  } else {
    return dateTime.year.toString();
  }
}

Set<DateTime> getDateTimeForGivenFrequency(Frequency frequency, DateTime dateTime) {
  if (frequency == Frequency.weekly) {
    return {getStartOfWeekDate(dateTime), getEndOfWeekDate(dateTime)};
  } else if (frequency == Frequency.monthly) {
    return {getStartOfMonthDate(dateTime), getEndOfMonthDate(dateTime)};
  } else {
    return {getStartOfYearDate(dateTime), getEndOfYearDate(dateTime)};
  }
}

DateTime getLastDayOfMonth(int year, int month) {
  // Get the last day of the next month and subtract one day
  return DateTime(year, month + 1, 0);
}

DateTime getWeekDateBeforeGivenFrequency(DateTime dateTime, int xAgo, Frequency frequency) {
  if (frequency == Frequency.weekly) {
    return getWeekDateBeforeWeeks(dateTime, xAgo);
  } else if (frequency == Frequency.monthly) {
    return getWeekDateBeforeMonths(dateTime, xAgo);
  } else {
    return getWeekDateBeforeYears(dateTime, xAgo);
  }
}

DateTime getWeekDateBeforeMonths(DateTime weekDate, int numberOfMonthsAgo,) {
  // Subtract the given number of months
  int resultantMonth = weekDate.month - numberOfMonthsAgo;
  int resultantYear = weekDate.year;

  if (resultantMonth < 1) {
    resultantYear = resultantYear - 1;
    resultantMonth = 12 - resultantMonth.abs() % 12;
  }
  int resultantDay = min(weekDate.day, getLastDayOfMonth(resultantYear, resultantMonth).day);
  return
      DateTime(resultantYear, resultantMonth, resultantDay);
}

DateTime getWeekDateBeforeYears(DateTime weekDate, int numberOfYearsAgo, {bool startOfTime = true}) {
  // Subtract the given number of years
  DateTime resultDate =
      DateTime(weekDate.year - numberOfYearsAgo, weekDate.month, weekDate.day);

  return startOfTime ? getStartOfDay(resultDate) : resultDate;
}

DateTime getDateTimeAfterMonths(DateTime startDate, int numberOfMonths) {
  int year = startDate.year + (startDate.month + numberOfMonths) ~/ 12;
  int month = (startDate.month + numberOfMonths) % 12;
  int day = startDate.day;

  // Handling the case when the day is beyond the end of the month
  int daysInNewMonth = DateTime(year, month + 1).difference(DateTime(year, month)).inDays;
  day = day > daysInNewMonth ? daysInNewMonth : day;

  return DateTime(year, month, day);
}

DateTime getDateTimeAfterWeeks(DateTime startDate, int numberOfWeeks) {
  // Add the specified number of weeks to the start date
  return startDate.add(Duration(days: numberOfWeeks * 7));
}

DateTime getStartOfMonthDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}

DateTime getEndOfMonthDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month + 1, 0);
}

DateTime getStartOfYearDate(DateTime dateTime) {
  return DateTime(dateTime.year, 1, 1);
}

DateTime getEndOfYearDate(DateTime dateTime) {
  return DateTime(dateTime.year, 12, 31);
}

int getTotalWeeks(DateTime startDateTime, DateTime endDateTime) {
  final Duration difference = endDateTime.difference(startDateTime);
  final int totalDays = difference.inDays;
  return (totalDays / 7).ceil();
}

int getTotalMonths(DateTime startDateTime, DateTime endDateTime) {
  return (endDateTime.year - startDateTime.year) * 12 +
      endDateTime.month -
      startDateTime.month;
}

int getTotalYears(DateTime startDateTime, DateTime endDateTime) {
  return endDateTime.year - startDateTime.year;
}

int getDaysDifference(DateTime startDate, DateTime endDate) {
  Duration difference = endDate.difference(startDate);
  return difference.inDays;
}

DateTime getUpdatedDateTimeFromPageIndexAndFrequency(
    int index, Frequency frequency) {
  DateTime dateTime = DateTime.now();
  if (frequency == Frequency.weekly) {
    return getWeekDateBeforeWeeks(dateTime, index);
  } else if (frequency == Frequency.monthly) {
    return getWeekDateBeforeMonths(dateTime, index);
  } else {
    return getWeekDateBeforeYears(dateTime, index);
  }
}

DateTime getCurrentlyViewingDateTimeFromFrequencyAndPageNumber(
    Frequency currentFrequency, double pageNumber) {
  if (currentFrequency == Frequency.weekly) {
    return getWeekDateBeforeWeeks(DateTime.now(), pageNumber.toInt());
  } else if (currentFrequency == Frequency.monthly) {
    return getWeekDateBeforeMonths(DateTime.now(), pageNumber.toInt());
  }
  return getWeekDateBeforeYears(DateTime.now(), pageNumber.toInt());
}

bool isDateTimeInSamePeriodForGivenFrequency(Frequency frequency, DateTime dateTime,) {
  Set<DateTime> range = getDateTimeForGivenFrequency(frequency, dateTime,);
  return dateTime.isAfter(range.first) && dateTime.isBefore(range.last);
}

bool isDateTimeInSamePeriod(Set range, DateTime dateTime,) {
  return dateTime.isAfter(range.first) && dateTime.isBefore(range.last);
}

int getPageNumberBasedOnSelectedFrequency(DateTime currentlyViewingDateTime,
    DateTime baseDateTime, Frequency frequency) {
  if (frequency == Frequency.weekly) {
    return getTotalWeeks(currentlyViewingDateTime, baseDateTime);
  } else if (frequency == Frequency.monthly) {
    return getTotalMonths(currentlyViewingDateTime, baseDateTime);
  }
  return getTotalYears(currentlyViewingDateTime, baseDateTime);
}

String getTransactionPeriodText(DateTime dateTime, Frequency frequency) {
  if (frequency == Frequency.weekly) {
    return getPrettyRangeForWeekDate(dateTime);
  } else if (frequency == Frequency.monthly) {
    return getMonthName(dateTime.month);
  }
  return dateTime.year.toString();
}

String getRelativeTimePassed(DateTime dateTime) {
  final now = DateTime.now().toUtc();
  // if date is within 24 hours, return hours. If within 7 days, return days. If within 30 days, return weeks. If within 365 days, return months. If within 10 years, return years. 
  final differenceHours = now.difference(dateTime).inHours;
  final differenceDays = now.difference(dateTime).inDays;

  final differenceMinutes = now.difference(dateTime).inMinutes;

  if (differenceMinutes >= 0 && differenceMinutes <= 60) {
    return '${differenceMinutes}m';
  }

  if (differenceHours >= 0 && differenceHours <= 24) {
    return '${differenceHours}h';
  }
  if (differenceDays >= 0 && differenceDays <= 7) {
    return '${differenceDays}d';
  }
  if (differenceDays >= 7 && differenceDays <= 30) {
    return '${(differenceDays / 7).ceil()}w';
  }
  if (differenceDays >= 31 && differenceDays <= 365) {
    return '${(differenceDays / 30).ceil()}m';
  }
  return '${(differenceDays / 365).ceil()}y';
}
