import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_circular_progressbar_indicator.dart';

class ProListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isThreeLine;
  final double? showProgressBarWithProgress;
  final double? showCircularProgressBarWithProgress;
  final bool swipeForEditAndDelete;
  final Function? onSwipeLeft;
  final Function? onSwipeRight;
  final Function? confirmDismissLeftSwipe;
  final Function? confirmDismissRightSwipe;
  final GestureTapCallback? onTap;
  final bool dividerAtEnd;

  const ProListItem({
    required Key key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.swipeForEditAndDelete = true,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.confirmDismissLeftSwipe,
    this.confirmDismissRightSwipe,
    this.onTap,
    this.showProgressBarWithProgress,
    this.showCircularProgressBarWithProgress,
    this.isThreeLine = false,
    this.dividerAtEnd = false,
  }) : super(key: key);

  Widget? buildTrailingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (trailing != null) trailing!,
        if (showCircularProgressBarWithProgress != null)
          ProCircularProgressBarIndicator(
            value: showCircularProgressBarWithProgress!,
          ),
        const SizedBox(
          width: generalAppLevelPadding,
        ),
        // if (onTap != null)
        // const Icon(Icons.arrow_forward_ios, size: 12),
      ],
    );
  }

  Widget buildPlainListTile() {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      isThreeLine: isThreeLine,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: buildTrailingWidget(),
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }

  Widget buildSwipableListTile(BuildContext context) {
    return Dismissible(
        key: key!,
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd &&
              onSwipeRight != null) {
            // Swipe to edit
            onSwipeRight!();
          } else if (direction == DismissDirection.endToStart &&
              onSwipeLeft != null) {
            // Swipe to delete
            onSwipeLeft!();
          }
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd &&
              confirmDismissRightSwipe != null) {
            // Swipe to edit
            return confirmDismissRightSwipe!();
          } else if (direction == DismissDirection.endToStart &&
              confirmDismissLeftSwipe != null) {
            // Swipe to delete
            return confirmDismissLeftSwipe!();
          }
          return false;
        },
        background: Container(
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: generalAppLevelPadding),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: buildPlainListTile());
  }

  @override
  Widget build(BuildContext context) {
    Widget listWidget = swipeForEditAndDelete
        ? buildSwipableListTile(context)
        : buildPlainListTile();

    return Column(children: [
      // if (showProgressBarWithProgress != null)
      //   BarOfTheChart(
      //     fractionFilled: showProgressBarWithProgress!,
      //     isColumn: false,
      //     color: Theme.of(context).colorScheme.inversePrimary,
      //   ),
      listWidget,
      if (dividerAtEnd) const Divider(),
    ]);
  }
}
