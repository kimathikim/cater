import 'package:flutter/material.dart';

void main() {
  runApp(const ProfilePageApp());
}

class ProfilePageApp extends StatelessWidget {
  const ProfilePageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Custom AppBar with background image
            Stack(
              children: [
                // Background image
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/security.png'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                // AppBar content
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading:
                      const Icon(Icons.person_outline, color: Colors.white),
                  title: Image.asset(
                    'assets/1.png',
                    height: 50,
                  ),
                  centerTitle: true,
                  actions: const [
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, color: Colors.white),
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Profile Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Account Options Section
                  _buildSectionContainer(
                    title: "Account Settings",
                    children: [
                      _buildProfileOption(Icons.person, 'Update Profile Image'),
                      _buildProfileOption(
                          Icons.image, 'Update Profile Cover (Image or Video)'),
                      _buildProfileOption(
                          Icons.block, 'Disable Replying to Profile',
                          hasCheckbox: true),
                      _buildProfileOption(Icons.edit, 'Edit Profile'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Preferences Section
                  _buildSectionContainer(
                    title: "Preferences",
                    children: [
                      _buildProfileOption(
                          Icons.favorite_border, 'Favorites List'),
                      _buildProfileOption(Icons.interests, 'Your Interests'),
                      _buildProfileOption(
                          Icons.business, 'Business Type (Specialization)'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Shopping Section
                  _buildSectionContainer(
                    title: "Shopping & Payments",
                    children: [
                      _buildProfileOption(
                          Icons.shopping_cart_outlined, 'My Cart'),
                      _buildProfileOption(
                          Icons.receipt_long, 'Payments & Receipts'),
                      _buildProfileOption(
                          Icons.production_quantity_limits, 'My Products'),
                      _buildProfileOption(Icons.business_center, 'My Ventures'),
                      _buildProfileOption(Icons.sell, 'My Sales'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Security Section
                  _buildSectionContainer(
                    title: "Security & Information",
                    children: [
                      _buildProfileOption(
                          Icons.account_balance, 'Bank Information'),
                      _buildProfileOption(
                          Icons.verified, 'Business Verification'),
                      _buildProfileOption(Icons.security, 'Account Security'),
                      _buildProfileOption(Icons.logout, 'Log Out'),
                      _buildProfileOption(Icons.delete, 'Deactivate Account'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for building each profile option
  Widget _buildProfileOption(IconData iconData, String title,
      {bool hasCheckbox = false}) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      trailing: hasCheckbox
          ? Checkbox(value: false, onChanged: (bool? value) {})
          : null,
      onTap: () {},
    );
  }

  // Widget for creating a section with a title and a list of options
  Widget _buildSectionContainer(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}
