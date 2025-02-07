import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user.dart';
import '../service/user_service.dart';
import '../themes/pro_themes.dart';
import 'buttons/pro_primary_button.dart';
import 'pro_text.dart';
import 'pro_theme_effects.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/share_image_generator.dart';
import 'dart:ui' as ui;
import 'pro_carousel.dart';

class ProShareSheet extends StatefulWidget {
  final String message;
  final String link;
  final UserService userService;
  final Function onShare;
  final Event event;
  final ProThemeType? themeType;
  final ProEffectType? effectType;

  String get sanitizedMessage => message.replaceAllMapped(
    RegExp(r'[_*\[\]()~`>#+=|{}-]'),
    (match) => '\\${match.group(0)}'
  );

  const ProShareSheet({
    Key? key,
    required this.message,
    required this.link,
    required this.userService,
    required this.onShare,
    required this.event,
    this.themeType,
    this.effectType,
  }) : super(key: key);

  @override
  State<ProShareSheet> createState() => _ProShareSheetState();
}

class _ProShareSheetState extends State<ProShareSheet> {
  List<User> selectedUsers = [];
  List<User> allUsers = [];
  bool isLoading = true;
  ui.Image? shareImage;
  ui.Image? primaryShareImage;
  int currentPage = 0;
  ui.Image? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _generateShareImages();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      allUsers = await widget.userService.getAllUsers();
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateShareImages() async {
    // Generate surface color background image
    final surfaceImage = await ShareImageGenerator.generateEventShareImage(
      event: widget.event,
      themeType: widget.themeType ?? ProThemeType.classic,
      effectType: widget.effectType ?? ProEffectType.none,
      size: const Size(1080, 1920),
      usePrimaryBackground: false,
    );

    // Generate primary color background image
    final primaryImage = await ShareImageGenerator.generateEventShareImage(
      event: widget.event,
      themeType: widget.themeType ?? ProThemeType.classic,
      effectType: widget.effectType ?? ProEffectType.none,
      size: const Size(1080, 1920),
      usePrimaryBackground: true,
    );

    setState(() {
      shareImage = surfaceImage;
      primaryShareImage = primaryImage;
      selectedImage = shareImage;

    });
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
    widget.onShare();
  }

  Future<void> _shareCurrentView() async {
    switch (currentPage) {
      case 0: // Link view
      //   Share.share(
      //     'Join me at ${widget.sanitizedMessage}!\nRSVP here: ${widget.link}',
      //     subject: 'RSVP to ${widget.sanitizedMessage}',
      //   );
      //   break;
      case 1: // Surface background image
        await _shareImage(shareImage);
        break;
      case 2: // Primary background image
        await _shareImage(primaryShareImage);
        break;
    }
  }

  Future<void> _shareImage(ui.Image? image) async {
    if (image == null) return;

    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/event_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.sanitizedMessage} ${widget.link}',
        subject: 'RSVP to ${widget.sanitizedMessage}',
      );
    } catch (e) {
      Share.share(
        '${widget.sanitizedMessage} ${widget.link}',
        subject: 'RSVP to ${widget.sanitizedMessage}',
      );
    }
  }

  Widget _buildSelectableImage(ui.Image? image) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => selectedImage = image),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedImage == image
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.3),
              width: selectedImage == image ? 3 : 1,
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: RawImage(
                    image: image,
                    fit: BoxFit.contain,
                  ),
                ),
                if (selectedImage == image)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ProPrimaryButton(
      const ProText(
        'Share',
        textStyle: TextStyle(color: Colors.white),
      ),
      isBig: true,
      onPressed: () => _shareImage(selectedImage),
    );
  }

  Widget _buildShareOptions() {
    final shareOptions = [
      // (Icons.whatsapp, 'WhatsApp', () => ShareUtils.shareToWhatsApp(
      //   'Join me at ${widget.sanitizedMessage}!',
      //   widget.link,
      // )),
      // (Icons.message, 'Messages', () => ShareUtils.shareToMessages(
      //   'Join me at ${widget.sanitizedMessage}!',
      //   widget.link,
      // )),
      // (Icons.email, 'Email', () => ShareUtils.shareViaEmail(
      //   subject: 'RSVP to ${widget.sanitizedMessage}',
      //   message: 'Join me at ${widget.sanitizedMessage}!',
      //   link: widget.link,
      // )),
      // (Icons.copy, 'Copy Link', _copyLink),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: shareOptions.map((option) => IconButton(
        icon: Icon(option.$1),
        onPressed: selectedImage == null && option.$1 != Icons.copy 
            ? null 
            : option.$3,
        tooltip: option.$2,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ProText(
            'Share Flyer',
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const ProText(
            'Select a flyer to share with your socials',
            textStyle: TextStyle(),
          ),
          const SizedBox(height: 16),
          ProCarousel(
            height: height * 0.5,
            viewportFraction: 0.8,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                selectedImage = index == 0 ? shareImage : primaryShareImage ;
              });
            },
            items: [
              if (shareImage != null) _buildSelectableImage(shareImage),
              if (primaryShareImage != null) _buildSelectableImage(primaryShareImage),
            ],
          ),
          const Spacer(),
          _buildShareButton(),
          const SizedBox(height: 8),
          _buildShareOptions(),
        ],
      ),
    );
  }
}
