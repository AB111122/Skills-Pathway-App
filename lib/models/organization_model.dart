/// Organization Model for Universities, Firms, and Listing Providers.
class OrganizationModel {
  final String id;
  final String userId;
  final String orgName;
  final String orgType; // University, Corporate Firm, NGO, Govt Body
  final String website;
  final String officialEmail;
  final String? contactPerson;
  final String? phone;
  final String? address;
  final String? city;
  final String? logoUrl;
  final bool isVerified;
  final String? verificationDocumentUrl;
  final String? registrationNumber;

  const OrganizationModel({
    required this.id,
    required this.userId,
    required this.orgName,
    required this.orgType,
    required this.website,
    required this.officialEmail,
    this.contactPerson,
    this.phone,
    this.address,
    this.city,
    this.logoUrl,
    required this.isVerified,
    this.verificationDocumentUrl,
    this.registrationNumber,
  });

  OrganizationModel copyWith({
    String? id,
    String? userId,
    String? orgName,
    String? orgType,
    String? website,
    String? officialEmail,
    String? contactPerson,
    String? phone,
    String? address,
    String? city,
    String? logoUrl,
    bool? isVerified,
    String? verificationDocumentUrl,
    String? registrationNumber,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orgName: orgName ?? this.orgName,
      orgType: orgType ?? this.orgType,
      website: website ?? this.website,
      officialEmail: officialEmail ?? this.officialEmail,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      logoUrl: logoUrl ?? this.logoUrl,
      isVerified: isVerified ?? this.isVerified,
      verificationDocumentUrl:
          verificationDocumentUrl ?? this.verificationDocumentUrl,
      registrationNumber: registrationNumber ?? this.registrationNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orgName': orgName,
      'orgType': orgType,
      'website': website,
      'officialEmail': officialEmail,
      'contactPerson': contactPerson,
      'phone': phone,
      'address': address,
      'city': city,
      'logoUrl': logoUrl,
      'isVerified': isVerified,
      'verificationDocumentUrl': verificationDocumentUrl,
      'registrationNumber': registrationNumber,
    };
  }

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orgName: json['orgName'] as String,
      orgType: json['orgType'] as String,
      website: json['website'] as String,
      officialEmail: json['officialEmail'] as String,
      contactPerson: json['contactPerson'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      verificationDocumentUrl: json['verificationDocumentUrl'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
    );
  }
}
