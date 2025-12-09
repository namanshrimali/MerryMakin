import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/comment.dart' show Comment;
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/utils/constants.dart'
    show generalAppLevelPadding;
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart'
    show ProPrimaryButton;
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart'
    show ProOutlinedButton;
import 'package:merrymakin/commons/widgets/cards/pro_card.dart' show ProCard;
import 'package:merrymakin/commons/widgets/pro_comment_textfield.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart'
    show ProFilterChip;
import 'package:merrymakin/commons/widgets/pro_text.dart' show ProText;
import 'package:merrymakin/commons/widgets/pro_snackbar.dart' show showSnackBar;
import 'package:merrymakin/factory/app_factory.dart' show AppFactory;
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/service/event_service.dart';

class TextBlastSheet extends ConsumerStatefulWidget {
  final Event event;
  const TextBlastSheet({super.key, required this.event});

  @override
  ConsumerState<TextBlastSheet> createState() => _TextBlastSheetState();
}

class _TextBlastSheetState extends ConsumerState<TextBlastSheet> {
  late List<String> _textBlastOptions;

  late List<String> _selectedTextBlastOptions;
  String? commentText;
  String? gifUrl;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  final int _maxMessageLength = 400;
  final int _minMessageLength = 10;

  @override
  void initState() {
    super.initState();
    _textBlastOptions = widget.event.getRSVPOptions();
    _selectedTextBlastOptions = [
      ..._textBlastOptions.where((option) => _getCountForOption(option) > 0)
    ];
  }

  RSVPStatus? _getRsvpStatusFromOption(String option) {
    final isPastEvent = widget.event.startDateTime != null &&
        widget.event.startDateTime!
            .isBefore(DateTime.now().subtract(const Duration(hours: 3)));

    if (isPastEvent) {
      if (option == RSVPStatus.GOING.getDisplayForPastInfo().$2) {
        return RSVPStatus.GOING;
      } else if (option == RSVPStatus.NOT_GOING.getDisplayForPastInfo().$2) {
        return RSVPStatus.NOT_GOING;
      } else if (option == RSVPStatus.MAYBE.getDisplayInfo().$2) {
        return RSVPStatus.MAYBE;
      }
    } else {
      if (option == RSVPStatus.GOING.getDisplayInfo().$2) {
        return RSVPStatus.GOING;
      } else if (option == RSVPStatus.MAYBE.getDisplayInfo().$2) {
        return RSVPStatus.MAYBE;
      } else if (option == RSVPStatus.NOT_GOING.getDisplayInfo().$2) {
        return RSVPStatus.NOT_GOING;
      }
    }
    return null;
  }

  int _getCountForOption(String option) {
    final rsvpStatus = _getRsvpStatusFromOption(option);
    if (rsvpStatus == null ||
        widget.event.attendees == null ||
        widget.event.attendees!.isEmpty) {
      return 0;
    }
    return widget.event.getAttendeesByRsvpStatus(rsvpStatus).length;
  }

  int _getTotalSelectedCount() {
    return _selectedTextBlastOptions
        .map((option) => _getCountForOption(option))
        .fold(0, (sum, count) => sum + count);
  }

  bool _hasAnyAttendees() {
    return _textBlastOptions.any((option) => _getCountForOption(option) > 0);
  }

  bool _areAllSelected() {
    return _selectedTextBlastOptions.length == _textBlastOptions.length;
  }

  void _toggleSelectAll() {
    setState(() {
      if (_areAllSelected()) {
        _selectedTextBlastOptions = [];
      } else {
        _selectedTextBlastOptions = [..._textBlastOptions];
      }
    });
  }

  int _getMessageLength() {
    return commentText?.length ?? 0;
  }

  Future<void> _handleSendBlast() async {
    if (_isSending) return;

    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }
    if (_getTotalSelectedCount() == 0) {
      showSnackBar(context, 'Please select at least one recipient group');
      return;
    }

    final totalCount = _getTotalSelectedCount();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: ProText('Confirm Send'),
        content: ProText(
          'Send this announcement to $totalCount ${totalCount == 1 ? 'person' : 'people'} + all hosts? (Only people who RSVPed with their emails will receive it)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ProText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: ProText('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSending = true;
    });

    try {
      await sendTextBlastForEvent(
        widget.event,
        gifUrl,
        commentText!,
        _selectedTextBlastOptions
            .map((option) => _getRsvpStatusFromOption(option)?.name ?? '')
            .toList(),
        context,
      ).then((value) {
        Comment comment = value as Comment;
        widget.event.comments!.add(comment);
        ref.read(eventProvider.notifier).rsvpEvent(widget.event);
      });

      if (mounted) {
        showSnackBar(
          context,
          'Announcement sent to $totalCount ${totalCount == 1 ? 'person' : 'people'}!',
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showSnackBar(context, 'Failed to send announcement: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return ProCard(
      surfaceTintColor: Colors.white.withOpacity(0.1),
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProText(
                  'Send Announcement',
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProText(
            widget.event.name,
            textStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildHeader(context, theme),
        const SizedBox(height: generalAppLevelPadding),
        // Empty state
        ProCard(
          surfaceTintColor: Colors.white.withOpacity(0.1),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding * 1.5),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: generalAppLevelPadding),
                ProText(
                  'No attendees yet',
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: generalAppLevelPadding / 2),
                ProText(
                  'Invite people to your event to start sending announcements!',
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: generalAppLevelPadding * 1.5),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          ProText(
                            'About Email Announcements',
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProText(
                        'Send email announcements to your event attendees based on their RSVP status. Each person in the selected RSVP groups will receive a personalized email with your message.',
                        textStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: theme.colorScheme.primary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ProText(
                              'Emails are sent individually to each user in the selected RSVP types.',
                              textStyle: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSelectedCount = _getTotalSelectedCount();
    final hasAnyAttendees = _hasAnyAttendees();
    final messageLength = _getMessageLength();

    if (!hasAnyAttendees) {
      return _buildEmptyState(context, theme);
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // _buildHeader(context, theme),
          const SizedBox(height: generalAppLevelPadding),
          // Info banner about email - moved to top
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Icon(
          //         Icons.info_outline,
          //         color: theme.colorScheme.primary.withOpacity(0.8),
          //         size: 20,
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: ProText(
          //           'This message will be sent as an email to all selected recipients. Each person in the selected RSVP groups will receive a personalized email.',
          //           textStyle: theme.textTheme.bodySmall?.copyWith(
          //             color: theme.colorScheme.onSurface.withOpacity(0.7),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: generalAppLevelPadding),
          // Recipients section
          ProCard(
            surfaceTintColor: Colors.white.withOpacity(0.1),
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ProText(
                        'Recipients',
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: generalAppLevelPadding / 2),
                ProText(
                  'Select who will receive this email announcement',
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: generalAppLevelPadding),
                // Select All / Deselect All button
                ProOutlinedButton(
                  isBig: true,
                  onPressed: _toggleSelectAll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _areAllSelected() ? Icons.deselect : Icons.select_all,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      ProText(
                        _areAllSelected() ? 'Deselect All' : 'Select All',
                        textStyle: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: generalAppLevelPadding),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: _textBlastOptions
                      .map((option) => ProFilterChip(
                            label: option,
                            isEnabled: _getCountForOption(option) > 0,
                            count: _getCountForOption(option),
                            isSelected:
                                _selectedTextBlastOptions.contains(option),
                            onSelected: (_) => setState(() {
                              _selectedTextBlastOptions.contains(option)
                                  ? _selectedTextBlastOptions.remove(option)
                                  : _selectedTextBlastOptions.add(option);
                            }),
                          ))
                      .toList(),
                ),
                ...[
                  const SizedBox(height: generalAppLevelPadding),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ProText(
                            totalSelectedCount == 0
                                ? 'Select at least one recipient group to send'
                                : 'Sending to ${totalSelectedCount} ${totalSelectedCount == 1 ? 'attendee' : 'attendees'} + all hosts! (Only people who RSVPed with their emails will receive it)',
                            textStyle: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          // Message section
          ProCard(
            surfaceTintColor: Colors.white.withOpacity(0.1),
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ProText(
                        'Message',
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                      ProText(
                        '$messageLength / $_maxMessageLength',
                        textStyle: theme.textTheme.bodySmall?.copyWith(
                          color: messageLength > _maxMessageLength
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: generalAppLevelPadding),
                ProUserCommentTextField(
                  onChanged: (String? value, String? gifUrl) {
                    setState(() {
                      commentText = value;
                      this.gifUrl = gifUrl;
                    });
                  },
                  user: AppFactory().cookiesService.locallyAvailableUserInfo,
                  maxLines: 5,
                  label: '',
                  hintText:
                      'Share updates, reminders, or important information...',
                  gifService: AppFactory().gifService,
                ),
                if (messageLength > _maxMessageLength) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProText(
                          'Message is too long. Please shorten it.',
                          textStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          // Send button
          ProPrimaryButton(
            _isSending
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ProText(
                        'Sending...',
                        textStyle: TextStyle(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : ProText('Send Text Blast'),
            isBig: true,
            onPressed: (totalSelectedCount > 0 &&
                    !_isSending &&
                    messageLength <= _maxMessageLength &&
                    messageLength >= _minMessageLength)
                ? _handleSendBlast
                : null,
            disabled: _isSending ||
                totalSelectedCount == 0 ||
                messageLength > _maxMessageLength ||
                messageLength < _minMessageLength,
          ),
        ],
      ),
    );
  }
}
