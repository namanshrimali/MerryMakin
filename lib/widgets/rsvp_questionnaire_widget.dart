import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/questionnaire_question.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/widgets/rsvping_as.dart';

/// Widget for answering questionnaire questions during RSVP flow
/// Provides a smooth, user-friendly experience with progress tracking
class RsvpQuestionnaireWidget extends StatefulWidget {
  final Event event;
  final User user;
  final ProThemeType themeType;
  final Function(Map<String, String> answers) onComplete;

  const RsvpQuestionnaireWidget({
    super.key,
    required this.event,
    required this.user,
    required this.onComplete,
    this.themeType = ProThemeType.midnight,
  });

  @override
  State<RsvpQuestionnaireWidget> createState() => _RsvpQuestionnaireWidgetState();
}

class _RsvpQuestionnaireWidgetState extends State<RsvpQuestionnaireWidget> {
  final Map<String, TextEditingController> _answerControllers = {};
  final Map<String, String?> _selectedDropdownAnswers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentQuestionIndex = 0;
  late List<MapEntry<String, QuestionnaireQuestion>> _questions;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _initializeControllers();
  }

  void _initializeQuestions() {
    final questions = widget.event.questionnaireQuestions ?? {};
    _questions = questions.entries.toList();
  }

  void _initializeControllers() {
    for (var entry in _questions) {
      final questionId = entry.key;
      final question = entry.value;
      
      if (question.type == QuestionnaireQuestionType.shortAnswer) {
        _answerControllers[questionId] = TextEditingController(text: widget.event.getAnswerForQuestionForUser(widget.user, questionId));
      } else {
        _selectedDropdownAnswers[questionId] = widget.event.getAnswerForQuestionForUser(widget.user, questionId);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValid() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Check all required questions are answered
    for (var entry in _questions) {
      final questionId = entry.key;
      final question = entry.value;

      if (question.required) {
        if (question.type == QuestionnaireQuestionType.shortAnswer) {
          final answer = _answerControllers[questionId]?.text.trim() ?? '';
          if (answer.isEmpty) {
            return false;
          }
        } else {
          final answer = _selectedDropdownAnswers[questionId];
          if (answer == null || answer.isEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Map<String, String> _getAnswers() {
    final Map<String, String> answers = {};
    
    for (var entry in _questions) {
      final questionId = entry.key;
      final question = entry.value;

      if (question.type == QuestionnaireQuestionType.shortAnswer) {
        final answer = _answerControllers[questionId]?.text.trim() ?? '';
        if (answer.isNotEmpty) {
          answers[questionId] = answer;
        }
      } else {
        final answer = _selectedDropdownAnswers[questionId];
        if (answer != null && answer.isNotEmpty) {
          answers[questionId] = answer;
        }
      }
    }
    
    return answers;
  }

  void _handleContinue() {
    if (_isValid()) {
      final answers = _getAnswers();
      widget.onComplete(answers);
    } else {
      // Scroll to first invalid question and show error
      _scrollToFirstInvalidQuestion();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all required questions'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _scrollToFirstInvalidQuestion() {
    for (int i = 0; i < _questions.length; i++) {
      final entry = _questions[i];
      final question = entry.value;
      
      if (question.required) {
        bool isAnswered = false;
        if (question.type == QuestionnaireQuestionType.shortAnswer) {
          final answer = _answerControllers[entry.key]?.text.trim() ?? '';
          isAnswered = answer.isNotEmpty;
        } else {
          final answer = _selectedDropdownAnswers[entry.key];
          isAnswered = answer != null && answer.isNotEmpty;
        }
        
        if (!isAnswered) {
          setState(() {
            _currentQuestionIndex = i;
          });
          break;
        }
      }
    }
  }

  Widget _buildProgressIndicator() {
    if (_questions.isEmpty) return const SizedBox.shrink();
    
    final theme = ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context);
    final totalQuestions = _questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;

    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProText(
                'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              ProText(
                '${(_currentQuestionIndex + 1)}/$totalQuestions',
                textStyle: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          if (widget.user.id != null)
            ...[
              const SizedBox(height: generalAppLevelPadding),
              RSVPingAsWidget(user: widget.user),
              const SizedBox(height: generalAppLevelPadding / 2),
            ]
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    if (index >= _questions.length) return const SizedBox.shrink();
    
    final entry = _questions[index];
    final questionId = entry.key;
    final question = entry.value;
    final theme = ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context);
    final isCurrentQuestion = index == _currentQuestionIndex;

    return AnimatedOpacity(
      opacity: isCurrentQuestion ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible: isCurrentQuestion,
        child: ProCard(
          elevation: 10,
          surfaceTintColor: Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              Row(
                children: [
                  Expanded(
                    child: ProText(
                      question.question,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (question.required)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ProText(
                        'Required',
                        textStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Answer input based on type
              if (question.type == QuestionnaireQuestionType.shortAnswer)
                _buildShortAnswerField(questionId, question, theme)
              else
                _buildDropdownField(questionId, question, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerField(
    String questionId,
    QuestionnaireQuestion question,
    ThemeData theme,
  ) {
    return ProTextField(
      label: 'Your answer',
      hintText: 'Type your answer here...',
      textEditingController: _answerControllers[questionId],
      keyboardType: TextInputType.text,
      multiline: true,
      maxLines: 4,
      onValidationCallback: question.required
          ? (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField(
    String questionId,
    QuestionnaireQuestion question,
    ThemeData theme,
  ) {
    final selectedValue = _selectedDropdownAnswers[questionId];
    final hasError = question.required && selectedValue == null;
    int optionIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: question.options.contains(selectedValue != null && selectedValue.isNotEmpty ? selectedValue.split('.')[1].trim() : null) ? selectedValue : null,
          decoration: InputDecoration(
            labelText: 'Select an option',
            hintText: 'Choose an option...',
            errorText: hasError ? 'Please select an option' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: question.options.map((String option) {
            optionIndex++;
            return DropdownMenuItem<String>(
              value: "${optionIndex}. ${option}",
              child: ProText(
                "${option}",
                textStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDropdownAnswers[questionId] = value;
            });
          },
          validator: question.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    final canGoBack = _currentQuestionIndex > 0;
    final canGoForward = _currentQuestionIndex < _questions.length - 1;

    return Row(
      children: [
        if (canGoBack)
          Expanded(
            child: ProOutlinedButton(
              child: ProText(
                'Previous',
                textStyle: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
              isBig: true,
              onPressed: () {
                setState(() {
                  _currentQuestionIndex--;
                });
              },
            ),
          ),
        if (canGoBack && canGoForward)
          const SizedBox(width: generalAppLevelPadding),
        if (canGoForward)
          Expanded(
            child: ProPrimaryButton(
              ProText(
                'Next',
                textStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              isBig: true,
              onPressed: () {
                // Validate current question if required
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                
                setState(() {
                  _currentQuestionIndex++;
                });
              },
            ),
          )
        else
          Expanded(
            child: ProPrimaryButton(
              ProText(
                'Continue',
                textStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              isBig: true,
              onPressed: _handleContinue,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context);

    if (_questions.isEmpty) {
      return SafeArea(
        child: Theme(
          data: theme,
          child: Center(
            child: ProText(
              'No questions to answer',
              textStyle: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      key: const ValueKey('questionnaire'),
      child: Theme(
        data: theme,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(generalAppLevelPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProText(
                        'Answer a few questions',
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProText(
                        'Your answers help the host plan and will be visible to the host and other guests.',
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: generalAppLevelPadding,
                  ),
                  child: _buildProgressIndicator(),
                ),
                
                const SizedBox(height: generalAppLevelPadding),
                
                // Current question
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: generalAppLevelPadding,
                  ),
                  child: _buildQuestionCard(_currentQuestionIndex),
                ),
                
                const SizedBox(height: generalAppLevelPadding),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(generalAppLevelPadding),
                  child: _buildNavigationButtons(theme),
                ),
                
                const SizedBox(height: generalAppLevelPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

