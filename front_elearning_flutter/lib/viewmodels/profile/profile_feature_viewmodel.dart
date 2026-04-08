import '../../core/result/result.dart';
import '../../models/learning/course_models.dart';
import '../../repositories/profile/profile_repository.dart';

class ProfileFeatureViewModel {
  ProfileFeatureViewModel(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfileModel>> profile() async {
    return _repository.profile();
  }
}
