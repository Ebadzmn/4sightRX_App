class SignUpRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String organizationId;
  final String password;

  const SignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.organizationId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'organizationId': organizationId,
      'password': password,
    };
  }
}
