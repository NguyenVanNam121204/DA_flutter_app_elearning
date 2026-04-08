class QuizOptionModel {
  const QuizOptionModel({required this.optionId, required this.text});

  final String optionId;
  final String text;

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      optionId:
          (json['answerId'] ??
                  json['AnswerId'] ??
                  json['optionId'] ??
                  json['OptionId'] ??
                  '')
              .toString(),
      text:
          (json['answerText'] ??
                  json['AnswerText'] ??
                  json['optionText'] ??
                  json['OptionText'] ??
                  '')
              .toString(),
    );
  }
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.questionId,
    required this.content,
    required this.type,
    required this.options,
  });

  final String questionId;
  final String content;
  final int type;
  final List<QuizOptionModel> options;

  bool get isTextQuestion => type == 4;
  bool get isMultiChoice => type == 2;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] ?? json['Type'] ?? 1;
    final optionsRaw =
        (json['options'] ??
                json['Options'] ??
                json['answers'] ??
                json['Answers'])
            as List? ??
        const [];
    return QuizQuestionModel(
      questionId: (json['questionId'] ?? json['QuestionId'] ?? '').toString(),
      content:
          (json['content'] ??
                  json['Content'] ??
                  json['questionText'] ??
                  json['QuestionText'] ??
                  '')
              .toString(),
      type: typeRaw is int ? typeRaw : int.tryParse(typeRaw.toString()) ?? 1,
      options: optionsRaw
          .whereType<Map<String, dynamic>>()
          .map(QuizOptionModel.fromJson)
          .toList(),
    );
  }
}

class QuizDetailModel {
  const QuizDetailModel({
    required this.quizId,
    required this.title,
    required this.questions,
  });

  const QuizDetailModel.empty()
    : quizId = '',
      title = 'Quiz',
      questions = const [];

  final String quizId;
  final String title;
  final List<QuizQuestionModel> questions;

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    final directQuestions =
        ((json['questions'] ?? json['Questions']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(QuizQuestionModel.fromJson)
            .where((q) => q.questionId.isNotEmpty)
            .toList() ??
        const <QuizQuestionModel>[];

    if (directQuestions.isNotEmpty) {
      return QuizDetailModel(
        quizId: (json['quizId'] ?? json['QuizId'] ?? '').toString(),
        title: (json['title'] ?? json['Title'] ?? 'Quiz').toString(),
        questions: directQuestions,
      );
    }

    final sections =
        ((json['quizSections'] ?? json['QuizSections']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    final flattened = <QuizQuestionModel>[];
    for (final section in sections) {
      final items =
          ((section['items'] ?? section['Items']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const <Map<String, dynamic>>[];
      for (final item in items) {
        if (item['questionId'] != null || item['QuestionId'] != null) {
          final question = QuizQuestionModel.fromJson(item);
          if (question.questionId.isNotEmpty) {
            flattened.add(question);
          }
          continue;
        }
        final nestedQuestions =
            ((item['questions'] ?? item['Questions']) as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(QuizQuestionModel.fromJson)
                .where((q) => q.questionId.isNotEmpty)
                .toList() ??
            const <QuizQuestionModel>[];
        flattened.addAll(nestedQuestions);
      }
    }

    return QuizDetailModel(
      quizId: (json['quizId'] ?? json['QuizId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Quiz').toString(),
      questions: flattened,
    );
  }
}

class QuizAttemptStartModel {
  const QuizAttemptStartModel({
    required this.attemptId,
    required this.durationMinutes,
  });

  final String attemptId;
  final int? durationMinutes;

  factory QuizAttemptStartModel.fromJson(Map<String, dynamic> json) {
    final durationRaw =
        json['duration'] ??
        json['Duration'] ??
        json['timeLimit'] ??
        json['TimeLimit'];
    final duration = durationRaw is int
        ? durationRaw
        : int.tryParse(durationRaw?.toString() ?? '');
    return QuizAttemptStartModel(
      attemptId:
          (json['quizAttemptId'] ??
                  json['QuizAttemptId'] ??
                  json['attemptId'] ??
                  json['AttemptId'] ??
                  '')
              .toString(),
      durationMinutes: duration,
    );
  }
}
