class TeacherSubmissionListItemModel {
  const TeacherSubmissionListItemModel({
    required this.submissionId,
    required this.studentName,
    required this.status,
    required this.score,
  });

  final String submissionId;
  final String studentName;
  final String status;
  final String score;

  factory TeacherSubmissionListItemModel.fromJson(Map<String, dynamic> json) {
    return TeacherSubmissionListItemModel(
      submissionId: (json['submissionId'] ?? json['SubmissionId'] ?? '')
          .toString(),
      studentName: (json['studentName'] ?? json['StudentName'] ?? 'Hoc vien')
          .toString(),
      status: (json['status'] ?? json['Status'] ?? 'N/A').toString(),
      score:
          (json['teacherScore'] ??
                  json['TeacherScore'] ??
                  json['score'] ??
                  json['Score'] ??
                  '-')
              .toString(),
    );
  }
}

class TeacherSubmissionDetailModel {
  const TeacherSubmissionDetailModel({
    required this.userName,
    required this.userAvatarUrl,
    required this.textContent,
    required this.attachmentUrl,
    required this.submittedAt,
    required this.status,
    required this.teacherScore,
    required this.totalPoints,
    required this.teacherFeedback,
  });

  final String userName;
  final String userAvatarUrl;
  final String textContent;
  final String attachmentUrl;
  final String submittedAt;
  final String status;
  final double? teacherScore;
  final double totalPoints;
  final String teacherFeedback;

  factory TeacherSubmissionDetailModel.fromJson(Map<String, dynamic> json) {
    final scoreRaw =
        json['teacherScore'] ??
        json['TeacherScore'] ??
        json['score'] ??
        json['Score'];
    final totalPointsRaw = json['totalPoints'] ?? json['TotalPoints'] ?? 10;
    return TeacherSubmissionDetailModel(
      userName: (json['userName'] ?? json['UserName'] ?? 'Hoc vien').toString(),
      userAvatarUrl: (json['userAvatarUrl'] ?? json['UserAvatarUrl'] ?? '')
          .toString(),
      textContent:
          (json['textContent'] ?? json['TextContent'] ?? json['content'] ?? '')
              .toString(),
      attachmentUrl: (json['attachmentUrl'] ?? json['AttachmentUrl'] ?? '')
          .toString(),
      submittedAt: (json['submittedAt'] ?? json['SubmittedAt'] ?? '')
          .toString(),
      status: (json['status'] ?? json['Status'] ?? 'N/A').toString(),
      teacherScore: scoreRaw is num
          ? scoreRaw.toDouble()
          : double.tryParse(scoreRaw?.toString() ?? ''),
      totalPoints: totalPointsRaw is num
          ? totalPointsRaw.toDouble()
          : double.tryParse(totalPointsRaw.toString()) ?? 10,
      teacherFeedback:
          (json['teacherFeedback'] ??
                  json['TeacherFeedback'] ??
                  json['feedback'] ??
                  json['Feedback'] ??
                  '')
              .toString(),
    );
  }
}
