import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../networking/api_constants.dart';

class ReportService {
  static String _sanitizeText(String? text) {
    if (text == null) return 'N/A';
    // Remove characters that might crash the default PDF font (keep basic ASCII, numbers, and common punctuation)
    return text.replaceAll(RegExp(r'[^\x00-\x7F]'), '?');
  }

  static Future<Uint8List?> _fetchImageBytes(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final url = ApiConstants.getFullImageUrl(path);
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('ERROR: Failed to fetch image for PDF: $e');
    }
    return null;
  }

  static Future<String?> generatePdfReport(Map<String, dynamic> data) async {
    try {
      final pdf = pw.Document();

      // Fetch images first
      final image1Bytes = await _fetchImageBytes(data['image1']);
      final image2Bytes = await _fetchImageBytes(data['image2']);

      final patientName = _sanitizeText(data['name'] ?? data['patientName']);
      final age = _sanitizeText(data['age']?.toString());
      final gender = _sanitizeText(data['gender']);
      final stenosis = _sanitizeText((data['stenosis'] ?? data['stenosisPercent'] ?? '0').toString());
      final artery = _sanitizeText(data['artery']);
      final riskLevel = _sanitizeText(data['riskLevel']);
      final diagnosis = _sanitizeText(data['notes'] ?? data['diagnosisDetails'] ?? 'No details');
      final date = _sanitizeText(data['date'] ?? DateTime.now().toString().split(' ')[0]);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('AngioLens Analysis Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text(date, style: const pw.TextStyle(color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Patient Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Divider(color: PdfColors.blue400),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Name: $patientName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Age: $age')),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Gender: $gender')),
                    pw.Expanded(child: pw.Text('Case ID: ${data['id'] ?? 'N/A'}')),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Analysis Results', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Divider(color: PdfColors.blue400),
                pw.SizedBox(height: 10),
                pw.Text('Detected Artery: $artery', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('Stenosis Level: $stenosis%', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Risk Level: $riskLevel', style: pw.TextStyle(fontSize: 14, color: riskLevel.toLowerCase().contains('critical') ? PdfColors.red : PdfColors.green, fontWeight: pw.FontWeight.bold)),
                
                // Diagnostic Images Section
                if (image1Bytes != null || image2Bytes != null) ...[
                  pw.SizedBox(height: 25),
                  pw.Text('Diagnostic Scans', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      if (image1Bytes != null)
                        pw.Container(
                          width: 200,
                          height: 150,
                          child: pw.Image(pw.MemoryImage(image1Bytes), fit: pw.BoxFit.contain),
                        ),
                      if (image2Bytes != null)
                        pw.Container(
                          width: 200,
                          height: 150,
                          child: pw.Image(pw.MemoryImage(image2Bytes), fit: pw.BoxFit.contain),
                        ),
                    ],
                  ),
                ],

                pw.SizedBox(height: 25),
                pw.Text('Diagnosis Details:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(diagnosis, style: const pw.TextStyle(lineSpacing: 4)),
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Generated by AngioLens AI System', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final sanitizedName = patientName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final file = File("${output.path}/Report_${sanitizedName}_${DateTime.now().millisecond}.pdf");
      
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      debugPrint('ERROR: PDF Generation failed: $e');
      return null;
    }
  }
}
