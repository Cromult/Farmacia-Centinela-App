class ForgotPasswordDto {
  final String email;

  ForgotPasswordDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordDto {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };
}
