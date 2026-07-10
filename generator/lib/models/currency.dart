class Currency {
  final String name;
  final String cc;
  final String symbol;

  Currency(this.name, this.cc, this.symbol);

  factory Currency.fromJson(Map<String, dynamic> json) =>
      Currency(json['name'] as String, json['cc'] as String, json['symbol'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'cc': cc, 'symbol': symbol};
}
