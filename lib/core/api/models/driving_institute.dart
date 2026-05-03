class DrivingInstitute {
  final int id;
  final String name;
  final String address;
  final String city;
  final String region;
  final String phone;
  final String? email;
  final String managerName;
  final int capacity;

  DrivingInstitute({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.region,
    required this.phone,
    this.email,
    required this.managerName,
    required this.capacity,
  });

  factory DrivingInstitute.fromJson(Map<String, dynamic> json) {
    return DrivingInstitute(
      id: json['instituteID'] ?? 0,
      name: json['instituteName'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      managerName: json['managerName'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }
}
