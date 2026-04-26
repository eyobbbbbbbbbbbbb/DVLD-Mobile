class LicenseClass {
  final int id;
  final String name;
  final String description;
  final int minimumAge;
  final int validityLength;
  final double fees;

  LicenseClass({
    required this.id,
    required this.name,
    required this.description,
    required this.minimumAge,
    required this.validityLength,
    required this.fees,
  });

  factory LicenseClass.fromJson(Map<String, dynamic> json) {
    return LicenseClass(
      id: json['licenseClassID'] ?? 0,
      name: json['className'] ?? '',
      description: json['classDescription'] ?? '',
      minimumAge: json['minimumAllowedAge'] ?? 18,
      validityLength: json['defaultValidityLength'] ?? 10,
      fees: (json['classFees'] ?? 0).toDouble(),
    );
  }
}
