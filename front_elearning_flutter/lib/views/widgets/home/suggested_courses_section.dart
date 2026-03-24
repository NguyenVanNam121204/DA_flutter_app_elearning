import 'package:flutter/material.dart';

import '../../../models/home_course_model.dart';
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
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('Chua co khoa hoc de xuat.'),
            ),
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


