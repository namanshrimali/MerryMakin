import 'package:intl/intl.dart';
import '../utils/date_time.dart';
import '../utils/math.dart';
import '../models/chart_data.dart';
import '../models/country_currency.dart';
import '../models/frequency.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';

List<ChartData<DateTime, double>> getGroupedTransactionValuesForWeek(
    DateTime dateTime, List<MoneyTransaction> transactions) {
  final DateTime startOfWeekDate = getStartOfWeekDate(dateTime);
  return List.generate(7, (index) {
    DateTime weekDay = startOfWeekDate.add(Duration(days: index));
    var totalSum = 0.0;

    for (var i = 0; i < transactions.length; i++) {
      if (isOnSameDay(weekDay, transactions[i].time)) {
        totalSum += transactions[i].transactionType == TransactionType.income
            ? 0
            : transactions[i].amount;
      }
    }
    return ChartData(
        weekDay, totalSum, DateFormat.E().format(weekDay).substring(0, 3));
  });
}

List<ChartData<DateTime, double>> getTransactionValuesGroupedByDayForMonth(
    DateTime dateTime, List<MoneyTransaction> transactions) {
  final DateTime startOfMonthDate = getStartOfMonthDate(dateTime);
  return List.generate(getDaysInMonth(dateTime), (index) {
    DateTime curr_iterated_date = startOfMonthDate.add(Duration(days: index));
    var totalSumForDay = 0.0;
    for (var i = 0; i < transactions.length; i++) {
      if (isOnSameDay(curr_iterated_date, transactions[i].time)) {
        totalSumForDay += transactions[i].amount;
      }
    }
    return ChartData(
        curr_iterated_date, totalSumForDay, prettifyDate(curr_iterated_date));
  });
}

List<ChartData<DateTime, double>> getTransactionValuesGroupedByWeekForMonth(
    DateTime dateTime, List<MoneyTransaction> transactions) {
  DateTime startOfMonth = getStartOfMonthDate(dateTime);
  DateTime endOfMonth = getEndOfMonthDate(dateTime);

  List<ChartData<DateTime, double>> result = [];

  DateTime currentDate = startOfMonth;

  while (currentDate.isBefore(endOfMonth) ||
      currentDate.isAtSameMomentAs(endOfMonth)) {
    DateTime startOfWeekDate = currentDate;
    DateTime endOfWeekDate = getEndOfWeekDate(startOfWeekDate);

    if (endOfWeekDate.isAfter(endOfMonth)) {
      // Ensure endOfWeekDate does not go beyond the end of the month
      endOfWeekDate = endOfMonth;
    }

    var totalSum = 0.0;

    for (var i = 0; i < transactions.length; i++) {
      if ((transactions[i].time.isAfter(startOfWeekDate) ||
              transactions[i].time.isAtSameMomentAs(startOfWeekDate)) &&
          (transactions[i]
                  .time
                  .isBefore(endOfWeekDate.add(const Duration(days: 1))) ||
              transactions[i].time.isAtSameMomentAs(
                  endOfWeekDate.add(const Duration(days: 1))))) {
        totalSum += transactions[i].transactionType == TransactionType.income
            ? 0
            : transactions[i].transactionType == TransactionType.income
                ? 0
                : transactions[i].amount;
      }
    }

    result.add(ChartData(
      endOfWeekDate,
      totalSum,
      startOfWeekDate.day == endOfWeekDate.day
          ? '${startOfWeekDate.day}'
          : '${startOfWeekDate.day}-${endOfWeekDate.day}',
    ));

    currentDate = endOfWeekDate.add(const Duration(days: 1));
  }

  return result;
}

List<ChartData<DateTime, double>>
    getGroupedTransactionValuesGroupedByMonthForYear(
        DateTime dateTime, List<MoneyTransaction> transactions) {
  return List.generate(12, (monthIndex) {
    DateTime startOfMonth = DateTime(dateTime.year, monthIndex + 1, 1);
    DateTime endOfMonth = DateTime(dateTime.year, monthIndex + 2, 0);

    var totalSum = 0.0;

    for (var i = 0; i < transactions.length; i++) {
      if ((transactions[i].time.isAfter(startOfMonth) ||
              transactions[i].time.isAtSameMomentAs(startOfMonth)) &&
          (transactions[i].time.isBefore(endOfMonth) ||
              transactions[i].time.isAtSameMomentAs(endOfMonth))) {
        totalSum += transactions[i].transactionType == TransactionType.income
            ? 0
            : transactions[i].amount;
        transactions[i].amount;
      }
    }

    return ChartData(
      endOfMonth,
      totalSum,
      monthIndex % 2 == 0 ? DateFormat.MMM().format(startOfMonth) : '',
    );
  });
}

List<ChartData<DateTime, double>>
    getGroupedTransactionValuesGroupedByWeekForLastNWeeks(
        DateTime dateTime, List<MoneyTransaction> transactions, int weeks, CountryCurrency countryCurrency ) {
  final DateTime currentStartOfWeekDateTime = getStartOfWeekDate(dateTime);
  final DateTime currentEndOfWeekDateTime = getEndOfWeekDate(dateTime);
  return List.generate(weeks, (weekIndex) {
    DateTime startOfWeek =
        getWeekDateBeforeWeeks(currentStartOfWeekDateTime, weekIndex);
    DateTime endOfWeek =
        getWeekDateBeforeWeeks(currentEndOfWeekDateTime, weekIndex, startOfTime: false);

    var totalSum = 0.0;

    for (var i = 0; i < transactions.length; i++) {
      if ((transactions[i].time.isAfter(startOfWeek) ||
              transactions[i].time.isAtSameMomentAs(startOfWeek)) &&
          (transactions[i].time.isBefore(endOfWeek) ||
              transactions[i].time.isAtSameMomentAs(endOfWeek))) {
        totalSum += transactions[i].transactionType == TransactionType.income
            ? 0
            : transactions[i].amount;
        transactions[i].amount;
      }
    }

    return ChartData(
      endOfWeek,
      totalSum,
      startOfWeek.day == endOfWeek.day
          ? '${startOfWeek.day}'
          : '${startOfWeek.day}-${endOfWeek.day}',
      yToString:
          '${countryCurrency.getCurrencySymbol()}${formatNumber(totalSum)}',
    );
  }).reversed.toList();
}

List<ChartData<DateTime, double>>
    getGroupedTransactionValuesGroupedByMonthForLastNMonths(
        DateTime dateTime, List<MoneyTransaction> transactions, int months, CountryCurrency countryCurrency ) {
  final DateTime currentStartOfMonthDateTime = getStartOfMonthDate(dateTime);
  final DateTime currentEndOfMonthDateTime = getEndOfMonthDate(dateTime);
  return List.generate(months, (monthIndex) {
    DateTime startOfMonth =
        getWeekDateBeforeMonths(currentStartOfMonthDateTime, monthIndex);
    DateTime endOfMonth =
        getWeekDateBeforeMonths(currentEndOfMonthDateTime, monthIndex);

    var totalSum = 0.0;

    for (var i = 0; i < transactions.length; i++) {
      if ((transactions[i].time.isAfter(startOfMonth) ||
              transactions[i].time.isAtSameMomentAs(startOfMonth)) &&
          (transactions[i].time.isBefore(endOfMonth) ||
              transactions[i].time.isAtSameMomentAs(endOfMonth))) {
        totalSum += transactions[i].transactionType == TransactionType.income
            ? 0
            : transactions[i].amount;
        transactions[i].amount;
      }
    }

    return ChartData(
      endOfMonth,
      totalSum,
      DateFormat.MMM().format(startOfMonth),
      yToString:
          '${countryCurrency.getCurrencySymbol()}${formatNumber(totalSum)}',
    );
  }).reversed.toList();
}

List<ChartData<DateTime, double>> getGroupedDataByFrequency(DateTime dateTime,
    Frequency frequency, List<MoneyTransaction> transactions) {
  if (frequency == Frequency.weekly) {
    return getGroupedTransactionValuesForWeek(dateTime, transactions);
  } else if (frequency == Frequency.monthly) {
    return getTransactionValuesGroupedByDayForMonth(dateTime, transactions);
  }
  return getGroupedTransactionValuesGroupedByMonthForYear(
      dateTime, transactions);
}
