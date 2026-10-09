import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/production_batch.dart';
import '../../models/order.dart';
import '../../models/expense.dart';
import '../../models/raw_material.dart';
import '../../models/factory_profile.dart';
import '../utils/formatters.dart';

class ReportExportService {
  // Export Batches CSV
  static Future<String> exportBatchesCsv(List<ProductionBatch> batches) async {
    final List<List<dynamic>> rows = [
      [
        'Batch Number',
        'Product Name',
        'Date',
        'Planned Qty (L)',
        'Actual Qty (L)',
        'Wastage Qty (L)',
        'Wastage %',
        'Efficiency %',
        'Status',
        'QC Status',
        'Operator',
      ],
      ...batches.map((b) => [
            b.batchNumber,
            b.productName,
            Formatters.date(b.productionDate),
            b.plannedQty,
            b.actualQty,
            b.wastageQty,
            b.wastagePercent.toStringAsFixed(1),
            b.efficiency.toStringAsFixed(1),
            b.status,
            b.qcStatus,
            b.assignedStaff,
          ]),
    ];

    final csvData = _encodeCsv(rows);
    return await _saveAndShareFile(csvData, 'JuiceFlow_Production_Report.csv');
  }

  // Export Sales Orders CSV
  static Future<String> exportOrdersCsv(List<SalesOrder> orders) async {
    final List<List<dynamic>> rows = [
      [
        'Order Number',
        'Customer Name',
        'Date',
        'Items Count',
        'Subtotal (INR)',
        'Tax (INR)',
        'Grand Total (INR)',
        'Paid Amount (INR)',
        'Payment Status',
        'Delivery Status',
      ],
      ...orders.map((o) => [
            o.orderNumber,
            o.customerName,
            Formatters.date(o.orderDate),
            o.items.length,
            o.subtotal,
            o.taxAmount,
            o.grandTotal,
            o.paidAmount,
            o.paymentStatus,
            o.deliveryStatus,
          ]),
    ];

    final csvData = _encodeCsv(rows);
    return await _saveAndShareFile(csvData, 'JuiceFlow_Sales_Report.csv');
  }

  // Export Expenses CSV
  static Future<String> exportExpensesCsv(List<Expense> expenses) async {
    final List<List<dynamic>> rows = [
      ['Expense Title', 'Category', 'Date', 'Amount (INR)', 'Payment Method', 'Description'],
      ...expenses.map((e) => [
            e.title,
            e.category,
            Formatters.date(e.date),
            e.amount,
            e.paymentMethod,
            e.description,
          ]),
    ];

    final csvData = _encodeCsv(rows);
    return await _saveAndShareFile(csvData, 'JuiceFlow_Expenses_Report.csv');
  }

  // Export Inventory CSV
  static Future<String> exportInventoryCsv(List<RawMaterial> materials) async {
    final List<List<dynamic>> rows = [
      [
        'Material Name',
        'Category',
        'Supplier',
        'Stock Qty',
        'Unit',
        'Min Level',
        'Batch No',
        'Expiry Date',
        'Location',
      ],
      ...materials.map((m) => [
            m.name,
            m.category,
            m.supplierName,
            m.quantity,
            m.unit,
            m.minStockLevel,
            m.batchNumber,
            Formatters.date(m.expiryDate),
            m.storageLocation,
          ]),
    ];

    final csvData = _encodeCsv(rows);
    return await _saveAndShareFile(csvData, 'JuiceFlow_Inventory_Report.csv');
  }

  static String _encodeCsv(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((cell) {
        final str = cell?.toString() ?? '';
        final escaped = str.replaceAll('"', '""');
        return '"$escaped"';
      }).join(',');
    }).join('\r\n');
  }

  static Future<String> _saveAndShareFile(String content, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)], text: 'Exported from JuiceFlow Factory Manager');
    return file.path;
  }

  // Generate Executive PDF Report
  static Future<void> exportExecutivePdfReport({
    required FactoryProfile profile,
    required List<ProductionBatch> batches,
    required List<SalesOrder> orders,
    required List<Expense> expenses,
  }) async {
    final pdf = pw.Document();

    final totalProduction = batches.fold<double>(0, (sum, b) => sum + b.actualQty);
    final totalSales = orders.fold<double>(0, (sum, o) => sum + o.grandTotal);
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netProfit = totalSales - totalExpenses;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        profile.companyName,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.Text(
                        'EXECUTIVE FACTORY PERFORMANCE REPORT',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Date: ${Formatters.date(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400, height: 20),

              // Summary KPI Grid
              pw.Row(
                children: [
                  _kpiBox('Total Production', '${totalProduction.toStringAsFixed(0)} Liters', PdfColors.green700),
                  pw.SizedBox(width: 8),
                  _kpiBox('Total Revenue', '₹${totalSales.toStringAsFixed(0)}', PdfColors.blue700),
                  pw.SizedBox(width: 8),
                  _kpiBox('Total Expenses', '₹${totalExpenses.toStringAsFixed(0)}', PdfColors.orange700),
                  pw.SizedBox(width: 8),
                  _kpiBox('Net Margin', '₹${netProfit.toStringAsFixed(0)}',
                      netProfit >= 0 ? PdfColors.green800 : PdfColors.red800),
                ],
              ),
              pw.SizedBox(height: 20),

              // Production Highlights Table
              pw.Text('Recent Production Batches',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('Batch #'),
                      _th('Product'),
                      _th('Produced (L)'),
                      _th('Wastage %'),
                      _th('QC Status'),
                    ],
                  ),
                  ...batches.take(6).map((b) => pw.TableRow(
                        children: [
                          _td(b.batchNumber),
                          _td(b.productName),
                          _td('${b.actualQty.toStringAsFixed(0)} L'),
                          _td('${b.wastagePercent.toStringAsFixed(1)}%'),
                          _td(b.qcStatus),
                        ],
                      )),
                ],
              ),
              pw.SizedBox(height: 20),

              // Recent Orders Table
              pw.Text('Recent Customer Orders',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _th('Order #'),
                      _th('Customer'),
                      _th('Date'),
                      _th('Amount (₹)'),
                      _th('Payment'),
                    ],
                  ),
                  ...orders.take(6).map((o) => pw.TableRow(
                        children: [
                          _td(o.orderNumber),
                          _td(o.customerName),
                          _td(Formatters.date(o.orderDate)),
                          _td('₹${o.grandTotal.toStringAsFixed(2)}'),
                          _td(o.paymentStatus),
                        ],
                      )),
                ],
              ),

              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('JuiceFlow Factory Management System • Confidential Enterprise Document',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Generated by JuiceFlow App',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'JuiceFlow_Factory_Executive_Report.pdf',
    );
  }

  static pw.Widget _kpiBox(String title, String val, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(val,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _th(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
    );
  }

  static pw.Widget _td(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
    );
  }
}
