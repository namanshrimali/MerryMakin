import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart';
import 'buttons/pro_stacked_fab.dart';
import '../widgets/pro_text.dart';

// Please send icon data in ProBaseScreenObject if withBottonNavigationBar = true.
// I don't have assertions in code :)

class ProBaseScreen extends ConsumerStatefulWidget {
  final List<ProBaseScreenObject> baseScreenObjectList;
  final bool withBottonNavigationBar;
  final bool withFloatingActionButton;
  const ProBaseScreen(
      {super.key,
      required this.baseScreenObjectList,
      this.withBottonNavigationBar = false,
      this.withFloatingActionButton = false});

  @override
  ConsumerState<ProBaseScreen> createState() => _ProBaseScreenState();
}

class _ProBaseScreenState extends ConsumerState<ProBaseScreen> {
  // int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _selectPage(int index) {
    ref.read(pageIndexProvider.notifier).gotoNewPage(index);
    // setState(() {
    //   _selectedPageIndex = index;
    // });
  }

  Widget? buildBottomNavigationBar() {
    return widget.withBottonNavigationBar
        ? BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed, // Set type to fixed
            selectedItemColor: Theme.of(context).primaryColor,
            currentIndex: ref.read(pageIndexProvider),
            onTap: _selectPage,
            items: [
              ...widget.baseScreenObjectList
                  .map((screenObject) => BottomNavigationBarItem(
                      icon: Icon(
                        screenObject.icon,
                        size: 20,
                      ),
                      tooltip: screenObject.title,
                      label: screenObject.title)),
            ],
          )
        : null;
  }

  Widget? buildFloatingActionButtonForScreen() {
    if (!widget.withFloatingActionButton ||
        widget.baseScreenObjectList[ref.read(pageIndexProvider)].fabObjects
            .isEmpty) {
      return null;
    }

    return ProStackedFab(
        fabObjects: widget
            .baseScreenObjectList[ref.read(pageIndexProvider)].fabObjects);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pageIndexProvider);
    final Widget appBarTitle =
        ProText(widget.baseScreenObjectList[ref.read(pageIndexProvider)].title);
    final PreferredSizeWidget appBarWidget = Platform.isIOS && false
        // ignore: dead_code
        ? CupertinoNavigationBar(
            middle: appBarTitle,
          )
        : AppBar(
            // title: appBarTitle,
            actions: widget.baseScreenObjectList[ref.read(pageIndexProvider)].appBarActions,
          ) as PreferredSizeWidget;
    return Platform.isIOS && false
        // TODO update all reusable widgets to work with cupertino style
        // ignore: dead_code
        ? CupertinoPageScaffold(
            navigationBar: appBarWidget as ObstructingPreferredSizeWidget,
            child:
                widget.baseScreenObjectList[ref.read(pageIndexProvider)].widget,
          )
        : Scaffold(
            appBar: appBarWidget,
            body: Padding(
                padding: const EdgeInsets.only(
                    left: generalAppLevelPadding,
                    right: generalAppLevelPadding),
                child: widget
                    .baseScreenObjectList[ref.read(pageIndexProvider)].widget),
            bottomNavigationBar: buildBottomNavigationBar(),
            floatingActionButton: buildFloatingActionButtonForScreen(),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
  }
}

class ProBaseScreenObject {
  final Widget widget;
  final List<Widget>? appBarActions;
  final IconData? icon;
  final String title;
  final List<ProStackedFabObject> fabObjects;

  ProBaseScreenObject(
    this.fabObjects, {
    required this.widget,
    this.icon,
    required this.title,
    this.appBarActions,
  });
}
