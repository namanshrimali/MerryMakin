import 'package:flutter/material.dart';
import 'pro_text.dart';

class ProScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final double? toolbarHeight;
  final bool centerTitle;
  final bool resizeToAvoidBottomInset;
  final Color? appBarBackgroundColor;
  final Widget? customTitle;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double maxWidth;

  const ProScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.toolbarHeight,
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
    this.appBarBackgroundColor,
    this.customTitle,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.maxWidth = 1280,
  });

  @override
  Widget build(BuildContext context) {
    final hasAppBar = title != null ||
        customTitle != null ||
        actions != null ||
        leading != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar ??
          (hasAppBar
              ? AppBar(
                  backgroundColor: appBarBackgroundColor,
                  title: customTitle ??
                      (title != null
                          ? ProText(
                              title!,
                              textStyle: Theme.of(context).textTheme.titleLarge,
                            )
                          : null),
                  centerTitle: centerTitle,
                  actions: actions,
                  leading: leading,
                  automaticallyImplyLeading: automaticallyImplyLeading,
                  toolbarHeight: toolbarHeight,
                )
              : null),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
