import 'currency.dart';

class ServiceInfo {
  final String description;
  final double quantity;
  final Currency currency;
  final double price;

  ServiceInfo(this.description, this.quantity, this.currency, this.price);

  factory ServiceInfo.fromJson(Map<String, dynamic> json) => ServiceInfo(
        json['description'] as String,
        (json['quantity'] as num).toDouble(),
        Currency.fromJson(json['currency'] as Map<String, dynamic>),
        (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'currency': currency.toJson(),
        'price': price,
      };

  double get totalPrice => quantity * price;

  String formattedQuantity() {
    return quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString();
  }
}
