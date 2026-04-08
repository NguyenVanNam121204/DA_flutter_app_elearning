class AssignmentQuizItemModel {
  const AssignmentQuizItemModel({required this.quizId, required this.title});

  final String quizId;
  final String title;

  factory AssignmentQuizItemModel.fromJson(Map<String, dynamic> json) {
    return AssignmentQuizItemModel(
      quizId: (json['quizId'] ?? json['QuizId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Quiz').toString(),
    );
  }
}

class AssignmentEssayItemModel {
  const AssignmentEssayItemModel({required this.essayId, required this.title});

  final String essayId;
  final String title;

  factory AssignmentEssayItemModel.fromJson(Map<String, dynamic> json) {
    return AssignmentEssayItemModel(
      essayId: (json['essayId'] ?? json['EssayId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Essay').toString(),
    );
  }
}

class AssignmentDetailModel {
  const AssignmentDetailModel({required this.quizzes, required this.essays});

  final List<AssignmentQuizItemModel> quizzes;
  final List<AssignmentEssayItemModel> essays;

  factory AssignmentDetailModel.fromJson(Map<String, dynamic> json) {
    final quizzesRaw =
        (json['quizzes'] ?? json['Quizzes']) as List? ?? const [];
    final essaysRaw = (json['essays'] ?? json['Essays']) as List? ?? const [];

    return AssignmentDetailModel(
      quizzes: quizzesRaw
          .whereType<Map<String, dynamic>>()
          .map(AssignmentQuizItemModel.fromJson)
          .toList(),
      essays: essaysRaw
          .whereType<Map<String, dynamic>>()
          .map(AssignmentEssayItemModel.fromJson)
          .toList(),
    );
  }
}

class EssayDetailModel {
  const EssayDetailModel({required this.title, required this.instruction});

  final String title;
  final String instruction;

  factory EssayDetailModel.fromJson(Map<String, dynamic> json) {
    return EssayDetailModel(
      title: (json['title'] ?? json['Title'] ?? 'Essay').toString(),
      instruction: (json['instruction'] ?? json['Instruction'] ?? '')
          .toString(),
    );
  }
}
