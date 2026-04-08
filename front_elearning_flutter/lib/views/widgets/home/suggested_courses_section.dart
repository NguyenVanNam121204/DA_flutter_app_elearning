import 'package:flutter/material.dart';

import '../../../models/home/home_course_model.dart';
import 'home_section_title.dart';
import 'suggested_course_card.dart';

class SuggestedCoursesSection extends StatelessWidget {
  const SuggestedCoursesSection({super.key, required this.courses});

  final List<HomeCourseModel> courses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: 'Khóa học đề xuất'),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDE8F7)),
            ),
            child: const Text('Chưa có khóa học đề xuất.'),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return SuggestedCourseCard(course: courses[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
      ],
    );
  }
}
