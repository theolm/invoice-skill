class Bank {
  final String iban;
  final String swift;
  final String bankName;
  final String bankAddress;

  Bank(this.iban, this.swift, this.bankName, this.bankAddress);

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        json['iban'] as String,
        json['swift'] as String,
        json['bankName'] as String,
        json['bankAddress'] as String,
      );

  Map<String, dynamic> toJson() => {
        'iban': iban,
        'swift': swift,
        'bankName': bankName,
        'bankAddress': bankAddress,
      };
}
