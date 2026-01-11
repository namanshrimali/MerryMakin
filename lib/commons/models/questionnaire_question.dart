enum QuestionnaireQuestionType {
  dropdown,
  shortAnswer;

  String get displayName {
    switch (this) {
      case QuestionnaireQuestionType.dropdown:
        return 'Dropdown';
      case QuestionnaireQuestionType.shortAnswer:
        return 'Short Answer';
    }
  }
}

class QuestionnaireQuestion {
  QuestionnaireQuestionType type;
  bool required;
  String question;
  List<String> options; // Only used for dropdown type

  QuestionnaireQuestion({
    required this.type,
    this.required = true,
    required this.question,
    this.options = const [],
  });

  factory QuestionnaireQuestion.fromMap(Map<String, dynamic> map) {
    return QuestionnaireQuestion(
      type: QuestionnaireQuestionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => QuestionnaireQuestionType.shortAnswer,
      ),
      required: map['required'] ?? false,
      question: map['question'] ?? '',
      options: map['options'] != null
          ? List<String>.from(map['options'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'required': required,
      'question': question,
      'options': options,
    };
  }

  QuestionnaireQuestion copyWith({
    QuestionnaireQuestionType? type,
    bool? required,
    String? question,
    List<String>? options,
  }) {
    return QuestionnaireQuestion(
      type: type ?? this.type,
      required: required ?? this.required,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }
}

