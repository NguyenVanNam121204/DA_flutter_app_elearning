class LectureListItemModel {
  const LectureListItemModel({required this.lectureId, required this.title});

  final String lectureId;
  final String title;

  factory LectureListItemModel.fromJson(Map<String, dynamic> json) {
    return LectureListItemModel(
      lectureId: (json['lectureId'] ?? json['LectureId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Lecture').toString(),
    );
  }
}

class LectureDetailModel {
  const LectureDetailModel({
    required this.title,
    required this.content,
    required this.videoUrl,
  });

  final String title;
  final String content;
  final String videoUrl;

  factory LectureDetailModel.fromJson(Map<String, dynamic> json) {
    return LectureDetailModel(
      title: (json['title'] ?? json['Title'] ?? 'Lecture').toString(),
      content: (json['content'] ?? json['Content'] ?? '').toString(),
      videoUrl: (json['videoUrl'] ?? json['VideoUrl'] ?? '').toString(),
    );
  }
}
