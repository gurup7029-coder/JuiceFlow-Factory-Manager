import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/order.dart';
import '../../models/factory_profile.dart';
import '../utils/formatters.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoice({
    required SalesOrder order,
    required FactoryProfile profile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        profile.companyName,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        profile.factoryName,
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        profile.address,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Phone: ${profile.phone} | Email: ${profile.email}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'GSTIN: ${profile.gstNumber} | FSSAI Lic: ${profile.fssaiLicense}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Invoice #: ${order.orderNumber}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Date: ${Formatters.date(order.orderDate)}',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Payment: ${order.paymentStatus.toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: order.paymentStatus == 'Paid'
                                ? PdfColors.green700
                                : PdfColors.red700,
                          )),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey300, height: 24),

              // Billed To Section
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          order.customerName,
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          order.customerAddress,
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'Phone: ${order.customerPhone}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Delivery Status: ${order.deliveryStatus}',
                            style: const pw.TextStyle(fontSize: 11)),
                        if (order.deliveryDate != null)
                          pw.Text('Delivery Date: ${Formatters.date(order.deliveryDate)}',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.green700),
                    children: [
                      _tableHeaderCell('S.No', width: 35),
                      _tableHeaderCell('Product Description / Size'),
                      _tableHeaderCell('Qty', align: pw.TextAlign.center),
                      _tableHeaderCell('Rate (₹)', align: pw.TextAlign.right),
                      _tableHeaderCell('Amount (₹)', align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  ...order.items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                      ),
                      children: [
                        _tableDataCell('$index', align: pw.TextAlign.center),
                        _tableDataCell('${item.productName} (${item.bottleSize})'),
                        _tableDataCell('${item.quantity}', align: pw.TextAlign.center),
                        _tableDataCell(item.unitPrice.toStringAsFixed(2),
                            align: pw.TextAlign.right),
                        _tableDataCell(item.totalPrice.toStringAsFixed(2),
                            align: pw.TextAlign.right),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 240,
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
                        if (order.discount > 0)
                          _summaryRow('Discount', '-₹${order.discount.toStringAsFixed(2)}'),
                        _summaryRow('GST / Tax', '₹${order.taxAmount.toStringAsFixed(2)}'),
                        pw.Divider(color: PdfColors.grey400),
                        _summaryRow(
                          'Grand Total',
                          '₹${order.grandTotal.toStringAsFixed(2)}',
                          isBold: true,
                          fontSize: 14,
                        ),
                        _summaryRow(
                          'Paid Amount',
                          '₹${order.paidAmount.toStringAsFixed(2)}',
                          color: PdfColors.green800,
                        ),
                        _summaryRow(
                          'Balance Due',
                          '₹${order.balanceAmount.toStringAsFixed(2)}',
                          isBold: true,
                          color: order.balanceAmount > 0 ? PdfColors.red800 : PdfColors.grey700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Declaration: Goods once sold will not be taken back.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'JuiceFlow Enterprise System • Fresh Fruit Beverage Quality Guaranteed.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'For ${profile.companyName}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Text(
                        'Authorised Signatory',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableHeaderCell(String text,
      {double? width, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableDataCell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printOrShareInvoice({
    required SalesOrder order,
    required FactoryProfile profile,
  }) async {
    final pdfBytes = await generateInvoice(order: order, profile: profile);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${order.orderNumber}.pdf',
    );
  }
}
