class CreatePatientUserProfileDto {
  final CreateUserDto user;
  final CreateProfileDto profile;
  final CreatePatientDto patient;

  CreatePatientUserProfileDto({
    required this.user,
    required this.profile,
    required this.patient,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'profile': profile.toJson(),
      'patient': patient.toJson(),
    };
  }
}

class CreateUserDto {
  final String email;
  final String password;
  final bool isActive;

  CreateUserDto({
    required this.email,
    required this.password,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'is_active': isActive,
    };
  }
}

class CreateProfileDto {
  final String name;
  final String lastname;
  final String birthdate;
  final String birthplace;
  final String nationality;
  final String ci;
  final String gender;

  CreateProfileDto({
    required this.name,
    required this.lastname,
    required this.birthdate,
    required this.birthplace,
    required this.nationality,
    required this.ci,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'nationality': nationality,
      'ci': ci,
      'gender': gender,
    };
  }
}

class CreatePatientDto {
  final String hospital;

  CreatePatientDto({
    required this.hospital,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospital': hospital,
    };
  }
}
