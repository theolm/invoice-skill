import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:invoice_generator/models/invoice.dart';
import 'package:invoice_generator/pdf/template.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('data', abbr: 'd', help: 'JSON string with invoice data')
    ..addOption('file', abbr: 'f', help: 'Path to JSON file with invoice data')
    ..addOption('output', abbr: 'o', help: 'Output PDF path', defaultsTo: 'invoice.pdf')
    ..addOption('output-dir', help: 'Output directory (used with --auto-name)', defaultsTo: '.')
    ..addFlag('auto-name', help: 'Generate filename as invoice-{id}-{YYYY-MM-DD}.pdf', negatable: false)
    ..addFlag('help', abbr: 'h', help: 'Show usage', negatable: false);

  final parsed = parser.parse(args);

  if (parsed['help'] as bool) {
    print(parser.usage);
    exit(0);
  }

  String jsonData;

  if (parsed.wasParsed('file')) {
    final file = File(parsed['file'] as String);
    jsonData = file.readAsStringSync();
  } else if (parsed.wasParsed('data')) {
    jsonData = parsed['data'] as String;
  } else {
    stderr.writeln('Error: provide --data or --file');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final invoiceData = jsonDecode(jsonData) as Map<String, dynamic>;

  String outputPath;

  if (parsed['auto-name'] as bool) {
    final id = invoiceData['id'] ?? 0;
    final issueDate = invoiceData['issueDate'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.fromMillisecondsSinceEpoch(issueDate);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dir = parsed['output-dir'] as String;
    outputPath = '$dir/invoice-$id-$dateStr.pdf';
  } else {
    outputPath = parsed['output'] as String;
  }

  final invoice = Invoice.fromJson(invoiceData);
  final pdf = generateInvoicePdf(invoice);
  final bytes = await pdf.save();

  final outFile = File(outputPath);
  if (!outFile.parent.existsSync()) {
    outFile.parent.createSync(recursive: true);
  }
  await outFile.writeAsBytes(bytes);

  print('Invoice PDF generated: $outputPath');
}
