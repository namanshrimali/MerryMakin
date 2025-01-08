import 'package:flutter/material.dart';
import '../models/country_currency.dart';

import '../utils/math.dart';
import 'pro_text.dart';

class CurrentPercentageAllocation extends StatelessWidget {
  final double totalAmount;
  final double totalAllocatedPercentage;
  final CountryCurrency countryCurrency;
  const CurrentPercentageAllocation({
    super.key,
    required this.totalAllocatedPercentage,
    required this.totalAmount, required this.countryCurrency,
  });

  @override
  Widget build(BuildContext context) {
    double remainingPercentage = 100 - totalAllocatedPercentage;

    return Column(
      children: [
        ProText(
          '${formatNumber(totalAllocatedPercentage)}% of 100%',
        ),
        remainingPercentage < 0
            ? ProText(
                '${formatNumber(totalAllocatedPercentage - 100)}% over ${countryCurrency.getCurrencySymbol()}$totalAmount',
                color: Theme.of(context).colorScheme.error,
              )
            : ProText(
                '${formatNumber(100 - totalAllocatedPercentage)}% left of ${countryCurrency.getCurrencySymbol()}$totalAmount',
              )
      ],
    );
  }
}
