import 'package:flutter/widgets.dart';

import 'teacher_course_submissions_screen.dart';

class TeacherEssaySubmissionsScreen extends StatelessWidget {
  const TeacherEssaySubmissionsScreen({required this.essayId, super.key});
  final String essayId;

  @override
  Widget build(BuildContext context) {
    return TeacherCourseSubmissionsScreen(essayId: essayId);
  }
}
