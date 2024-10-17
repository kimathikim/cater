import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  bool isMentor = false;
  bool isMentee = false;
  String firstName = '';
  String email = '';
  String bio = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String> _showExpertiseDialog() async {
    String expertise = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your expertise'),
          content: TextField(
            onChanged: (value) {
              expertise = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return expertise;
  }

  Future<String> _showHelpNeededDialog() async {
    String help = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter the help you need'),
          content: TextField(
            onChanged: (value) {
              help = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return help;
  }

  Future<void> _fetchProfile() async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('https://momhive-992deeb4847a.herokuapp.com/api/v1/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          firstName = userData['first_name'];
          email = userData['email'];
          bio = userData['bio'] ?? 'No bio available';
          isMentor = userData['is_mentor'] ?? false;
          isMentee = userData['is_mentee'] ?? false;
        });
      } else {
        // Handle the error
        setState(() {
          bio = 'Failed to load profile data';
        });
      }
    }
  }

  Future<void> _updateMentorStatus(bool status, String expertise) async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      final response = await http.patch(
        Uri.parse(
            'https://momhive-992deeb4847a.herokuapp.com/api/v1/update_profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'is_mentor': status,
          'expertise': expertise,
        }),
      );

      if (response.statusCode == 202) {
        setState(() {
          isMentor = status;
        });
      } else {
        // Handle the error
        print('Failed to update mentor status');
      }
    }
  }

  Future<void> _updateMenteeStatus(bool status, String content) async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      final response = await http.patch(
        Uri.parse(
            'https://momhive-992deeb4847a.herokuapp.com/api/v1/update_profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_mentee': status, 'help_needed': content}),
      );

      if (response.statusCode == 202) {
        setState(() {
          isMentee = status;
        });
      } else {
        // Handle the error
        print('Failed to update mentee status');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.yellow[600],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header
          Container(
            color: Colors.yellow[600],
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.yellow[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  firstName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  bio,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Profile Details
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ProfileDetailCard(
                  title: 'Name',
                  content: firstName,
                ),
                ProfileDetailCard(
                  title: 'Email',
                  content: email,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Would you like to be a Mentor?'),
                  trailing: Switch(
                    value: isMentor,
                    onChanged: (bool value) async {
                      if (value) {
                        String expertise = await _showExpertiseDialog();
                        _updateMentorStatus(value, expertise);
                      } else {
                        _updateMentorStatus(value, "");
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Would you like to be a Mentee?'),
                  trailing: Switch(
                    value: isMentee,
                    onChanged: (bool value) async {
                      if (value) {
                        String helpNeeded = await _showHelpNeededDialog();
                        _updateMenteeStatus(value, helpNeeded);
                      } else {
                        _updateMenteeStatus(value, "");
                      }
                    },
                  ),
                ),
                const Divider(),
                const ProfileSectionTitle(title: 'Recent Activities'),
                const ActivityCard(
                  title: 'Groups Joined',
                  description: 'Parenting Support Group, Healthy Eating Group',
                ),
                const ActivityCard(
                  title: 'Events Participated',
                  description: 'Mom\'s Yoga Class, Baby Playdate',
                ),
                const ActivityCard(
                  title: 'Articles Read',
                  description:
                      'How to Handle Toddler Tantrums, Healthy Meal Ideas for Busy Moms',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final String title;
  final String content;

  const ProfileDetailCard(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(content),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;

  const ActivityCard(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
