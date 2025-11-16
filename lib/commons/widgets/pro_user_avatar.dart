import 'package:flutter/material.dart';
import 'package:merrymakin/commons/service/image_service.dart';
import '../models/user.dart';
import '../widgets/pro_text.dart';
import 'pro_bottom_modal_sheet.dart';
import 'pro_image_picker.dart';

class ProUserAvatar extends StatefulWidget {
  final User user;
  final double radius;
  final bool canEdit;
  final Function? onTap;
  final ImageService? imageService;
  ProUserAvatar({
    super.key,
    required this.user,
    this.imageService,
    this.radius = 12,
    this.canEdit = false,
    this.onTap = null,
  });

  @override
  State<ProUserAvatar> createState() => _ProUserAvatarState();
}

class _ProUserAvatarState extends State<ProUserAvatar> {
  void _handleImageSelection() {
    if (widget.imageService == null) {
      return;
    }
    openProBottomModalSheet(
      context,
      isFullScreen: true,
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ProImagePicker(
          onImageSelected: (String imageUrl) {
            setState(() {
              widget.user.photoUrl = imageUrl;
              if (widget.onTap != null) {
                widget.onTap!(widget.user);
              }
            });
            Navigator.pop(context); // Close bottom sheet
          },
          imageService: widget.imageService!,
        ),
      ),
    );
  }

  Widget userAvatar() {
    Widget? childWidget = null;
    if (widget.user.photoUrl == null) {
      final initials = widget.user.getInitials();
      childWidget = ProText(
        '${initials[0].toUpperCase()}${initials[1].toUpperCase()}',
        textStyle: TextStyle(fontSize: widget.radius * .80),
      );
    }
    // have gradient background color
    return Stack(children: [
      CircleAvatar(
          radius: widget.radius,
          backgroundImage: NetworkImage(widget.user.photoUrl ?? ''),
          onBackgroundImageError: (_, __) {},
          child: childWidget),
      if (widget.canEdit)
        Positioned(
          right: -6,
          bottom: -6,
          child: CircleAvatar(
            radius: widget.radius * 0.3, // Smaller size for the camera icon
            backgroundColor: Colors.white,
            child: Icon(
              Icons.camera_alt,
              size: widget.radius * 0.3,
            ),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = userAvatar();
    if (widget.canEdit) {
      return InkWell(
        radius: widget.radius,
        child: avatar,
        onTap: () {
          _handleImageSelection();
        },
      );
    }
    return avatar;
  }
}
