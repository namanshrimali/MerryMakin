// Number format
import 'package:flutter/material.dart';

const int uptoDecimals = 2;

// Padding
const double generalAppLevelPadding = 16;

// Animation transitions
const double quickAnimationDurationInSeconds = 1;

// Icon Size
const double normalIconSize = 30;

// Text Size
const double displayLargeHeight = 64;
const double displayMediumHeight = 52;
const double displaySmallHeight = 44;

const RoundedRectangleBorder roundedRectangleBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)));

const RoundedRectangleBorder bottomRoundedRectangleBorder =
    RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
  topLeft: Radius.zero,
  topRight: Radius.zero,
  bottomLeft: Radius.circular(32.0),
  bottomRight: Radius.circular(32.0),
));

const String accountsTableName = 'accounts_table';
const String accountsBaseToBalanceTableName = 'account_base_to_balance_table';
const String accountsBalanceTableName = 'account_balance_table';
const String goalsTableName = 'goals_table';
const String transactionsTableName = 'money_transactions';
const String userTableName = 'user';
const String goalsToTransactionsTableName = 'goal_to_transaction';
const String accountBaseToTransactionsTableName = 'account_to_transaction';
const String cookiesTableName = 'cookies_table';
const String eventTableName = 'event_table';
const String eventToHostTableName = 'event_to_host';
const String eventToAttendeeTableName = 'event_to_attendee';

const String deleteGoalConfirmationText =
    'Deleting goal is irreversible and all the contributions made towards it would be deleted as well. Are you sure you want to delete?';
const String defaultDeleteConfirmationText =
    'Are you sure you want to delete this item?';

const String contactUsEmail = "summonnaman@gmail.com";