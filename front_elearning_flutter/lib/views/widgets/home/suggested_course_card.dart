import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../models/home/home_course_model.dart';
import '../common/catalunya_card.dart';

class SuggestedCourseCard extends StatelessWidget {
  const SuggestedCourseCard({super.key, required this.course});

  final HomeCourseModel course;

  String _formatPrice(double? price) {
    if (price == null || price == 0) {
      return 'Miễn phí';
    }
    return '${price.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final courseId = course.courseId.toString();

    return CatalunyaCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            context.push('${RoutePaths.courseDetail}?courseId=$courseId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  child:
                      course.imageUrl == null || course.imageUrl!.trim().isEmpty
                      ? Container(
                          color: const Color(0xFFE8F2FF),
                          alignment: Alignment.center,
                          child: const Icon(Icons.menu_book_rounded, size: 42),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            course.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFE8F2FF),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 42,
                                ),
                              );
                            },
                          ),
                        ),
                ),
                if (course.isEnrolled)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Đã tham gia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
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
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(course.price),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push(
                        '${RoutePaths.courseDetail}?courseId=$courseId',
                      ),
                      child: Text(
                        course.isEnrolled ? 'Vào học ngay' : 'Đăng ký ngay',
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
