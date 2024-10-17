import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const VendorManagementApp());
}

class VendorManagementApp extends StatelessWidget {
  const VendorManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const VendorManagementPage(),
    );
  }
}

class VendorManagementPage extends StatefulWidget {
  const VendorManagementPage({super.key});

  @override
  _VendorManagementPageState createState() => _VendorManagementPageState();
}

class _VendorManagementPageState extends State<VendorManagementPage> {
  final List<Map<String, String>> _vendors = [
    {
      "name": "John's Flowers",
      "service": "Flower Arrangements",
      "cost": "\$200"
    },
    {
      "name": "ABC Decorations",
      "service": "Event Decor",
      "cost": "\$1500"
    },
    {
      "name": "Fresh Supplies",
      "service": "Food Supplier",
      "cost": "\$2500"
    },
  ];

  List<Contact> _contacts = [];
  final _serviceController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();
  }

  // Request permission to access contacts
  Future<void> _requestContactsPermission() async {
    if (await Permission.contacts.request().isGranted) {
      _getContacts();
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts denied.')),
      );
    }
  }

  // Fetch contacts from the user's phone
  Future<void> _getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  // Add selected contact as a vendor
  void _addVendorFromContact(Contact contact) {
    if (_serviceController.text.isNotEmpty && _costController.text.isNotEmpty) {
      setState(() {
        _vendors.add({
          "name": contact.displayName ?? "Unnamed Contact",
          "service": _serviceController.text,
          "cost": _costController.text,
        });
        _serviceController.clear();
        _costController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text('Vendor Management', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendors List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _vendors.isNotEmpty
                  ? ListView.builder(
                      itemCount: _vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = _vendors[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                _buildVendorIcon(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendor['name']!,
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('Service: ${vendor['service']}',
                                          style: const TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 5),
                                      Text('Cost: ${vendor['cost']}',
                                          style: const TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF00BFA5)),
                                  onPressed: () {
                                    // Manage vendor logic (update or assign to events)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Manage Vendor clicked!')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _vendors.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No vendors available', style: TextStyle(color: Colors.black54))),
            ),
            const SizedBox(height: 20),
            _buildAddVendorFromContacts(),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorIcon() {
    return const CircleAvatar(
      backgroundColor: Color(0xFF00BFA5),
      child: Icon(FontAwesomeIcons.truck, color: Colors.white),
    );
  }

  // Build form to add vendor from contacts
  Widget _buildAddVendorFromContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Vendor from Contacts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _serviceController,
          decoration: const InputDecoration(
            labelText: 'Service Provided',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _costController,
          decoration: const InputDecoration(
            labelText: 'Cost',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            _showContactSelectionDialog();
          },
          icon: const Icon(Icons.contact_phone),
          label: const Text('Select Contact as Vendor'),
        ),
      ],
    );
  }

  // Show dialog to select a contact
  Future<void> _showContactSelectionDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Contact'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _contacts.isNotEmpty
                ? ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        title: Text(contact.displayName ?? 'Unnamed Contact'),
                        subtitle: contact.phones?.isNotEmpty == true
                            ? Text(contact.phones!.first.value!)
                            : const Text('No phone number'),
                        onTap: () {
                          Navigator.pop(context);
                          _addVendorFromContact(contact);
                        },
                      );
                    },
                  )
                : const Center(child: Text('No contacts available')),
          ),
        );
      },
    );
  }
}

