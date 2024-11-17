import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'contact.dart';
import 'communication.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({Key? key}) : super(key: key);

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Box<Contact> contactBox;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);

    if (!Hive.isAdapterRegistered(ContactAdapter().typeId)) {
      Hive.registerAdapter(ContactAdapter());
    }

    contactBox = await Hive.openBox<Contact>('contacts');
    _loadContactsFromHive();
    _fetchContactsFromApi();
  }

  void _loadContactsFromHive() {
    setState(() {
      contacts = contactBox.values.toList();
    });
  }

  Future<void> _fetchContactsFromApi() async {
    try {
      var url = Uri.parse(
          'https://catermanage-388b2a1ca8bc.herokuapp.com/api/v1/users');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var users = data['users'] as List;
        await contactBox.clear(); // Clear the old data
        for (var userData in users) {
          final contact = Contact(
            id: userData['id'],
            name: userData['name'],
          );
          contactBox.add(contact);
        }
        _loadContactsFromHive();
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.teal,
      ),
      body: ValueListenableBuilder(
        valueListenable: contactBox.listenable(),
        builder: (context, Box<Contact> box, _) {
          final contacts = box.values.toList().cast<Contact>();
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0]),
                ),
                title: Text(contact.name),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
