class LearningVocabularyItem {
  const LearningVocabularyItem({required this.word, required this.meaning});

  final String word;
  final String meaning;

  factory LearningVocabularyItem.fromJson(Map<String, dynamic> json) {
    return LearningVocabularyItem(
      word: (json['word'] ?? json['Word'] ?? '').toString(),
      meaning: (json['meaning'] ?? json['Meaning'] ?? '').toString(),
    );
  }
}

class LearningCourseItem {
  const LearningCourseItem({required this.courseId, required this.title});

  final String courseId;
  final String title;

  factory LearningCourseItem.fromJson(Map<String, dynamic> json) {
    return LearningCourseItem(
      courseId: (json['courseId'] ?? json['CourseId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Course').toString(),
    );
  }
}

class CourseDetailModel {
  const CourseDetailModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String courseId;
  final String title;
  final String description;
  final String imageUrl;

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      courseId: (json['courseId'] ?? json['CourseId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Course').toString(),
      description: (json['description'] ?? json['Description'] ?? '')
          .toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? '').toString(),
    );
  }
}

class UserProfileModel {
  const UserProfileModel({
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String fullName;
  final String email;
  final String role;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: (json['fullName'] ?? json['FullName'] ?? '-').toString(),
      email: (json['email'] ?? json['Email'] ?? '-').toString(),
      role: (json['role'] ?? json['Role'] ?? '-').toString(),
    );
  }
}
