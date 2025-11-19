class UserProfile {
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final String occupation;
  final String incomeRange;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.occupation,
    required this.incomeRange,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'incomeRange': incomeRange,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      occupation: json['occupation'] as String,
      incomeRange: json['incomeRange'] as String,
    );
  }

  String get fullName => '$firstName $lastName';
}
