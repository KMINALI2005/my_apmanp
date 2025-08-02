// services/file_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../models/debt_model.dart';

class FileService {
  // Method to check and request storage permission
  static Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  // Generate and save a PDF file
  static Future<void> generatePdf(List<Debt> debts) async {
    final pdf = pw.Document();

    final currencyFormat = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'د.ع.',
      decimalDigits: 0,
    );
    
    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.with's(
          defaultTextStyle: const pw.TextStyle(font: pw.Font.pdfa('NotoNaskhArabic-Regular')),
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'تقرير الديون',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['الحالة', 'التاريخ', 'الفئة', 'المبلغ', 'الاسم'],
                  data: debts.map((e) => [
                    e.isPaid ? 'مدفوع' : 'متبقي',
                    DateFormat('yyyy-MM-dd').format(e.date),
                    e.category,
                    currencyFormat.format(e.amount),
                    e.name,
                  ]).toList(),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  cellStyle: const pw.TextStyle(
                    fontSize: 10,
                  ),
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final status = await _requestPermission();
      if (status) {
        final dir = await getExternalStorageDirectory();
        final path = '${dir?.path}/debts_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        await OpenFilex.open(path);
      }
    } catch (e) {
      // Handle error
      print('Error generating PDF: $e');
    }
  }

  // Generate and save an Excel (CSV) file
  static Future<void> generateExcel(List<Debt> debts) async {
    final excel = Excel.createExcel();
    final sheet = excel['Debts'];
    
    // Add headers
    sheet.appendRow([
      const TextCellValue('الاسم'),
      const TextCellValue('المبلغ'),
      const TextCellValue('الفئة'),
      const TextCellValue('التاريخ'),
      const TextCellValue('الحالة'),
    ]);
    
    // Add data rows
    for (var debt in debts) {
      sheet.appendRow([
        TextCellValue(debt.name),
        DoubleCellValue(debt.amount),
        TextCellValue(debt.category),
        TextCellValue(DateFormat('yyyy-MM-dd').format(debt.date)),
        TextCellValue(debt.isPaid ? 'مدفوع' : 'متبقي'),
      ]);
    }

    try {
      final status = await _requestPermission();
      if (status) {
        final dir = await getExternalStorageDirectory();
        final path = '${dir?.path}/debts_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final fileBytes = excel.save();
        if (fileBytes != null) {
          final file = File(path);
          await file.writeAsBytes(fileBytes);
          await OpenFilex.open(path);
        }
      }
    } catch (e) {
      // Handle error
      print('Error generating Excel: $e');
    }
  }
}
