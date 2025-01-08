import 'dart:math';

import 'package:flutter/material.dart';

double getTotalScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
}

double getBubbleChartHeight(BuildContext context) {
  return min(getTotalScreenHeight(context) * 0.5, 400);
}