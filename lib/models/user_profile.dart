class UserProfile {
  final int age;
  final String gender;
  final String firstName;
  final String lastName;
  final String occupation;
  final String incomeRange;

  UserProfile({
    required this.age,
    required this.gender,
    required this.firstName,
    required this.lastName,
    required this.occupation,
    required this.incomeRange,
  });

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'firstName': firstName,
    'lastName': lastName,
    'occupation': occupation,
    'incomeRange': incomeRange,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    age: json['age'] as int,
    gender: json['gender'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    occupation: json['occupation'] as String,
    incomeRange: json['incomeRange'] as String,
  );
}