import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const SettingsPageApp());
}

class SettingsPageApp extends StatelessWidget {
  const SettingsPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5), // Teal green
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _twoFactorAuthEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApplicationSettings(),
            const SizedBox(height: 20),
            _buildPrivacyAndSecuritySettings(),
            const SizedBox(height: 20),
            _buildAdminSettings(), // Only show if admin role
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationSettings() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            _buildDropdownSetting(
              'Language',
              FontAwesomeIcons.language,
              _selectedLanguage,
              (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              ['English', 'Spanish', 'French'],
            ),
            _buildSwitchSetting(
              'Enable Notifications',
              FontAwesomeIcons.bell,
              _notificationsEnabled,
              (newValue) {
                setState(() {
                  _notificationsEnabled = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyAndSecuritySettings() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy & Security Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(FontAwesomeIcons.key, color: Color(0xFF00BFA5)),
              title: const Text('Change Password', style: TextStyle(color: Colors.black87)),
              onTap: () {
                // Logic to change password
              },
            ),
            _buildSwitchSetting(
              'Enable 2-Factor Authentication (2FA)',
              FontAwesomeIcons.lock,
              _twoFactorAuthEnabled,
              (newValue) {
                setState(() {
                  _twoFactorAuthEnabled = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSettings() {
    // Only render this section if the user is an admin
    bool isAdmin = true; // Replace this with actual admin check

    if (!isAdmin) {
      return Container();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(FontAwesomeIcons.usersCog, color: Color(0xFF00BFA5)),
              title: const Text('Manage User Roles & Permissions', style: TextStyle(color: Colors.black87)),
              onTap: () {
                // Logic for managing user roles
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(String title, IconData icon, String value,
      ValueChanged<String?> onChanged, List<String> options) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00BFA5)),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options
            .map((String option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)))
            .toList(),
      ),
    );
  }

  Widget _buildSwitchSetting(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      secondary: Icon(icon, color: const Color(0xFF00BFA5)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BFA5),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
    );
  }
}

