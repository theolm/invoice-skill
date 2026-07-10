import 'bank.dart';

class BankInfo {
  final String beneficiaryName;
  final Bank main;
  final Bank? intermediary;

  BankInfo(this.beneficiaryName, this.main, this.intermediary);

  factory BankInfo.fromJson(Map<String, dynamic> json) => BankInfo(
        json['beneficiaryName'] as String,
        Bank.fromJson(json['main'] as Map<String, dynamic>),
        json['intermediary'] != null
            ? Bank.fromJson(json['intermediary'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'beneficiaryName': beneficiaryName,
        'main': main.toJson(),
        'intermediary': intermediary?.toJson(),
      };
}
