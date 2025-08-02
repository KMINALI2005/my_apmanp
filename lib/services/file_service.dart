// services/file_service.dart - إصدار مبسط بدون مشاركة
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/debt_model.dart';

class FileService {
  // Method to check and request storage permission
  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true;
  }

  // Show success message
  static void _showSuccess(BuildContext? context, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Show error message
  static void _showError(BuildContext? context, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Generate and save a PDF file
  static Future<void> generatePdf(List<Debt> debts, [BuildContext? context]) async {
    try {
      final pdf = pw.Document();
      final currencyFormat = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: 'د.ع.',
        decimalDigits: 0,
      );
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Column(
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
                pw.Text(
                  'تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
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
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                  headerAlignment: pw.Alignment.center,
                ),
              ],
            );
          },
        ),
      );

      final hasPermission = await _requestPermission();
      if (hasPermission) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'تقرير_الديون_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final path = '${dir.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        
        // Open the file
        final result = await OpenFilex.open(path);
        if (result.type == ResultType.done) {
          _showSuccess(context, 'تم إنشاء ملف PDF بنجاح');
        } else {
          _showError(context, 'فشل في فتح الملف');
        }
      } else {
        _showError(context, 'لا توجد صلاحية للوصول للملفات');
      }
    } catch (e) {
      print('Error generating PDF: $e');
      _showError(context, 'حدث خطأ في إنشاء ملف PDF');
    }
  }

  // Generate and save an Excel file
  static Future<void> generateExcel(List<Debt> debts, [BuildContext? context]) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['تقرير الديون'];
      
      // Add headers
      sheet.appendRow([
        'الاسم',
        'المبلغ',
        'الفئة',
        'التاريخ',
        'الحالة',
        'الوصف'
      ]);
      
      // Add data rows
      for (var debt in debts) {
        sheet.appendRow([
          debt.name,
          debt.amount,
          debt.category,
          DateFormat('yyyy-MM-dd').format(debt.date),
          debt.isPaid ? 'مدفوع' : 'متبقي',
          debt.description.isNotEmpty ? debt.description : 'لا يوجد'
        ]);
      }

      final hasPermission = await _requestPermission();
      if (hasPermission) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'تقرير_الديون_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final path = '${dir.path}/$fileName';
        final fileBytes = excel.encode();
        if (fileBytes != null) {
          final file = File(path);
          await file.writeAsBytes(fileBytes);
          
          // Open the file
          final result = await OpenFilex.open(path);
          if (result.type == ResultType.done) {
            _showSuccess(context, 'تم إنشاء ملف Excel بنجاح');
          } else {
            _showError(context, 'فشل في فتح الملف');
          }
        }
      } else {
        _showError(context, 'لا توجد صلاحية للوصول للملفات');
      }
    } catch (e) {
      print('Error generating Excel: $e');
      _showError(context, 'حدث خطأ في إنشاء ملف Excel');
    }
  }
}
