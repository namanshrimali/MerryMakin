import 'dart:math';

import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/questionnaire_question.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';

class QuestionnaireWidget extends StatefulWidget {
  final bool isEnabled;
  final Map<String, QuestionnaireQuestion> questions;
  final Function(bool isEnabled) onIsEnabledChanged;
  final Function(Map<String, QuestionnaireQuestion> questions) onQuestionsChanged;

  const QuestionnaireWidget({
    super.key,
    required this.isEnabled,
    required this.questions,
    required this.onIsEnabledChanged,
    required this.onQuestionsChanged,
  });

  @override
  State<QuestionnaireWidget> createState() => _QuestionnaireWidgetState();
}

class _QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  late Map<String, QuestionnaireQuestion> _questions;
  late bool _isEnabled;
  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
    _isEnabled = widget.isEnabled;
  }

  @override
  void didUpdateWidget(QuestionnaireWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questions != widget.questions) {
      _questions = widget.questions;
    }
  }

  void _addQuestion() {
    String newQuestionId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _questions[newQuestionId] = QuestionnaireQuestion(
        type: QuestionnaireQuestionType.shortAnswer,
        question: '',
        required: true,
        options: [],
      );
    });
    _notifyChanges();
  }

  void _deleteQuestion(String questionId) {
    setState(() {
      _questions.remove(questionId);
    });
    _notifyChanges();
  }

  void _updateQuestion(String questionId, QuestionnaireQuestion question) {
    _questions[questionId] = question;
    _notifyChanges();
  }

  void _notifyChanges() {
    widget.onQuestionsChanged(_questions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle
        ProCard(
          radius: 32,
          elevation: 10,
          surfaceTintColor: Colors.white.withOpacity(0.1),
          child: ProListItem(
            key: const Key('questionnaire-toggle'),
            title: const ProText(
              'Questionnaire',
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: ProText(
            'Ask guests questions when they RSVP. Collect dietary restrictions, potluck items, anything!',
            textStyle: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
            trailing: Switch(
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
                widget.onIsEnabledChanged(_isEnabled);
              },
            ),
          ),
        ),
        // Description text
        if (_isEnabled) ...[
          const SizedBox(height: 16),
          // Questions list
          ..._questions.entries.map((entry) => _QuestionBlock(
            questionId: entry.key,
            question: entry.value,
            onUpdate: (question) => _updateQuestion(entry.key, question),
            onDelete: () => _deleteQuestion(entry.key),
          )),
          // Add question button
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _addQuestion(),
                icon: const Icon(Icons.add),
                label: const ProText('Add question'),
              ),
            ],
          ),
        ],
        const SizedBox(height: generalAppLevelPadding),
        ProPrimaryButton(
          ProText('Save'),
          isBig: true,
          onPressed: () {
            _notifyChanges();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _QuestionBlock extends StatefulWidget {
  final QuestionnaireQuestion question;
  final String questionId;
  final Function(QuestionnaireQuestion) onUpdate;
  final VoidCallback onDelete;

  const _QuestionBlock({
    required this.question,
    required this.questionId,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_QuestionBlock> createState() => _QuestionBlockState();
}

class _QuestionBlockState extends State<_QuestionBlock> {
  late QuestionnaireQuestion _question;
  final Map<int, TextEditingController> _optionControllers = {};
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _questionController.text = _question.question;
    _initializeOptionControllers();
  }

  @override
  void didUpdateWidget(_QuestionBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _question = widget.question;
      _questionController.text = _question.question;
      _initializeOptionControllers();
    }
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (int i = 0; i < _question.options.length; i++) {
      _optionControllers[i] = TextEditingController(text: _question.options[i]);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    widget.onUpdate(_question);
  }

  void _updateQuestionType(QuestionnaireQuestionType type) {
    setState(() {
      _question = _question.copyWith(
        type: type,
        options: type == QuestionnaireQuestionType.dropdown
            ? (_question.options.isEmpty ? [''] : _question.options)
            : [],
      );
      if (type == QuestionnaireQuestionType.dropdown) {
        _initializeOptionControllers();
      } else {
        _optionControllers.clear();
      }
    });
    _updateQuestion();
  }

  void _updateRequired(bool required) {
    setState(() {
      _question = _question.copyWith(required: required);
    });
    _updateQuestion();
  }

  void _updateQuestionText(String text) {
    setState(() {
      _question = _question.copyWith(question: text);
    });
    _updateQuestion();
  }

  void _addOption() {
    setState(() {
      final newIndex = _question.options.length;
      _question = _question.copyWith(
        options: [..._question.options, ''],
      );
      _optionControllers[newIndex] =
          TextEditingController(text: '');
    });
    _updateQuestion();
  }

  void _updateOption(int index, String value) {
    final newOptions = List<String>.from(_question.options);
    newOptions[index] = value;
    _question = _question.copyWith(options: newOptions);
    _updateQuestion();
  }

  void _deleteOption(int index) {
    setState(() {
      final newOptions = List<String>.from(_question.options);
      newOptions.removeAt(index);
      _question = _question.copyWith(options: newOptions);
      
      // Dispose and remove the controller at the deleted index
      _optionControllers[index]?.dispose();
      
      // Rebuild controllers map for remaining options
      final oldControllers = Map<int, TextEditingController>.from(_optionControllers);
      _optionControllers.clear();
      for (int i = 0; i < newOptions.length; i++) {
        final oldIndex = i >= index ? i + 1 : i;
        if (oldControllers.containsKey(oldIndex)) {
          _optionControllers[i] = oldControllers[oldIndex]!;
        } else {
          _optionControllers[i] = TextEditingController(text: newOptions[i]);
        }
      }
    });
    _updateQuestion();
  }

  void _showQuestionTypeSelector() {
    openProBottomModalSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: QuestionnaireQuestionType.values.map((type) {
          return ProListItem(
            key: Key(type.name),
            title: ProText(type.displayName),
            onTap: () {
              _updateQuestionType(type);
              Navigator.pop(context);
            },
            trailing: _question.type == type
                ? const Icon(Icons.check, color: Colors.green)
                : null,
          );
        }).toList(),
      ),
    );
  }

  String getQuestionExample() {
     List<String> sample_questions = [
      'e.g Any food allergies?',
      'e.g Any dietary restrictions?',
      'e.g Any potluck items?',
      'e.g Any other questions?',
     ];
     return sample_questions[Random().nextInt(sample_questions.length)];
  }

  @override
  Widget build(BuildContext context) {
    return ProCard(
      radius: 32,
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with type selector, required checkbox, and delete button
            Row(
              children: [
                // Question type dropdown
                Expanded(
                  child: InkWell(
                    onTap: _showQuestionTypeSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProText(_question.type.displayName),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Required checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _question.required,
                      onChanged: (value) => _updateRequired(value ?? false),
                    ),
                    const ProText('Required'),
                  ],
                ),
                const SizedBox(width: 8),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Question text field
            ProTextField(
              hintText: getQuestionExample(),
              textEditingController: _questionController,
              onChanged: (value) => _updateQuestionText(value as String),
            ),
            // Options (only for dropdown)
            if (_question.type == QuestionnaireQuestionType.dropdown) ...[
              const SizedBox(height: 12),
              ...List.generate(_question.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const ProText('• '),
                      Expanded(
                        child: ProTextField(
                          hintText: 'Option ${index + 1}',
                          autofocus: false,
                          textEditingController: _optionControllers[index],
                          onChanged: (value) =>
                              _updateOption(index, value as String),
                        ),
                      ),
                      if (_question.options.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _deleteOption(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              // Add option button
              Center(
                child: TextButton(
                  onPressed: _addOption,
                  child: const ProText('+ New option'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

