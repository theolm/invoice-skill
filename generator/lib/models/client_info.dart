class ClientInfo {
  final String name;
  final String address;

  ClientInfo(this.name, this.address);

  factory ClientInfo.fromJson(Map<String, dynamic> json) =>
      ClientInfo(json['name'] as String, json['address'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'address': address};
}
