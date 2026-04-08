import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import 'teacher_feature_viewmodel.dart';

class TeacherCreateCourseState {
  const TeacherCreateCourseState({
    this.preview = false,
    this.saving = false,
  });

  final bool preview;
  final bool saving;

  TeacherCreateCourseState copyWith({
    bool? preview,
    bool? saving,
  }) {
    return TeacherCreateCourseState(
      preview: preview ?? this.preview,
      saving: saving ?? this.saving,
    );
  }
}

class TeacherCreateCourseViewModel extends StateNotifier<TeacherCreateCourseState> {
  TeacherCreateCourseViewModel(this._feature)
      : super(const TeacherCreateCourseState());

  final TeacherFeatureViewModel _feature;

  void togglePreview() {
    state = state.copyWith(preview: !state.preview);
  }

  Future<String> createCourse({
    required String title,
    required String description,
    required int maxStudent,
    required String imageUrl,
  }) async {
    state = state.copyWith(saving: true);
    final res = await _feature.createCourse({
      'Title': title,
      'Description': description,
      'MaxStudent': maxStudent,
      'Type': 2,
      if (imageUrl.isNotEmpty) 'ImageUrl': imageUrl,
    });
    state = state.copyWith(saving: false);
    return switch (res) {
      Success() => 'Tao khoa hoc thanh cong',
      Failure(:final error) => error.message,
    };
  }
}

