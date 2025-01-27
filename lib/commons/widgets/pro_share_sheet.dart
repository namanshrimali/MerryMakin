import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user.dart';
import '../service/user_service.dart';
import '../themes/pro_themes.dart';
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
  final ProThemeType themeType;
  final ProEffectType effectType;

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
    required this.themeType,
    required this.effectType,
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
      themeType: widget.themeType,
      effectType: widget.effectType,
      size: const Size(1080, 1920),
      usePrimaryBackground: false,
    );

    // Generate primary color background image
    final primaryImage = await ShareImageGenerator.generateEventShareImage(
      event: widget.event,
      themeType: widget.themeType,
      effectType: widget.effectType,
      size: const Size(1080, 1920),
      usePrimaryBackground: true,
    );

    setState(() {
      shareImage = surfaceImage;
      primaryShareImage = primaryImage;
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
      //     subject: 'Invitation to ${widget.sanitizedMessage}',
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
        text: '${widget.sanitizedMessage}!\nRSVP here: ${widget.link}',
        subject: 'Invitation to ${widget.sanitizedMessage}',
      );
    } catch (e) {
      Share.share(
        '${widget.sanitizedMessage}!\nRSVP here: ${widget.link}',
        subject: 'Invitation to ${widget.sanitizedMessage}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.6,
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
            'Tap on the flyer to post to socials',
            textStyle: TextStyle(),
          ),
          const SizedBox(height: 16),
          ProCarousel(
            height: height * 0.4,
            viewportFraction: 0.8,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            items: [
              // Link preview - made tappable
              // GestureDetector(
              //   onTap: _copyLink,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.surface,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     padding: const EdgeInsets.all(16),
              //     child: Center(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Container(
              //             child: Column(
              //               children: [
              //                 const ProText(
              //                   'Share Link',
              //                   textStyle: TextStyle(
              //                     fontSize: 20,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 16),
              //                 const ProText('Anyone with the link can RSVP'),
              //               ],
              //             ),
              //           ),
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               Icon(
              //                 Icons.link,
              //                 color: Theme.of(context).primaryColor,
              //               ),
              //               const ProText('Tap to copy'),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // Surface background image - made tappable
              if (shareImage != null)
                GestureDetector(
                  onTap: () => _shareImage(shareImage),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RawImage(
                      image: shareImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              // Primary background image - made tappable
              if (primaryShareImage != null)
                GestureDetector(
                  onTap: () => _shareImage(primaryShareImage),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RawImage(
                      image: primaryShareImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
          // const Spacer(),
          // if (selectedUsers.isEmpty)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     IconButton(
            //       icon: const Icon(Icons.whatsapp),
            //       onPressed: () => ShareUtils.shareToWhatsApp(
            //         'Join me at ${widget.sanitizedMessage}!',
            //         widget.link,
            //       ),
            //       tooltip: 'Share to WhatsApp',
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.message),
            //       onPressed: () => ShareUtils.shareToMessages(
            //         'Join me at ${widget.sanitizedMessage}!',
            //         widget.link,
            //       ),
            //       tooltip: 'Share via Messages',
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.email),
            //       onPressed: () => ShareUtils.shareViaEmail(
            //         subject: 'Invitation to ${widget.sanitizedMessage}',
            //         message: 'Join me at ${widget.sanitizedMessage}!',
            //         link: widget.link,
            //       ),
            //       tooltip: 'Share via Email',
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.copy),
            //       onPressed: _copyLink,
            //       tooltip: 'Copy Link',
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.share),
            //       onPressed: _shareCurrentView,
            //       tooltip: 'Share',
            //     ),
            //   ],
            // )
          // else
            // ProOutlinedButton(
            //   onPressed: () {
            //     Navigator.pop(context, selectedUsers);
            //   },
            //   child: ProText(
            //     'Share with ${selectedUsers.length} ${selectedUsers.length == 1 ? 'User' : 'Users'}',
            //   ),
            // ),
        ],
      ),
    );
  }
}
