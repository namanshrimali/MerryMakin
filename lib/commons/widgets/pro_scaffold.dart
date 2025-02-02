import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'buttons/pro_outlined_button.dart';
import 'pro_text.dart';
import 'package:url_launcher/url_launcher.dart';
// Conditional import for web platform detection
import '../utils/platform_web.dart'
    if (dart.library.io) '../utils/platform_stub.dart' as platform;

class ProScaffold extends StatefulWidget {
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
  final String? iosAppLink;
  final String? androidAppLink;

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
    this.iosAppLink,
    this.androidAppLink,
  });

  @override
  State<ProScaffold> createState() => _ProScaffoldState();
}

class _ProScaffoldState extends State<ProScaffold> {
  bool _showAppBanner = true;

  Future<void> _launchAppStore(BuildContext context) async {
    if (!kIsWeb) return;

    String? storeUrl;
    bool isIOSBrowser = false;

    // Only run platform check if we're on web
    if (kIsWeb) {
      isIOSBrowser = platform.isIOS();
      print("isIOSBrowser: $isIOSBrowser");
    }

    storeUrl = isIOSBrowser ? widget.iosAppLink : widget.androidAppLink;

    if (storeUrl != null) {
      final Uri url = Uri.parse(storeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showSnackBar(context, "Failed to open app");
      }
    }
  }

  Widget _buildAppBanner(BuildContext context) {
    if (!kIsWeb ||
        (widget.iosAppLink == null && widget.androidAppLink == null ||
            !_showAppBanner)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _showAppBanner = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded)),
              const SizedBox(width: 8),
              const ProText(
                'Experience MerryMakin in our mobile app',
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
            ProOutlinedButton(
              onPressed: () => _launchAppStore(context),
              child: const ProText('Open'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAppBar = widget.title != null ||
        widget.customTitle != null ||
        widget.actions != null ||
        widget.leading != null;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.appBar ??
          (hasAppBar
              ? AppBar(
                  backgroundColor: widget.appBarBackgroundColor,
                  title: widget.customTitle ??
                      (widget.title != null
                          ? ProText(
                              widget.title!,
                              textStyle: Theme.of(context).textTheme.titleLarge,
                            )
                          : null),
                  centerTitle: widget.centerTitle,
                  actions: widget.actions,
                  leading: widget.leading,
                  automaticallyImplyLeading: widget.automaticallyImplyLeading,
                  toolbarHeight: widget.toolbarHeight,
                )
              : null),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
          ),
          child: Column(
            children: [
              _buildAppBanner(context),
              Expanded(child: widget.body),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
