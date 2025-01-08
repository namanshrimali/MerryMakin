import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_text.dart';

Future openProBottomModalSheet(BuildContext context, Widget childWidget,
    {bool isFullScreen = false, String? titleText}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: isFullScreen
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0))),
      builder: (_) {
        return ProBottomModalSheetContent(
          titleText: titleText,
          isFullScreen: isFullScreen,
          child: childWidget,
        );
      });
}

void closeProBottomModalSheet(BuildContext context) {
  Navigator.of(context).pop();
}

class ProBottomModalSheetContent extends StatelessWidget {
  final Widget child;
  final bool isFullScreen;
  final String? titleText;
  const ProBottomModalSheetContent(
      {super.key,
      required this.child,
      required this.isFullScreen,
      this.titleText});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: generalAppLevelPadding,
              right: generalAppLevelPadding,
              top: generalAppLevelPadding,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(children: <Widget>[
            GestureDetector(
              onVerticalDragDown: (_) {}, // Allow swipe gesture
              child: Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: generalAppLevelPadding),
            if (titleText != null)
              ProText(
                titleText!,
                textStyle: Theme.of(context).textTheme.headlineSmall,
              ),
            if (titleText != null)
              const SizedBox(height: generalAppLevelPadding),
            isFullScreen
                ? SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: child,
                  )
                : child,
          ]),
        ),
      ),
    );
  }
}
