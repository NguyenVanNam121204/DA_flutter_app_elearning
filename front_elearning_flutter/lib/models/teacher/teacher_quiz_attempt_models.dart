class TeacherQuizAttemptListItemModel {
  const TeacherQuizAttemptListItemModel({
    required this.attemptId,
    required this.studentName,
    required this.totalScore,
    required this.percentage,
  });

  final String attemptId;
  final String studentName;
  final String totalScore;
  final String percentage;

  factory TeacherQuizAttemptListItemModel.fromJson(Map<String, dynamic> json) {
    return TeacherQuizAttemptListItemModel(
      attemptId: (json['attemptId'] ?? json['AttemptId'] ?? '').toString(),
      studentName: (json['studentName'] ?? json['StudentName'] ?? 'Hoc vien')
          .toString(),
      totalScore: (json['totalScore'] ?? json['TotalScore'] ?? '-').toString(),
      percentage: (json['percentage'] ?? json['Percentage'] ?? '-').toString(),
    );
  }
}

class TeacherQuizAttemptQuestionModel {
  const TeacherQuizAttemptQuestionModel({
    required this.questionText,
    required this.isCorrect,
    required this.userAnswerText,
    required this.correctAnswerText,
  });

  final String questionText;
  final bool isCorrect;
  final String userAnswerText;
  final String correctAnswerText;

  factory TeacherQuizAttemptQuestionModel.fromJson(Map<String, dynamic> json) {
    return TeacherQuizAttemptQuestionModel(
      questionText: (json['questionText'] ?? json['QuestionText'] ?? '')
          .toString(),
      isCorrect: (json['isCorrect'] ?? json['IsCorrect'] ?? false) == true,
      userAnswerText:
          (json['userAnswerText'] ?? json['UserAnswerText'] ?? 'Chua tra loi')
              .toString(),
      correctAnswerText:
          (json['correctAnswerText'] ?? json['CorrectAnswerText'] ?? '')
              .toString(),
    );
  }
}

class TeacherQuizAttemptDetailModel {
  const TeacherQuizAttemptDetailModel({
    required this.userName,
    required this.email,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.timeSpentSeconds,
    required this.startedAt,
    required this.submittedAt,
    required this.status,
    required this.questions,
  });

  final String userName;
  final String email;
  final String totalScore;
  final String maxScore;
  final String percentage;
  final String timeSpentSeconds;
  final String startedAt;
  final String submittedAt;
  final String status;
  final List<TeacherQuizAttemptQuestionModel> questions;

  factory TeacherQuizAttemptDetailModel.fromJson(Map<String, dynamic> json) {
    final questionsRaw =
        (json['questions'] ?? json['Questions']) as List? ?? const [];
    return TeacherQuizAttemptDetailModel(
      userName: (json['userName'] ?? json['UserName'] ?? 'Hoc vien').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      totalScore: (json['totalScore'] ?? json['TotalScore'] ?? '-').toString(),
      maxScore: (json['maxScore'] ?? json['MaxScore'] ?? '-').toString(),
      percentage: (json['percentage'] ?? json['Percentage'] ?? '-').toString(),
      timeSpentSeconds:
          (json['timeSpentSeconds'] ?? json['TimeSpentSeconds'] ?? '0')
              .toString(),
      startedAt: (json['startedAt'] ?? json['StartedAt'] ?? '').toString(),
      submittedAt: (json['submittedAt'] ?? json['SubmittedAt'] ?? '')
          .toString(),
      status: (json['status'] ?? json['Status'] ?? 'N/A').toString(),
      questions: questionsRaw
          .whereType<Map<String, dynamic>>()
          .map(TeacherQuizAttemptQuestionModel.fromJson)
          .toList(),
    );
  }
}
