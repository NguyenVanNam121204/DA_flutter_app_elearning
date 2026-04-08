class LessonListItemModel {
  const LessonListItemModel({required this.lessonId, required this.title});

  final String lessonId;
  final String title;

  factory LessonListItemModel.fromJson(Map<String, dynamic> json) {
    return LessonListItemModel(
      lessonId: (json['lessonId'] ?? json['LessonId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Lesson').toString(),
    );
  }
}

class LessonDetailModel {
  const LessonDetailModel({
    required this.lessonId,
    required this.title,
    required this.description,
  });

  final String lessonId;
  final String title;
  final String description;

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      lessonId: (json['lessonId'] ?? json['LessonId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Lesson').toString(),
      description: (json['description'] ?? json['Description'] ?? '')
          .toString(),
    );
  }
}

class LessonModuleItemModel {
  const LessonModuleItemModel({
    required this.moduleId,
    required this.name,
    required this.contentType,
  });

  final String moduleId;
  final String name;
  final int contentType;

  factory LessonModuleItemModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['contentType'] ?? json['ContentType'] ?? 1;
    return LessonModuleItemModel(
      moduleId: (json['moduleId'] ?? json['ModuleId'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? 'Module').toString(),
      contentType: rawType is int
          ? rawType
          : int.tryParse(rawType.toString()) ?? 1,
    );
  }
}

class LessonDetailBundleModel {
  const LessonDetailBundleModel({required this.lesson, required this.modules});

  final LessonDetailModel lesson;
  final List<LessonModuleItemModel> modules;
}

class LessonResultModel {
  const LessonResultModel({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final String score;
  final String correctAnswers;
  final String totalQuestions;

  factory LessonResultModel.fromJson(Map<String, dynamic> json) {
    return LessonResultModel(
      score: (json['score'] ?? json['Score'] ?? '-').toString(),
      correctAnswers: (json['correctAnswers'] ?? json['CorrectAnswers'] ?? '-')
          .toString(),
      totalQuestions: (json['totalQuestions'] ?? json['TotalQuestions'] ?? '-')
          .toString(),
    );
  }
}
