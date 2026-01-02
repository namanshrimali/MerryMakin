import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/models/user_request_dto.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_segmented_button.dart';
import 'package:merrymakin/commons/widgets/pro_comment_textfield.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/models/comment.dart';

import '../commons/utils/validators.dart';
import '../commons/widgets/cards/pro_card.dart';
import '../commons/widgets/pro_user_avatar.dart';
import '../commons/widgets/pro_bottom_modal_sheet.dart';
import '../widgets/chip_in_verification.dart';

enum RsvpModalStep {
  rsvpForm,
  chipInVerification,
  // Add more steps here as needed for future components
}

class RsvpModal extends ConsumerStatefulWidget {
  final Event event;
  final RSVPStatus initialRsvpStatus;
  final User? user;
  final ProThemeType themeType;
  const RsvpModal({
    super.key,
    required this.event,
    required this.initialRsvpStatus,
    this.user,
    this.themeType = ProThemeType.midnight,
  });

  @override
  ConsumerState<RsvpModal> createState() => _ProRsvpModalState();
}

class _ProRsvpModalState extends ConsumerState<RsvpModal>
    with SingleTickerProviderStateMixin {
  late RSVPStatus _selectedRsvpStatus;
  final List<TextEditingController> _plusOneControllers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? commentText;
  String? gifUrl;
  final _formKey = GlobalKey<FormState>();
  RsvpModalStep _currentStep = RsvpModalStep.rsvpForm;
  bool _isExiting = false;
  late AnimationController _exitController;
  late Animation<Offset> _exitAnimation;

  @override
  void initState() {
    super.initState();
    _selectedRsvpStatus = widget.initialRsvpStatus;

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    ));

    // Add one empty plus one field by default
    final plusOneNames = widget.event.getPlusOneNamesForUser(widget.user);
    for (var plusOneName in plusOneNames) {
      _plusOneControllers.add(TextEditingController(text: plusOneName));
    }
  }

  @override
  void dispose() {
    for (var controller in _plusOneControllers) {
      controller.dispose();
    }
    _nameController.dispose();
    _emailController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _addPlusOneField() {
    setState(() {
      _plusOneControllers.add(TextEditingController());
    });
  }

  void _removePlusOneField(int index) {
    setState(() {
      _plusOneControllers[index].dispose();
      _plusOneControllers.removeAt(index);
    });
  }

  List<String> _getPlusOnes() {
    return _plusOneControllers
        .map((controller) => controller.text)
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Determines the next step after Continue is clicked
  RsvpModalStep? _getNextStep() {
    // Check if we should show chip-in verification
    if (_selectedRsvpStatus == RSVPStatus.GOING &&
        widget.event.chipIn != null &&
        widget.event.chipIn!.amount != null &&
        widget.event.chipIn!.amount! > 0 &&
        widget.event.chipIn!.hasAnyPaymentMethod) {
      return RsvpModalStep.chipInVerification;
    }
    // Add more step conditions here for future components
    return null; // null means no next step, proceed with RSVP
  }

  /// Submits the RSVP and comment to the API
  Future<void> _submitRsvp() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Handle plus ones (for future API extension)
      final plusOnes = _getPlusOnes();

      // Handle comment - post it via API if there's any comment
      final plusOnesText =
          plusOnes.isNotEmpty && _selectedRsvpStatus != RSVPStatus.NOT_GOING
              ? " with ${plusOnes.join(", ")}"
              : "";
      final rsvpStatusText = _selectedRsvpStatus.getDisplayInfo().$2;

      widget.event.setRsvpStatusForUser(
        AppFactory().cookiesService.currentUser,
        _selectedRsvpStatus,
      );

      // Update event comments list
      if (widget.event.comments == null) {
        widget.event.comments = [];
      }
      final String status = widget.event.getRsvpStatusForUser(
                  AppFactory().cookiesService.currentUser!) ==
              RSVPStatus.UNDECIDED
          ? "rsvped $rsvpStatusText${plusOnesText}"
          : "updated their rsvp to $rsvpStatusText${plusOnesText}";

      await Future.wait([
        rsvpForEvent(
          widget.event,
          plusOnes,
          _selectedRsvpStatus,
        ),
        addCommentToEvent(
            widget.event,
            Comment(
              comment: commentText ?? '',
              gifUrl: gifUrl,
              user: AppFactory().cookiesService.currentUser!,
              status: status,
              createdAt: DateTime.now().toUtc(),
            ),
            context)
      ]).then((value) {
        if (mounted) {
          // Update the comment in widget.event with the server-returned comment
          final returnedComment =
              value.length > 1 ? value[1] as Comment? : null;
          if (returnedComment != null) {
            // Replace the local comment with the server-returned comment
            widget.event.comments!.add(returnedComment);
          }

          ref.read(eventProvider.notifier).rsvpEvent(widget.event);

          showSnackBar(context, 'RSVP updated successfully!');
          if (plusOnes.isNotEmpty) {
            // For now, just show a message. You can extend the API later to support these
            showSnackBar(context, 'Plus ones noted: ${plusOnes.join(", ")}');
          }

          // Close the modal
          closeProBottomModalSheet(context);
        }
      });
    } catch (error) {
      if (mounted) {
        showSnackBar(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleContinue() async {
    if (_isSubmitting) {
      return;
    }
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create user if not logged in
      if (widget.user == null) {
        await userService.addOrUpdateUser(
            UserRequestDTO(
                givenName: _nameController.text.trim(),
                email: _emailController.text.trim().isNotEmpty
                    ? _emailController.text.trim()
                    : null,
                sprylyServices: SprylyServices.MerryMakin),
            '',
            SprylyServices.MerryMakin.name);
      }

      // Check if there's a next step to show
      final nextStep = _getNextStep();
      if (nextStep != null) {
        // First, trigger exit animation for current screen
        setState(() {
          _isExiting = true;
        });
        // Animate old screen out to the left
        await _exitController.forward();
        if (mounted) {
          // Then show the new screen
          setState(() {
            _currentStep = nextStep;
            _isExiting = false;
          });
          // Reset exit controller for next transition
          _exitController.reset();
        }
      } else {
        // No next step, submit RSVP directly
        await _submitRsvp();
      }
    } catch (error) {
      if (mounted) {
        showSnackBar(context, error.toString());
      }
    }
  }

  /// Handles the onAlreadyPaid callback from ChipInVerification
  Future<void> _handleAlreadyPaid() async {
    await _submitRsvp();
  }

  Widget buildUserInfoSectionForNonLoggedInUsers(theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProTextField(
              label: 'Your Name',
              hintText: 'Enter your name',
              textEditingController: _nameController,
              keyboardType: TextInputType.name,
              onValidationCallback: (String? value) => validateTextField(
                  value, 'Name', 5, 50,
                  isRequired: widget.user == null),
            ),
            const SizedBox(height: generalAppLevelPadding),
            ProTextField(
              label: 'Email (Optional)',
              hintText: 'Enter your email',
              textEditingController: _emailController,
              keyboardType: TextInputType.emailAddress,
              onValidationCallback: (String? value) =>
                  validateEmailField(value, isRequired: false),
            ),
            const SizedBox(height: generalAppLevelPadding / 2),
            ProText(
              'Just for event updates, guest list, and party chats. No spam.',
              textStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRsvpingAsSectionForLoggedInUsers(theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProText('RSVPing as'),
            SizedBox(width: generalAppLevelPadding / 2),
            ProUserAvatar(
              user: widget.user!,
              radius: 20,
              canEdit: false,
            ),
            SizedBox(width: generalAppLevelPadding / 2),
            ProText(widget.user!.getFirstAndLastName()),
          ],
        ),
      ),
    );
  }

  Widget buildPlusOneSection(List<String> plusOneNames, theme) {
    List<String> suggestedPlusOneNames = [
      "Bill Doors",
      "Kanye East",
      "Elon Tusk",
      "Emma Pebble",
      "Jiff Besoz",
      "Sabrina Carpainter",
      "Tailor Slow",
    ];

    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          // Plus Ones Section
          ProText(
            'Your Plus Ones',
            textStyle: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding / 2),
          ...List.generate(
            _plusOneControllers.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                  bottom: index == _plusOneControllers.length - 1
                      ? 0
                      : generalAppLevelPadding),
              child: Row(
                children: [
                  Expanded(
                    child: ProTextField(
                      // label: "Plus One ${index + 1}",
                      hintText:
                          "e.g. ${suggestedPlusOneNames[index % suggestedPlusOneNames.length]}",
                      textEditingController: _plusOneControllers[index],
                      keyboardType: TextInputType.name,
                      autofocus: index == _plusOneControllers.length - 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removePlusOneField(index),
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProOutlinedButton(
            child: ProText('Add Plus One'),
            isBig: true,
            onPressed: () => _addPlusOneField(),
          ),
        ],
      ),
    );
  }

  Widget buildCommentSection(theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          // Comment Section
          ProUserCommentTextField(
              onChanged: (String? value, String? gifUrl) {
                this.commentText = value;
                this.gifUrl = gifUrl;
              },
              gifService: AppFactory().gifService),
        ],
      ),
    );
  }

  Widget buildRSVPOptionsWidget() {
    final isLoggedIn = widget.user != null;
    final theme =
        ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context);

    return SafeArea(
      key: const ValueKey('rsvpForm'),
      child: Theme(
        data: theme,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RSVP Buttons
              ProCard(
                elevation: 10,
                surfaceTintColor: Colors.white.withOpacity(0.1),
                child: ProSegmentedButton<RSVPStatus>(
                  selected: {_selectedRsvpStatus},
                  segments: [
                    ProButtonSegment(
                      icon: Icon(RSVPStatus.GOING.getDisplayInfo().$1),
                      value: RSVPStatus.GOING,
                      label: ProText(RSVPStatus.GOING.getDisplayInfo().$2),
                    ),
                    ProButtonSegment(
                      icon: Icon(RSVPStatus.NOT_GOING.getDisplayInfo().$1),
                      value: RSVPStatus.NOT_GOING,
                      label: ProText(RSVPStatus.NOT_GOING.getDisplayInfo().$2),
                    ),
                    ProButtonSegment(
                      icon: Icon(RSVPStatus.MAYBE.getDisplayInfo().$1),
                      value: RSVPStatus.MAYBE,
                      label: ProText(RSVPStatus.MAYBE.getDisplayInfo().$2),
                    ),
                  ],
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  selectedBackgroundColor: theme.colorScheme.primary,
                  selectedTextColor: theme.colorScheme.onPrimary,
                  onSelectionChanged: (selected) {
                    setState(() {
                      _selectedRsvpStatus = selected.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: generalAppLevelPadding),

              // Name and Email fields for non-logged-in users
              if (!isLoggedIn) buildUserInfoSectionForNonLoggedInUsers(theme),
              if (isLoggedIn) buildRsvpingAsSectionForLoggedInUsers(theme),
              const SizedBox(height: generalAppLevelPadding),

              if (_selectedRsvpStatus != RSVPStatus.NOT_GOING) ...[
                buildPlusOneSection(
                    widget.event.getPlusOneNamesForUser(widget.user), theme),
                const SizedBox(height: generalAppLevelPadding),
              ],

              buildCommentSection(theme),

              const SizedBox(height: generalAppLevelPadding),

              // Continue Button
              ProPrimaryButton(
                ProText(
                  _isSubmitting ? 'Submitting...' : 'Continue',
                  textStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                isBig: true,
                onPressed: _isSubmitting ? null : _handleContinue,
                disabled: _isSubmitting,
              ),
              const SizedBox(height: generalAppLevelPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipInVerificationView() {
    final theme =
        ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context);
    final plusOnes = _getPlusOnes();
    final user = widget.user ?? AppFactory().cookiesService.currentUser!;

    return SafeArea(
      key: const ValueKey('chipInVerification'),
      child: Theme(
        data: theme,
        child: ChipInVerification(
          event: widget.event,
          attendee: Attendee(
            user: user,
            rsvpStatus: _selectedRsvpStatus,
            rsvpDate: DateTime.now(),
            plusOnes: plusOnes,
          ),
          onAlreadyPaid: _handleAlreadyPaid,
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case RsvpModalStep.rsvpForm:
        return buildRSVPOptionsWidget();
      case RsvpModalStep.chipInVerification:
        return _buildChipInVerificationView();
      // Add more cases here for future steps
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Old screen sliding out to the left (when exiting)
        if (_isExiting)
          SlideTransition(
            position: _exitAnimation,
            child: _buildStepWidget(_currentStep),
          ),
        // New screen sliding in from the right (when not exiting)
        if (!_isExiting)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
            child: _buildCurrentStepWidget(),
          ),
      ],
    );
  }

  Widget _buildStepWidget(RsvpModalStep step) {
    switch (step) {
      case RsvpModalStep.rsvpForm:
        return buildRSVPOptionsWidget();
      case RsvpModalStep.chipInVerification:
        return _buildChipInVerificationView();
      // Add more cases here for future steps
    }
  }
}
