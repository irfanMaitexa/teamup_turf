import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer_null_safe/full_pdf_viewer_scaffold.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class AdminPaymentManagementScreen extends StatelessWidget {
  final List<Map<String, dynamic>> payments = [
    {'date': '2024-11-01', 'payment': 500, 'sport': 'Football'},
    {'date': '2024-11-02', 'payment': 300, 'sport': 'Basketball'},
    {'date': '2024-11-03', 'payment': 450, 'sport': 'Tennis'},
  ];

  double get totalEarnings {
    return payments.fold(0, (sum, payment) => sum + payment['payment']);
  }

  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    final pdf = pw.Document();
    print('pd');

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Payment Management Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              data: [
                ['Date', 'Payment', 'Sports'],
                ...payments.map((payment) => [payment['date'], '\$${payment['payment']}', payment['sport']])
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Earnings: \$${totalEarnings}', style: pw.TextStyle(fontSize: 18)),
          ],
        );
      },
    ));

    // Save PDF to file
    final outputFile = await _savePdfToFile(pdf);
  
    await _openPDF(outputFile, context);
  }

  Future<File> _savePdfToFile(pw.Document pdf) async {
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/payment_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _openPDF(File file, BuildContext context) async {
    final filePath = file.path;
    final fileBytes = await file.readAsBytes();
    final fileUrl = await DefaultCacheManager().putFile(filePath, fileBytes);
    print(fileUrl);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PDFScreen(file.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomSheet:   Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          
          onPressed: () => _generateAndDownloadPDF(context),
          style: ElevatedButton.styleFrom(
            fixedSize: Size(double.maxFinite,45),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Download Report as PDF',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
          
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Payment Management',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings
            Text(
              'Total Earnings: \$${totalEarnings}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            
            // Payments Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Sport')),
                ],
                rows: payments.map((payment) {
                  return DataRow(cells: [
                    DataCell(Text(payment['date'])),
                    DataCell(Text('\$${payment['payment']}')),
                    DataCell(Text(payment['sport'])),
                  ]);
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            
            // Generate PDF Button
          
          
          ],
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final String pathPDF;

  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ],
        ),
        path: pathPDF);
  }
}