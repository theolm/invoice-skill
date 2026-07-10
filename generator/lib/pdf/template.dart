import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';
import 'widgets.dart';

pw.Document generateInvoicePdf(Invoice invoice) {
  final widgets = PdfWidgets();
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            _getFirstRow(invoice, widgets),
            pw.SizedBox(height: 16),
            _getSecondRow(invoice, widgets),
            pw.SizedBox(height: 50),
            _getServiceRow(invoice, widgets),
            pw.SizedBox(height: 16),
            _getTotalAmountRow(invoice, widgets),
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey400, thickness: 1),
            pw.SizedBox(height: 30),
            _getBankRow(invoice, widgets),
            if (invoice.bankInfo.intermediary != null) ...[
              pw.SizedBox(height: 4),
              _getIntermediaryBankRow(invoice, widgets),
            ],
          ],
        );
      },
    ),
  );

  return pdf;
}

pw.Widget _getFirstRow(Invoice invoice, PdfWidgets w) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Flexible(child: w.getTitle(invoice)),
        pw.Flexible(
          child: w.getCompanyBlock(
            "From",
            invoice.companyInfo.name,
            invoice.formattedAddress(),
            invoice.companyInfo.email,
          ),
        ),
      ],
    );

pw.Widget _getSecondRow(Invoice invoice, PdfWidgets w) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Flexible(child: w.getDatesBlock(invoice)),
        pw.Flexible(
          child: w.getCompanyBlock(
            "Invoice For",
            invoice.clientInfo.name,
            invoice.clientInfo.address,
            "",
          ),
        ),
      ],
    );

pw.Widget _getTotalAmountRow(Invoice invoice, PdfWidgets w) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          "Amount Due: ",
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Text(
          invoice.formattedTotalPrice(invoice.service.currency.symbol),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );

pw.Widget _getServiceRow(Invoice invoice, PdfWidgets w) => pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: PdfColors.grey400,
          width: .5,
        ),
        verticalInside: pw.BorderSide(
          color: PdfColors.grey400,
          width: .5,
        ),
      ),
      children: [
        pw.TableRow(
          children: [
            w.getServiceLabel("Service Description"),
            w.getServiceLabel("Quantity"),
            w.getServiceLabel("Unit Price"),
            w.getServiceLabel("Amount"),
          ],
        ),
        pw.TableRow(
          children: [
            w.getServiceText(invoice.service.description),
            w.getServiceText(invoice.formattedQuantity()),
            w.getServiceText(
                invoice.formattedPrice(invoice.service.currency.symbol)),
            w.getServiceText(
                invoice.formattedTotalPrice(invoice.service.currency.symbol)),
          ],
        ),
      ],
    );

pw.Widget _getBankRow(Invoice invoice, PdfWidgets w) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Text(
          "Pay to banking details below:",
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        w.getBankRow("Contractor's full name:", invoice.companyInfo.ownerName),
        if (invoice.companyInfo.cnpj != null &&
            invoice.companyInfo.cnpj!.isNotEmpty)
          w.getBankRow("CNPJ:", invoice.companyInfo.cnpj!),
        w.getBankRow("Beneficiary name:", invoice.bankInfo.beneficiaryName),
        w.getBankRow("Beneficiary Account Number (IBAN):",
            invoice.bankInfo.main.iban),
        w.getBankRow("SWIFT Code:", invoice.bankInfo.main.swift),
        w.getBankRow("Bank Name:", invoice.bankInfo.main.bankName),
        w.getBankRow("Bank Address:", invoice.bankInfo.main.bankAddress),
      ],
    );

pw.Widget _getIntermediaryBankRow(Invoice invoice, PdfWidgets w) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Text(
          "Intermediary bank details:",
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 4),
        w.getBankRow("Account Number:", invoice.bankInfo.intermediary!.iban),
        w.getBankRow("SWIFT Code:", invoice.bankInfo.intermediary!.swift),
        w.getBankRow(
            "Bank Name:", invoice.bankInfo.intermediary!.bankName),
        w.getBankRow(
            "Bank Address:", invoice.bankInfo.intermediary!.bankAddress),
      ],
    );
