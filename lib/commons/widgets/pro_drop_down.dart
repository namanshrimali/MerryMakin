import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_bottom_modal_sheet.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_list_view.dart';
import '../widgets/pro_text.dart';

class ProDropDown extends StatelessWidget {
  final List<ProDropDownItemObject> dropDownMenuItemList;
  final Map<String, List<ProDropDownItemObject>>? categorizedNameToItemMap;
  // final List<ProDropDownItemObject>? recentDropDownMenuItemList;
  final Function onChanged;
  final int? currentValueIndex;
  final String labelText;
  final bool showAll;
  const ProDropDown(
      {super.key,
      required this.dropDownMenuItemList,
      required this.onChanged,
      this.currentValueIndex,
      required this.labelText,
      this.categorizedNameToItemMap,
      this.showAll = true});

  List<Widget> getProListItemForDropdown(
      BuildContext context, List<ProDropDownItemObject> list) {
    return list.map((item) {
      return ProListItem(
        key: Key(item.dropdownMenuItem.value.toString()),
        swipeForEditAndDelete: false,
        title: item.dropdownMenuItem.child,
        leading: item.leading,
        trailing: item.trailing,
        onTap: () {
          onChanged.call(item.dropdownMenuItem.value);
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  List<Widget> getExtraDropDownMapToWidgetList(BuildContext context) {
    List<Widget> widgetList = [];
    if (categorizedNameToItemMap == null || categorizedNameToItemMap!.isEmpty) {
      return widgetList;
    }
    categorizedNameToItemMap!.forEach((key, value) {
      widgetList.add(
        ProText(key, weight: FontWeight.w600,),
      );

      widgetList.addAll(
        getProListItemForDropdown(context, value),
      );

      widgetList.add(
        SizedBox(
          height: generalAppLevelPadding,
        ),
      );
    });
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        openProBottomModalSheet(
            context,
            titleText: labelText,
            ProListView(
              height: 500,
              listItems: [
                ...getExtraDropDownMapToWidgetList(context),
                if (showAll) ProText("All", weight: FontWeight.w600,),
                if (showAll)
                  ...getProListItemForDropdown(context, dropDownMenuItemList),
              ],
            ));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: currentValueIndex != null || currentValueIndex == -1 ? labelText : null,
          contentPadding:
              const EdgeInsets.only(left: 8, right: 8, bottom: 18, top: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            currentValueIndex == null || currentValueIndex == -1
                ? ProText(
                    'Select $labelText',
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  )
                : dropDownMenuItemList[currentValueIndex!]
                    .dropdownMenuItem
                    .child,
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class ProDropDownItemObject {
  final DropdownMenuItem dropdownMenuItem;
  Widget? trailing;
  Widget? leading;
  ProDropDownItemObject(this.dropdownMenuItem, {this.leading, this.trailing});
}
