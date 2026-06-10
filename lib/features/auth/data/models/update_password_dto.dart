class UpdatePasswordDto {
  final String oldPassword;
  final String newPassword;

  UpdatePasswordDto({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}
