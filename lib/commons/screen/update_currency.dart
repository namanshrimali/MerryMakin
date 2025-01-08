import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/buttons/pro_primary_button.dart';
import '../widgets/pro_drop_down.dart';
import '../widgets/pro_text.dart';
import '../models/country_currency.dart';
import '../service/cookies_service.dart';

class UpdateCurrency extends StatefulWidget {
  final Function(CountryCurrency) onUpdate;
  final CookiesService cookiesService;
  const UpdateCurrency({super.key, required this.onUpdate, required this.cookiesService});
  static const routeNameForUpdateCurrency = '/update-currency';

  @override
  State<UpdateCurrency> createState() => _UpdateCurrencyState();
}

class _UpdateCurrencyState extends State<UpdateCurrency> {
  CountryCurrency? countryCurrency = CookiesService.locallyStoredCountryCurrency;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProDropDown(
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
                  )
                ]
              },
              dropDownMenuItemList: CountryCurrency.values
                  .map((countryCurrency) => ProDropDownItemObject(
                        DropdownMenuItem<CountryCurrency>(
                          value: countryCurrency,
                          child: ProText(
                            countryCurrency.getCurrencyName(),
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
                  countryCurrency == null ? null : countryCurrency!.index,
              onChanged: (CountryCurrency newCountryCurrency) {
                setState(() {
                  countryCurrency = newCountryCurrency;
                });
              },
              labelText: 'Currency'),
          SizedBox(
            height: generalAppLevelPadding,
          ),
          ProPrimaryButton(
            ProText("Update"),
            isBig: true,
            onPressed: countryCurrency == null
                ? null
                : () {
                    widget.cookiesService.setAppCountryCurrency(countryCurrency!);
                    // widget.onUpdate(countryCurrency!);
                    Navigator.of(context).pop(countryCurrency);
                  },
          ),
        ]);
  }
}
