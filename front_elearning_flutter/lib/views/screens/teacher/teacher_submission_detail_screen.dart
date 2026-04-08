import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/providers.dart';

class TeacherSubmissionDetailScreen extends ConsumerWidget {
  const TeacherSubmissionDetailScreen({required this.submissionId, super.key});
  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(
      teacherSubmissionDetailDataProvider(submissionId),
    );
    return asyncDetail.when(
      data: (detail) {
        final userName = detail.userName;
        final avatar = detail.userAvatarUrl;
        final content = detail.textContent;
        final attachmentUrl = detail.attachmentUrl;
        final submittedAt = detail.submittedAt;
        final status = detail.status;
        final feedback = detail.teacherFeedback;
        final score = detail.teacherScore;
        final totalPoints = detail.totalPoints;
        return Scaffold(
          appBar: AppBar(title: const Text('Chi tiet bai nop')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: avatar.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(avatar))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(userName),
                  subtitle: Text(
                    submittedAt.isEmpty
                        ? 'Không rõ thời gian nộp'
                        : submittedAt,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (score != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(
                      'Diem: ${score.toStringAsFixed(1)}/${totalPoints.toStringAsFixed(1)}',
                    ),
                    subtitle: Text(
                      'Ti le: ${((score / totalPoints) * 100).toStringAsFixed(1)}%',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Noi dung bai lam',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(content.isEmpty ? 'Không có nội dung' : content),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${content.trim().length} ky tu',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.comment),
                    title: const Text('Nhan xet'),
                    subtitle: Text(feedback),
                  ),
                ),
              ],
              if (attachmentUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: const Text('File dinh kem'),
                    subtitle: Text(
                      attachmentUrl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Copy',
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: attachmentUrl),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Da copy link file')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Chip(label: Text('Trang thai: $status')),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
    );
  }
}

