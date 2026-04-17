import 'package:flutter/material.dart';

import '../../../models/home/home_course_model.dart';
import '../common/catalunya_card.dart';
import 'home_section_title.dart';
import 'suggested_course_card.dart';

class SuggestedCoursesSection extends StatelessWidget {
  const SuggestedCoursesSection({super.key, required this.courses});

  final List<HomeCourseModel> courses;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 700 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: 'Danh sách khóa học hệ thống'),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          const CatalunyaCard(child: Text('Chưa có khóa học hệ thống.'))
        else
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: courses.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (context, index) {
              return SuggestedCourseCard(course: courses[index]);
            },
          ),
      ],
    );
  }
}
