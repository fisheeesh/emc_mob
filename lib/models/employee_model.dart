class Employee {
  final int id;
  final String email;
  final String gender;
  final String workStyle;
  final String jobType;
  final String position;
  final String? avatar;
  final String? birthdate;
  final String? phone;
  final String fullName;
  final String accType;
  final String departmentName;
  final String createdAt;

  Employee({
    required this.id,
    required this.email,
    required this.gender,
    required this.workStyle,
    required this.jobType,
    required this.position,
    this.avatar,
    required this.birthdate,
    required this.phone,
    required this.fullName,
    required this.accType,
    required this.departmentName,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      email: json['email'],
      gender: json['gender'],
      workStyle: json['workStyle'],
      jobType: json['jobType'],
      position: json['position'],
      avatar: json['avatar'],
      birthdate: json['birthdate'],
      phone: json['phone'],
      fullName: json['fullName'],
      accType: json['accType'],
      departmentName: json['department']['name'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'gender': gender,
      'workStyle': workStyle,
      'jobType': jobType,
      'position': position,
      'avatar': avatar,
      'birthdate': birthdate,
      'phone': phone,
      'fullName': fullName,
      'accType': accType,
      'departmentName': departmentName,
      'createdAt': createdAt,
    };
  }
}