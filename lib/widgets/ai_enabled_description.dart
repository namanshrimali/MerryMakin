import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merrymakin/commons/ai/ai_typing_engine.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';

import '../commons/widgets/buttons/pro_primary_button.dart';

class AIEnabledDescription extends StatefulWidget {
  final Event event;
  final ValueChanged<String>? onDescriptionChanged;
  final TextEditingController? controller;
  final List<String>? initialFoodSelections;
  final String? initialDressCodeSelection;
  final bool animateAgain;

  const AIEnabledDescription({
    super.key,
    required this.event,
    this.onDescriptionChanged,
    this.controller,
    this.initialFoodSelections,
    this.initialDressCodeSelection,
    this.animateAgain = false,
  });

  @override
  State<AIEnabledDescription> createState() => _AIEnabledDescriptionState();
}

class _AIEnabledDescriptionState extends State<AIEnabledDescription> {
  static const List<String> _foodOptions = <String>[
    'BYOB',
    'Potluck',
    'Buffet',
    'Drinks',
    'Snacks',
  ];

  static const List<String> _dressOptions = <String>[
    'Formal',
    'Black & White',
    'Casual',
    'Ethnic Wear',
    'Smart Casual',
  ];

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AiTypingEngine _typingEngine;
  final Set<String> _selectedFood = <String>{};
  String? _selectedDress = null;

  bool _isTyping = false;
  bool _pendingContextRefresh = false;

  String? _lastFoodLine;
  String? _lastDressLine;
  bool _foodLineLockedByUser = false;
  bool _dressLineLockedByUser = false;
  String? _lastChipInLine;
  bool _chipInLineLockedByUser = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _typingEngine = AiTypingEngine(
      controller: _controller,
      onTextChanged: (String value) =>
          widget.onDescriptionChanged?.call(value),
      onTypingStatusChanged: (bool typing) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isTyping = typing;
        });
        if (!typing && _pendingContextRefresh) {
          _pendingContextRefresh = false;
          _refreshContextualSections();
        }
      },
    );
    _hydrateSelectionsFromEvent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialGeneration();
    });
  }

  void _hydrateSelectionsFromEvent() {
    if (widget.event.foodSituation != null &&
        widget.event.foodSituation!.isNotEmpty) {
      _selectedFood.addAll(
        widget.event.foodSituation!
            .split(',')
            .map((value) => value.trim())
            .where(_foodOptions.contains),
      );
    }

    if (widget.initialDressCodeSelection != null) {
      _selectedDress = widget.initialDressCodeSelection;
    }
  }

  @override
  void dispose() {
    _typingEngine.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _startInitialGeneration() {
    // if event has description, use it and don't add anything else
    if (widget.event.description != null && widget.event.description!.isNotEmpty) {
      _typingEngine.setTextImmediately(widget.event.description!);
      return;
    }
    final String baseText = _buildBaseDescription(widget.event);
    final String? foodLine =
        _selectedFood.isNotEmpty ? _buildFoodLine() : null;
    final String? dressLine =
        _selectedDress != null && _selectedDress!.isNotEmpty ? _buildDressLine() : null;
    final String? chipInLine = _buildChipInLine();
    _lastFoodLine = foodLine;
    _lastDressLine = dressLine;
    _foodLineLockedByUser = false;
    _dressLineLockedByUser = false;
    _pendingContextRefresh = false;

    final String composed =
        _composeFullText(baseText, foodLine, dressLine, chipInLine);
    _typingEngine.animateTo(composed, animateAgain: widget.animateAgain);
  }

  List<String> _splitIntoLines(String description) {
    final List<String> lines = <String>[];
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < description.length; i++) {
      final String char = description[i];
      buffer.write(char);
      if (char == '.' || char == '!' || char == '?') {
        final String sentence = buffer.toString().trim();
        if (sentence.isNotEmpty) {
          lines.add(sentence);
        }
        buffer = StringBuffer();
      }
    }

    final String trailing = buffer.toString().trim();
    if (trailing.isNotEmpty) {
      lines.add(RegExp(r'[.!?]$').hasMatch(trailing) ? trailing : '$trailing.');
    }

    return lines;
  }

  String _buildFoodLine() {
    const Map<String, String> descriptions = <String, String>{
      'BYOB': '🍾 BYOB – Bring your favorite bottle to share.',
      'Potluck': '🍱 Potluck – Show off your signature dish.',
      'Buffet': '🍽️ Buffet – Dive into a spread of crowd favorites.',
      'Drinks': '🍹 Drinks – Sip curated cocktails and sparkling sippers.',
      'Snacks': '🍿 Snacks – Grazing table loaded with crunchy bites.',
    };

    final List<String> segments = _foodOptions
        .where(_selectedFood.contains)
        .map((String option) => descriptions[option] ?? option)
        .toList();

    return 'Food & Drinks: ${segments.join(' ')}';
  }

  String _buildDressLine() {
    const Map<String, String> descriptions = <String, String>{
      'Formal': '🤵 Formal – Dress to impress in elegant evening wear.',
      'Black & White': '⚫⚪ Black & White – Keep it classic in monochrome.',
      'Casual': '🧢 Casual – Comfy fits encouraged, just bring the vibe.',
      'Ethnic Wear':
          '🪔 Ethnic Wear – Celebrate culture with vibrant traditional looks.',
      'Smart Casual':
          '🕶️ Smart Casual – Sharp, playful, and ready for photos.',
    };

    if (_selectedDress == null) {
      return '';
    }

    return 'Dress Code: ${descriptions[_selectedDress!] ?? _selectedDress!}';
  }
  String _buildChipInLine() {
    if (widget.event.chipIn == null || widget.event.chipIn!.amount == null || widget.event.chipIn!.amount! <= 0) {
      return '';
    }
    String chipInLine = 'Chip In: 💰 We\'re asking guests to chip in an amount of ${widget.event.chipIn?.getChipInAmountString()} for the event.';
    if (widget.event.chipIn?.hasAnyPaymentMethod ?? false) {
      for (final String paymentMethod in widget.event.chipIn?.getPaymentMethodLabelsList() ?? []) {
        final String? userId = widget.event.chipIn?.getPaymentMethodUserIdViaLabel(paymentMethod);
        if (userId != null && userId.trim().isNotEmpty && userId.trim().toLowerCase() != 'null') {
          chipInLine += '\n${paymentMethod}: ${userId}';
        }
      }
    }

    return chipInLine;
  }

  String _applyEventDetails(String template, Event event) {
    // final String rawLocation = (event.location ?? '').trim();
    // final String location =
    //     rawLocation.isNotEmpty ? rawLocation : 'To Be Decided';
    final String date = _formatDate(event.startDateTime);
    final String time = _formatTime(event.startDateTime);

    String sanitizedTemplate = template.replaceAll(
      RegExp(r'\s*,?\s*at\s+\[Location\](,?|\.)?'),
      '',
    );
    sanitizedTemplate =
        sanitizedTemplate.replaceAll('[Location]', '').trim();

    String filled = sanitizedTemplate
        .replaceAll('[Event Name]', event.name)
        .replaceAll('[Date]', date)
        .replaceAll('[Time]', time);

    filled = filled.replaceAll(RegExp(r'\s+'), ' ').trim();
    filled = filled
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .replaceAll(' !', '!')
        .replaceAll(' ?', '?')
        .replaceAll(' :', ':')
        .replaceAll(' ;', ';');

    return filled;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'To Be Decided';
    }
    return DateFormat('EEEE, MMM d').format(dateTime.toLocal());
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'To Be Decided';
    }
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  String _buildBaseDescription(Event event) {
    final String eventType = inferEventType(event.name);
    final String baseDescription = generateDescription(
      eventType,
      event.name,
    );
    final String detailed = _applyEventDetails(baseDescription, event);
    return _splitIntoLines(detailed).join('\n');
  }

  String _composeFullText(
    String base,
    String? foodLine,
    String? dressLine,
    String? chipInLine,
  ) {
    final List<String> resultLines = base.split('\n');
    while (resultLines.isNotEmpty && resultLines.last.trim().isEmpty) {
      resultLines.removeLast();
    }

    bool hasContext = false;

    void appendContextLine(String line) {
      if (!hasContext) {
        if (resultLines.isNotEmpty) {
          resultLines.add('');
        }
        hasContext = true;
      }
      resultLines.add(line);
    }

    if (foodLine != null && foodLine.isNotEmpty) {
      appendContextLine(foodLine);
    }
    if (dressLine != null && dressLine.isNotEmpty) {
      appendContextLine(dressLine);
    }
    if (chipInLine != null && chipInLine.isNotEmpty) {
      appendContextLine(chipInLine);
    }

    return resultLines.join('\n');
  }

  void _refreshContextualSections() {
    if (_typingEngine.isTyping) {
      _pendingContextRefresh = true;
      return;
    }
    _pendingContextRefresh = false;

    final List<String> originalLines = _controller.text.split('\n');
    final List<String> baseLines = <String>[];

    const String foodPrefix = 'Food & Drinks:';
    const String dressPrefix = 'Dress Code:';

    for (final String line in originalLines) {
      if (line.startsWith(foodPrefix)) {
        if (!_foodLineLockedByUser &&
            _lastFoodLine != null &&
            line == _lastFoodLine) {
          continue;
        }
        if (!_foodLineLockedByUser &&
            _lastFoodLine != null &&
            line != _lastFoodLine) {
          _foodLineLockedByUser = true;
        }
        baseLines.add(line);
        continue;
      }

      if (line.startsWith(dressPrefix)) {
        if (!_dressLineLockedByUser &&
            _lastDressLine != null &&
            line == _lastDressLine) {
          continue;
        }
        if (!_dressLineLockedByUser &&
            _lastDressLine != null &&
            line != _lastDressLine) {
          _dressLineLockedByUser = true;
        }
        baseLines.add(line);
        continue;
      }

      baseLines.add(line);
    }

    while (baseLines.isNotEmpty && baseLines.last.trim().isEmpty) {
      baseLines.removeLast();
    }

    final List<String> updatedLines = List<String>.from(baseLines);
    bool contextStarted = updatedLines.any(
      (String line) =>
          line.startsWith(foodPrefix) || line.startsWith(dressPrefix),
    );

    void appendContextLine(String line) {
      if (!contextStarted) {
        if (updatedLines.isNotEmpty && updatedLines.last.trim().isNotEmpty) {
          updatedLines.add('');
        }
        contextStarted = true;
      }
      updatedLines.add(line);
    }

    String? nextFoodLine;
    if (!_foodLineLockedByUser && _selectedFood.isNotEmpty) {
      nextFoodLine = _buildFoodLine();
      appendContextLine(nextFoodLine);
    }

    String? nextDressLine;
    if (!_dressLineLockedByUser && _selectedDress != null && _selectedDress!.isNotEmpty) {
      nextDressLine = _buildDressLine();
      appendContextLine(nextDressLine);
    }

    final String newText = updatedLines.join('\n');
    final String currentText = _controller.text;

    if (newText != currentText) {
      final bool sharesPrefix =
          newText.startsWith(currentText) || currentText.startsWith(newText);
      if (sharesPrefix) {
        _typingEngine.animateTo(newText);
      } else {
        _typingEngine.setTextImmediately(newText);
      }
    }

    if (!_foodLineLockedByUser) {
      _lastFoodLine = nextFoodLine;
    }
    if (!_dressLineLockedByUser) {
      _lastDressLine = nextDressLine;
    }

    if (_selectedFood.isEmpty && !_foodLineLockedByUser) {
      _lastFoodLine = null;
    }
    if (_selectedDress == null || _selectedDress!.isEmpty && !_dressLineLockedByUser) {
      _lastDressLine = null;
    }
  }

  void _onFoodTapped(String value) {
    setState(() {
      if (_selectedFood.contains(value)) {
        _selectedFood.remove(value);
      } else {
        _selectedFood.add(value);
      }
      if (_typingEngine.isTyping) {
        _pendingContextRefresh = true;
      } else {
        _refreshContextualSections();
      }
    });
  }

    void _onDressTapped(String value) {
    setState(() {
      _selectedDress = _selectedDress == value ? null : value;
      if (_typingEngine.isTyping) {
        _pendingContextRefresh = true;
      } else {
        _refreshContextualSections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProText('Food Situation', textStyle: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _foodOptions
              .map(
                (String option) => ProFilterChip(
                  label: option,
                  isSelected: _selectedFood.contains(option),
                  onSelected: (_) => _onFoodTapped(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        ProText('Dress Code', textStyle: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dressOptions
              .map(
                (String option) => ProFilterChip(
                  label: option,
                  isSelected: _selectedDress == option,
                  onSelected: (_) => _onDressTapped(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        ProText('AI Generated Description', textStyle: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ProTextField(
          textAlign: TextAlign.center,
          textEditingController: _controller,
          multiline: true,
          maxLines: 8,
          hintText: 'Let AI craft your event description...',
        ),
        if (_isTyping) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating description...',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
        const SizedBox(height: generalAppLevelPadding),
        Center(
          child: ProPrimaryButton(
            isBig: true,
            disabled: _isTyping,
            const ProText('Use this description'),
            onPressed: _handleConfirm,
          ),
        ),
      ],
    );
  }

  void _handleConfirm() {
    if (_typingEngine.isTyping) {
      _typingEngine.setTextImmediately(_controller.text);
    }
    final String trimmed = _controller.text.trim();
    widget.event.description = trimmed;
    widget.event.foodSituation =
        _selectedFood.isEmpty ? null : _selectedFood.join(', ');
    widget.event.dressCode =
        _selectedDress == null || _selectedDress!.isEmpty ? null : _selectedDress;
    Navigator.of(context).pop(trimmed);
  }
}

String inferEventType(String eventName) {
  eventName = eventName.toLowerCase();

  if (eventName.contains('diwali') || eventName.contains('deepavali')) {
    return 'festival:diwali';
  } else if (eventName.contains('holi')) {
    return 'festival:holi';
  } else if (eventName.contains('dussehra')) {
    return 'festival:dussehra';
  } else if (eventName.contains('raksha bandhan') ||
      eventName.contains('rakhi')) {
    return 'festival:raksha_bandhan';
  } else if (eventName.contains('navratri')) {
    return 'festival:navratri';
  } else if (eventName.contains('makar sankranti')) {
    return 'festival:makar_sankranti';
  } else if (eventName.contains('onam')) {
    return 'festival:onam';
  } else if (eventName.contains('lohri')) {
    return 'festival:lohri';
  } else if (eventName.contains('ganesh chaturthi') ||
      eventName.contains('ganesh utsav') ||
      eventName.contains('ganesh puja') ||
      eventName.contains('ganesh festival')) {
    return 'festival:ganesh_chaturthi';
  } else if (eventName.contains('janmashtami')) {
    return 'festival:janmashtami';
  } else if (eventName.contains('baisakhi')) {
    return 'festival:baisakhi';
  } else if (eventName.contains('pongal')) {
    return 'festival:pongal';
  } else if (eventName.contains('christmas') ||
      eventName.contains('xmas')) {
    return 'festival:christmas';
  } else if (eventName.contains('easter')) {
    return 'festival:easter';
  } else if (eventName.contains('good friday')) {
    return 'festival:good_friday';
  } else if (eventName.contains('pentecost')) {
    return 'festival:pentecost';
  } else if (eventName.contains('ascension day')) {
    return 'festival:ascension_day';
  } else if (eventName.contains('all saints day')) {
    return 'festival:all_saints_day';
  } else if (eventName.contains('assumption of mary')) {
    return 'festival:assumption_of_mary';
  } else if (eventName.contains('advent')) {
    return 'festival:advent';
  } else if (eventName.contains('epiphany')) {
    return 'festival:epiphany';
  } else if (eventName.contains('ash wednesday')) {
    return 'festival:ash_wednesday';
  } else if (eventName.contains('new year')) {
    return 'holiday:new_year';
  } else if (eventName.contains('labor day') ||
      eventName.contains('workers day')) {
    return 'holiday:labor_day';
  } else if (eventName.contains('independence day')) {
    return 'holiday:independence_day';
  } else if (eventName.contains('international day of peace')) {
    return 'holiday:international_day_of_peace';
  } else if (eventName.contains('world environment day')) {
    return 'holiday:world_environment_day';
  } else if (eventName.contains('mother\'s day')) {
    return 'holiday:mothers_day';
  } else if (eventName.contains('father\'s day')) {
    return 'holiday:fathers_day';
  } else if (eventName.contains('veterans day') ||
      eventName.contains('remembrance day')) {
    return 'holiday:veterans_day';
  } else if (eventName.contains('thanksgiving')) {
    return 'holiday:thanksgiving';
  } else if (eventName.contains('halloween')) {
    return 'holiday:halloween';
  } else if (eventName.contains('boxing day')) {
    return 'holiday:boxing_day';
  } else if (eventName.contains('international women\'s day')) {
    return 'holiday:international_womens_day';
  } else if (eventName.contains('birthday') || eventName.contains('bday')) {
    return 'birthday';
  } else if (eventName.contains('party') ||
      eventName.contains('bash') ||
      eventName.contains('celebration')) {
    return 'party';
  } else if (eventName.contains('anniversary') || eventName.contains('anniv')) {
    return 'anniversary';
  }

  return 'general';
}

String generateDescription(String eventType, String eventName) {
  switch (eventType) {
    case 'festival:diwali':
      return 'Celebrate the Festival of Lights! [Event Name] is on [Date] at [Time]. Enjoy sweets, lights, and togetherness!';
    case 'festival:holi':
      return 'Celebrate the Festival of Colors! [Event Name] is on [Date] at [Time]. Let’s throw colors and have fun together!';
    case 'festival:dussehra':
      return 'Celebrate the victory of good over evil! [Event Name] is on [Date] at [Time]. Let’s join in the festivities!';
    case 'festival:raksha_bandhan':
      return 'Celebrate the bond of siblings! [Event Name] is on [Date] at [Time]. Join us for a fun and meaningful celebration!';
    case 'festival:navratri':
      return 'Join us for nine nights of devotion and dance! [Event Name] is on [Date] at [Time]. Celebrate Durga’s triumph!';
    case 'festival:makar_sankranti':
      return 'Let’s celebrate the harvest! [Event Name] is on [Date] at [Time]. Enjoy sweets, kites, and festive spirit!';
    case 'festival:onam':
      return 'Celebrate Kerala’s harvest festival! [Event Name] is on [Date] at [Time]. Join us for a grand feast and traditional fun!';
    case 'festival:lohri':
      return 'Celebrate the harvest in Punjab! [Event Name] is on [Date] at [Time]. Let’s gather around the bonfire and celebrate!';
    case 'festival:ganesh_chaturthi':
      return 'Celebrate Lord Ganesha’s birthday! [Event Name] is on [Date] at [Time]. Join us for prayers, sweets, and a grand procession!';
    case 'festival:janmashtami':
      return 'Celebrate the birth of Lord Krishna! [Event Name] is on [Date] at [Time]. Let’s sing, dance, and worship together!';
    case 'festival:baisakhi':
      return 'Celebrate the harvest season! [Event Name] is on [Date] at [Time]. Enjoy dancing and festive food!';
    case 'festival:pongal':
      return 'Celebrate the Tamil harvest festival! [Event Name] is on [Date] at [Time]. Enjoy traditional food and vibrant celebrations!';
    case 'festival:christmas':
      return 'It’s the most wonderful time of the year! [Event Name] is on [Date] at [Time]. Join us for holiday cheer and festivities!';
    case 'festival:easter':
      return 'Celebrate the resurrection of Christ! [Event Name] is on [Date] at [Time]. Come for a joyful celebration and feast!';
    case 'festival:good_friday':
      return 'Join us in reflection and prayer on Good Friday. [Event Name] is on [Date] at [Time]. Let’s honor Christ’s sacrifice.';
    case 'festival:pentecost':
      return 'Celebrate the coming of the Holy Spirit! [Event Name] is on [Date] at [Time]. Join us for this significant Christian holiday!';
    case 'festival:ascension_day':
      return 'Celebrate the Ascension of Jesus! [Event Name] is on [Date] at [Time]. Join us for reflection and celebration!';
    case 'festival:all_saints_day':
      return 'Honor the saints and martyrs! [Event Name] is on [Date] at [Time]. Join us for this important Christian observance!';
    case 'festival:assumption_of_mary':
      return 'Celebrate the Assumption of Mary into heaven! [Event Name] is on [Date] at [Time]. Come for mass and blessings!';
    case 'festival:advent':
      return 'Prepare for the coming of Christ! [Event Name] is on [Date] at [Time]. Join us for this joyful time of anticipation!';
    case 'festival:epiphany':
      return 'Celebrate the visit of the Magi! [Event Name] is on [Date] at [Time]. Let’s commemorate the manifestation of Christ!';
    case 'festival:ash_wednesday':
      return 'Mark the beginning of Lent on Ash Wednesday! [Event Name] is on [Date] at [Time]. Join us for reflection and prayer!';
    case 'holiday:new_year':
      return 'Celebrate the beginning of the new year! [Event Name] is on [Date] at [Time]. Let’s ring in the new year together!';
    case 'holiday:labor_day':
      return 'Take a break and enjoy Labor Day! [Event Name] is on [Date] at [Time]. Let’s relax and celebrate the workers!';
    case 'holiday:independence_day':
      return 'Celebrate freedom on Independence Day! [Event Name] is on [Date] at [Time]. Join us for fireworks and fun!';
    case 'holiday:international_day_of_peace':
      return 'Celebrate peace on International Day of Peace! [Event Name] is on [Date] at [Time]. Let’s unite for global harmony!';
    case 'holiday:world_environment_day':
      return 'Join us to protect the planet on World Environment Day! [Event Name] is on [Date] at [Time]. Let’s make a difference!';
    case 'holiday:mothers_day':
      return 'Celebrate mothers everywhere! [Event Name] is on [Date] at [Time]. Let’s honor the women who raised us!';
    case 'holiday:fathers_day':
      return 'Celebrate fathers and father figures! [Event Name] is on [Date] at [Time]. Let’s appreciate the dads in our lives!';
    case 'holiday:veterans_day':
      return 'Honor our veterans! [Event Name] is on [Date] at [Time]. Join us for a tribute to those who served!';
    case 'holiday:thanksgiving':
      return 'Give thanks this Thanksgiving! [Event Name] is on [Date] at [Time]. Let’s gather to enjoy food and gratitude!';
    case 'holiday:halloween':
      return 'Get spooky this Halloween! [Event Name] is on [Date] at [Time]. Come dressed up for fun and treats!';
    case 'holiday:boxing_day':
      return 'Celebrate Boxing Day with great sales and fun! [Event Name] is on [Date] at [Time]. Let’s enjoy the festivities!';
    case 'holiday:international_womens_day':
      return 'Celebrate women around the world! [Event Name] is on [Date] at [Time]. Join us for a day of empowerment and appreciation!';
    case 'party':
      return 'Hey! I’m hosting a little get-together on [Date] at [Time] at [Location]. Come by for some fun, good vibes, and maybe a drink or two!';
    case 'birthday':
      return 'Hey! I’m hosting a birthday party on [Date] at [Time] at [Location]. Come by for some fun, good vibes, and maybe a drink or two!';
    case 'anniversary':
      return 'Hey! I’m hosting an anniversary party on [Date] at [Time] at [Location]. Come by for some fun, good vibes, and maybe a drink or two!';
    default:
      return 'Come join us for a fun time at [Location] on [Date] at [Time]. Looking forward to seeing you!';
  }
}
