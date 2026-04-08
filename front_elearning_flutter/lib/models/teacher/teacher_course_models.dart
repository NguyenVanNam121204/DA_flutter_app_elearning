class TeacherCourseModel {
  const TeacherCourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.studentCount,
    required this.imageUrl,
    required this.level,
  });

  final String courseId;
  final String title;
  final String description;
  final String studentCount;
  final String imageUrl;
  final String level;

  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    return TeacherCourseModel(
      courseId: (json['courseId'] ?? json['CourseId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Course').toString(),
      description: (json['description'] ?? json['Description'] ?? '')
          .toString(),
      studentCount: (json['studentCount'] ?? json['StudentCount'] ?? 0)
          .toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? '').toString(),
      level: (json['level'] ?? json['Level'] ?? '').toString(),
    );
  }
}

class TeacherClassStudentModel {
  const TeacherClassStudentModel({required this.fullName, required this.email});

  final String fullName;
  final String email;

  factory TeacherClassStudentModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassStudentModel(
      fullName: (json['fullName'] ?? json['FullName'] ?? 'Hoc vien').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
    );
  }
}

class TeacherLessonDetailModel {
  const TeacherLessonDetailModel({
    required this.title,
    required this.description,
    required this.orderIndex,
  });

  final String title;
  final String description;
  final String orderIndex;

  factory TeacherLessonDetailModel.fromJson(Map<String, dynamic> json) {
    return TeacherLessonDetailModel(
      title: (json['title'] ?? json['Title'] ?? 'Lesson').toString(),
      description: (json['description'] ?? json['Description'] ?? '')
          .toString(),
      orderIndex: (json['orderIndex'] ?? json['OrderIndex'] ?? '').toString(),
    );
  }
}
