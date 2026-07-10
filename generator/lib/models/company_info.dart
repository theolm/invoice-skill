class CompanyInfo {
  final String name;
  final CompanyAddress? address;
  final String email;
  final String ownerName;
  final String? cnpj;

  CompanyInfo(
    this.name,
    this.address,
    this.email,
    this.ownerName,
    this.cnpj,
  );

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
        json['name'] as String,
        json['address'] != null
            ? CompanyAddress.fromJson(json['address'] as Map<String, dynamic>)
            : null,
        json['email'] as String,
        json['ownerName'] as String,
        json['cnpj'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address?.toJson(),
        'email': email,
        'ownerName': ownerName,
        'cnpj': cnpj,
      };
}

class CompanyAddress {
  final String street;
  final String? extraInfo;
  final String neighbourhood;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  CompanyAddress(
    this.street,
    this.extraInfo,
    this.neighbourhood,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  );

  factory CompanyAddress.fromJson(Map<String, dynamic> json) => CompanyAddress(
        json['street'] as String,
        json['extraInfo'] as String?,
        json['neighbourhood'] as String,
        json['city'] as String,
        json['state'] as String,
        json['country'] as String,
        json['zipCode'] as String,
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'extraInfo': extraInfo,
        'neighbourhood': neighbourhood,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
      };

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('$street')
      ..write(extraInfo != null ? ' ${extraInfo}' : '')
      ..write('\n$neighbourhood, $city')
      ..write('\n$state - $country')
      ..write('\nZip-code: $zipCode');
    return buffer.toString();
  }
}
