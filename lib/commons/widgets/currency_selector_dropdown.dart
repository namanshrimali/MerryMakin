import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_drop_down.dart';

import '../models/country_currency.dart';
import 'pro_text.dart';

class ProCurrencySelectorDropdown extends StatelessWidget {
  final CountryCurrency? initialCurrency;
  final Function(CountryCurrency) onChanged;
  final bool isBig;
  const ProCurrencySelectorDropdown({super.key, this.initialCurrency, required this.onChanged, this.isBig = false});

  @override
  Widget build(BuildContext context) {
    return ProDropDown(
            categorizedNameToItemMap: {
              "Suggested": [
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.UnitedStatesDollarUnitedStates,
                    child: ProText(
                      CountryCurrency.UnitedStatesDollarUnitedStates
                          .getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.UnitedStatesDollarUnitedStates
                        .getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.IndianRupee,
                    child: ProText(
                      CountryCurrency.IndianRupee.getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.IndianRupee.getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.BritishPoundSterlingUnitedKingdom,
                    child: ProText(
                      CountryCurrency.BritishPoundSterlingUnitedKingdom
                          .getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.BritishPoundSterlingUnitedKingdom
                        .getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.FrenchEuro,
                    child: ProText(
                      CountryCurrency.FrenchEuro.getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.FrenchEuro.getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.CanadianDollar,
                    child: ProText(
                      CountryCurrency.CanadianDollar.getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.CanadianDollar.getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
                ProDropDownItemObject(
                  DropdownMenuItem<CountryCurrency>(
                    value: CountryCurrency.AustralianDollar,
                    child: ProText(
                      CountryCurrency.AustralianDollar.getCurrencyName(),
                      hideOverflownDataWithEllipses: true,
                    ),
                  ),
                  trailing: ProText(
                    CountryCurrency.AustralianDollar.getCurrencyCode(),
                    hideOverflownDataWithEllipses: true,
                  ),
                ),
              ]
            },
            dropDownMenuItemList: CountryCurrency.values
                .map((countryCurrency) => ProDropDownItemObject(
                      DropdownMenuItem<CountryCurrency>(
                        value:  countryCurrency,
                        child: ProText(
                          isBig ? countryCurrency.getCurrencyName() : "${countryCurrency.getCurrencyCode()} ${countryCurrency.getCurrencySymbol()}",
                          hideOverflownDataWithEllipses: true,
                        ),
                      ),
                      trailing: ProText(
                        countryCurrency.getCurrencyCode(),
                        hideOverflownDataWithEllipses: true,
                      ),
                    ))
                .toList(),
            currentValueIndex:
                initialCurrency == null ? null : initialCurrency!.index,
            onChanged: (CountryCurrency newCurrency) {
              onChanged(newCurrency);
            },
            labelText: '',
          );
  }
}
