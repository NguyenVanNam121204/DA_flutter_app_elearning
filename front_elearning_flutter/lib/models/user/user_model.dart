class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? json['FirstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? json['LastName'] ?? '').toString();
    final fullName = '$firstName $lastName'.trim();
    final displayName = (json['displayName'] ?? json['DisplayName'] ?? '')
        .toString();

    return UserModel(
      id: (json['id'] ?? json['Id'] ?? json['userId'] ?? json['UserId'] ?? '')
          .toString(),
      fullName: fullName.isEmpty
          ? (displayName.isEmpty
                ? (json['fullName'] ?? json['FullName'] ?? '').toString()
                : displayName)
          : fullName,
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? json['AvatarUrl'])?.toString(),
    );
  }
}
