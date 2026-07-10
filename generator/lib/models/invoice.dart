import 'package:intl/intl.dart';

import 'bank_info.dart';
import 'client_info.dart';
import 'company_info.dart';
import 'service_info.dart';

class Invoice {
  final int id;
  final int issueDate;
  final int dueDate;
  final ServiceInfo service;
  final CompanyInfo companyInfo;
  final ClientInfo clientInfo;
  final BankInfo bankInfo;
  final int createdAt;
  final int updatedAt;

  Invoice(
    this.id,
    this.issueDate,
    this.dueDate,
    this.service,
    this.companyInfo,
    this.clientInfo,
    this.bankInfo,
    this.createdAt,
    this.updatedAt,
  );

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        json['id'] as int,
        json['issueDate'] as int,
        json['dueDate'] as int,
        ServiceInfo.fromJson(json['service'] as Map<String, dynamic>),
        CompanyInfo.fromJson(json['companyInfo'] as Map<String, dynamic>),
        ClientInfo.fromJson(json['clientInfo'] as Map<String, dynamic>),
        BankInfo.fromJson(json['bankInfo'] as Map<String, dynamic>),
        json['createdAt'] as int? ?? 0,
        json['updatedAt'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'issueDate': issueDate,
        'dueDate': dueDate,
        'service': service.toJson(),
        'companyInfo': companyInfo.toJson(),
        'clientInfo': clientInfo.toJson(),
        'bankInfo': bankInfo.toJson(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String formattedQuantity() => service.formattedQuantity();

  String formattedPrice(String symbol) =>
      NumberFormat.currency(locale: 'en_US', symbol: symbol).format(service.price);

  String formattedTotalPrice(String symbol) {
    final totalPrice = service.price * service.quantity;
    return NumberFormat.currency(locale: 'en_US', symbol: symbol).format(totalPrice);
  }

  String formattedAddress() {
    if (companyInfo.address == null) {
      return "no address";
    } else {
      return companyInfo.address!.toString();
    }
  }
}
