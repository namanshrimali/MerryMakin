import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../pro_text.dart';

class ProStackedFab extends StatefulWidget {
  final List<ProStackedFabObject> fabObjects;
  final Widget? buttonText;
  final IconData? staticButtonIcon;
  final Color? buttonForegroundColor;
  final Color? buttonBackgroundColor;
  const ProStackedFab({super.key, required this.fabObjects, this.buttonText, this.staticButtonIcon, this.buttonForegroundColor, this.buttonBackgroundColor});

  @override
  State<ProStackedFab> createState() => _ProStackedFabState();
}

class _ProStackedFabState extends State<ProStackedFab> {
  bool isAddIcon = true;
  bool isBackdropVisible = false;

  @override
  Widget build(BuildContext context) {
    if (widget.fabObjects.length == 1) {
      return FloatingActionButton(
        onPressed: () {
          setState(() {
            isAddIcon = !isAddIcon;
            isBackdropVisible = false;
            widget.fabObjects[0].onTap();
          });
        },
        child: Icon(widget.fabObjects[0].icon),
      );
    }
    return Stack(
      children: [
        if (isBackdropVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isAddIcon = true;
                  isBackdropVisible = false;
                });
              },
              child: Container(
                color: Colors.white.withOpacity(1),
              ),
            ),
          ),
        Positioned(
          bottom: 16.0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1,
            child: widget.buttonText != null || widget.staticButtonIcon != null ? FloatingActionButton.extended(
              foregroundColor: widget.buttonForegroundColor,
              backgroundColor: widget.buttonBackgroundColor,
              label: Row(
                children: [
                  widget.staticButtonIcon == null ? (isAddIcon ? const Icon(Icons.add) : const Icon(Icons.close)) : Icon(widget.staticButtonIcon!),
                  const SizedBox(width: 8),
                  widget.buttonText!,
                ],
              ),
              onPressed: () {
                setState(() {
                  isAddIcon = !isAddIcon;
                  isBackdropVisible = !isBackdropVisible;
                },);}) :  FloatingActionButton(
              onPressed: () {
                setState(() {
                  isAddIcon = !isAddIcon;
                  isBackdropVisible = !isBackdropVisible;
                });
              },
              child:
                  isAddIcon ? const Icon(Icons.add) : const Icon(Icons.close),
            ),
          ),
        ),
        if (isBackdropVisible)
          Positioned(
            bottom: 80.0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...widget.fabObjects.map((fabObject) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 200,
                            child: ProText(
                              fabObject.actionButtonText != null ? fabObject.actionButtonText! : fabObject.title,
                              // hideOverflownDataWithEllipses: true,
                              maxLines: 6,
                            ),
                          ),
                          const SizedBox(
                            width: generalAppLevelPadding,
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                isAddIcon = !isAddIcon;
                                isBackdropVisible = false;
                                fabObject.onTap();
                              });
                            },
                            child: Icon(fabObject.icon),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}

class ProStackedFabObject {
  IconData icon;
  Function onTap;
  String title;
  String? actionButtonText;

  ProStackedFabObject(
      {required this.icon, required this.title, required this.onTap, this.actionButtonText});
}
