import 'package:flutter/material.dart';

import '../../../models/home/home_course_model.dart';

class SuggestedCourseCard extends StatelessWidget {
  const SuggestedCourseCard({super.key, required this.course});

  final HomeCourseModel course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              color: const Color(0xFFE8F2FF),
              child: course.imageUrl == null || course.imageUrl!.trim().isEmpty
                  ? const Icon(Icons.menu_book_rounded, size: 42)
                  : Image.network(
                      course.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.menu_book_rounded, size: 42);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (course.price != null)
                    Text(
                      '${course.price!.toStringAsFixed(0)} VND',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: course.isEnrolled
                          ? const Color(0xFFE5F8EF)
                          : const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      course.isEnrolled ? 'Đã đăng ký' : 'Khóa học đề xuất',
                      style: TextStyle(
                        color: course.isEnrolled
                            ? const Color(0xFF1C8F55)
                            : const Color(0xFF235EA8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



