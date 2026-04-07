import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class TeacherSubmissionDetailScreen extends ConsumerWidget {
  const TeacherSubmissionDetailScreen({required this.submissionId, super.key});
  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<Map<String, dynamic>>>(
      future: ref.read(teacherFeatureViewModelProvider).submissionDetail(submissionId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final map = (result as Success<Map<String, dynamic>>).value;
        final userName = (map['userName'] ?? map['UserName'] ?? 'Hoc vien').toString();
        final avatar = (map['userAvatarUrl'] ?? map['UserAvatarUrl'] ?? '').toString();
        final content = (map['textContent'] ?? map['TextContent'] ?? map['content'] ?? '').toString();
        final attachmentUrl = (map['attachmentUrl'] ?? map['AttachmentUrl'] ?? '').toString();
        final submittedAt = (map['submittedAt'] ?? map['SubmittedAt'] ?? '').toString();
        final status = (map['status'] ?? map['Status'] ?? 'N/A').toString();
        final scoreRaw = map['teacherScore'] ?? map['TeacherScore'] ?? map['score'] ?? map['Score'];
        final totalPointsRaw = map['totalPoints'] ?? map['TotalPoints'] ?? 10;
        final feedback = (map['teacherFeedback'] ?? map['TeacherFeedback'] ?? map['feedback'] ?? map['Feedback'] ?? '')
            .toString();
        final score = scoreRaw is num ? scoreRaw.toDouble() : double.tryParse(scoreRaw?.toString() ?? '');
        final totalPoints = totalPointsRaw is num
            ? totalPointsRaw.toDouble()
            : double.tryParse(totalPointsRaw.toString()) ?? 10;
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
                  subtitle: Text(submittedAt.isEmpty ? 'Khong ro thoi gian nop' : submittedAt),
                ),
              ),
              const SizedBox(height: 12),
              if (score != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text('Diem: ${score.toStringAsFixed(1)}/${totalPoints.toStringAsFixed(1)}'),
                    subtitle: Text('Ti le: ${((score / totalPoints) * 100).toStringAsFixed(1)}%'),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Noi dung bai lam', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(content.isEmpty ? 'Khong co noi dung' : content),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('${content.trim().length} ky tu',
                            style: Theme.of(context).textTheme.bodySmall),
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
                        await Clipboard.setData(ClipboardData(text: attachmentUrl));
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
    );
  }
}
