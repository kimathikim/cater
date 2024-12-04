import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // Add this import
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'communication.dart';

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final quill.QuillController _quillController = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        title: const Text('Booking Details',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailCard('Event Details', [
                _detailRow('Event', widget.booking['event_name']),
                _detailRow('Date', widget.booking['event_date']),
                _detailRow('Time', widget.booking['event_time']),
                _detailRow('Location', widget.booking['event_location']),
                _detailRow('Guests', '${widget.booking['guest_count']}'),
              ]),
              const SizedBox(height: 20),
              _buildStatusCard('Status', widget.booking['status'], context),
              const SizedBox(height: 20),
              _buildServiceCard('Services', widget.booking['services']),
              const SizedBox(height: 20),
              _buildSpecialInstructionsCard('Special Instructions',
                  widget.booking['special_instructions']),
              const SizedBox(height: 20),
              _buildCostCard('Total Cost', widget.booking['total_cost']),
              const SizedBox(height: 20),
              _buildNoteTakingFeature(),
              const SizedBox(height: 20),
              _buildCommunicationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTakingFeature() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Booking Updates'),
            const Divider(color: Colors.grey),
            quill.QuillToolbar(
              configurations: quill.QuillToolbarConfigurations(
                sharedConfigurations: quill.QuillSharedConfigurations(),
                buttonOptions: quill.QuillSimpleToolbarButtonOptions(),
              ),
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: quill.QuillEditor(
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                controller: _quillController,
              ),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: _buildTableRows(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                  ),
                  onPressed: _addTableRow,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                  ),
                  onPressed: _exportAndPreviewPDF,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAndPreviewPDF() async {
    final text = _quillController.document.toPlainText();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/notes.pdf');
    await file.writeAsBytes(await pdf.save());

    // Show a PDF preview dialog
    await _showPDFPreview(file);
  }

  Future<void> _showPDFPreview(File file) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'PDF Preview',
            style: TextStyle(color: Colors.black),
          ),
          content: SizedBox(
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: file.path,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Send PDF via Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sendPDFEmail(file);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPDFEmail(File file) async {
    // Prepare the email with necessary details
    final Email email = Email(
      body: 'Here are the notes you requested.',
      subject: 'Your Notes PDF',
      recipients: ['client@example.com'], // Replace with the recipient's email
      attachmentPaths: [file.path], // Path to the PDF file
      isHTML: false, // Set to true if your body contains HTML
    );

    try {
      // Send the email
      await FlutterEmailSender.send(email);

      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully!')),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }

  final List<TableRow> _tableRows = [
    TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  ];

  List<TableRow> _buildTableRows() {
    return _tableRows;
  }

  void _addTableRow() {
    setState(() {
      _tableRows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  filled: true,
                  border: OutlineInputBorder(),
                  hintText: 'Enter item',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter quantity',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style:
                    TextStyle(color: Colors.black), // Set text color to black
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter price',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _saveNotes() async {
    final text = _quillController.document.toPlainText();
    // Save the notes locally (e.g., Hive or SQLite can be used for storage).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notes saved: $text')),
    );
  }

  Future<void> _exportToPDF() async {
    final text = _quillController.document.toPlainText();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/notes.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at: ${file.path}')),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> details) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.info, color: Color(0xFF00BFA5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BFA5),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Pending':
        statusColor = const Color(0xFFFFB74D);
        break;
      case 'Confirmed':
        statusColor = const Color(0xFF81C784);
        break;
      case 'Completed':
        statusColor = const Color(0xFF00BFA5);
        break;
      case 'Cancelled':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showUpdateStatusDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Update Status'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationButtons(BuildContext context) {
    final managerId = widget.booking['userProfile']['id'];
    final managerName = widget.booking['userProfile']['name'];
    final clientId = widget.booking['user_id'];
    final clientName = widget.booking['user_name'];

    // Ensure values are not null and log for debugging
    if (managerId == null ||
        managerName == null ||
        clientId == null ||
        clientName == null) {
      print("Communication Error: One or more user details are missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Client or Manager information is unavailable.'),
        ),
      );
      return const SizedBox
          .shrink(); // Return an empty widget if data is not available
    }

    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person),
          label: const Text('Contact Client'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunicationApp(
                  receiverName: clientName,
                  receiverId: clientId,
                  userName: managerName,
                  id: managerId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    String selectedStatus = 'Pending';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Update Booking Status',
            style: TextStyle(color: Colors.black),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            dropdownColor: Colors.white,
            items: ['Pending', 'Confirmed', 'Completed', 'Cancelled']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                selectedStatus = newValue;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateBookingStatus(
                    context, widget.booking['id'], selectedStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBookingStatus(
      BuildContext context, String bookingId, String newStatus) async {
    final String apiUrl =
        'https://web-production-3e0c9.up.railway.app/api/v1/bookings/$bookingId';

    try {
      var box = await Hive.openBox('authBox');
      String? token = box.get('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User not authenticated. Please log in.')),
        );
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $newStatus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Widget _buildServiceCard(String title, List<dynamic> services) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            if (services.isEmpty)
              const Text(
                'No services listed.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              )
            else
              Column(
                children: services.map<Widget>((service) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '\$${service['price']} x ${service['quantity']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructionsCard(String title, String? instructions) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                instructions?.isNotEmpty == true ? instructions! : 'None',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(String title, dynamic cost) {
    double totalCost = cost is int ? cost.toDouble() : cost;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title),
            const Divider(color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
