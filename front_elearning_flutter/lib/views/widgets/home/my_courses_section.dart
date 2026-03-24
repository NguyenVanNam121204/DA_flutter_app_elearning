import 'package:flutter/material.dart';

import '../../../models/home_course_model.dart';
import 'course_progress_card.dart';
import 'home_section_title.dart';

class MyCoursesSection extends StatelessWidget {
  const MyCoursesSection({
    super.key,
    required this.isLoading,
    required this.courses,
  });

  final bool isLoading;
  final List<HomeCourseModel> courses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: 'Khoa hoc cua bạn'),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (courses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('Bạn chưa đăng ký khóa học nào.'),
            ),
          )
        else
          ...courses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseProgressCard(
                title: course.title,
                progress: (course.progressPercentage / 100).clamp(0, 1),
                lessonCount: course.totalLessons,
              ),
            ),
          ),
      ],
    );
  }
}


