import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(Icons.person_outline, color: Colors.white),
          title: const Text(
            '13',
            style: TextStyle(color: Colors.red, fontSize: 24),
          ),
          centerTitle: true,
          actions: const [
            Icon(Icons.notifications_none, color: Colors.white),
            SizedBox(width: 16),
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(width: 16),
            Icon(Icons.home, color: Colors.white),
            SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: 450,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/sec.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          height: 400,
                          decoration:
                              BoxDecoration(color: Colors.black.withOpacity(0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: 220),
                            Row(
                              children: [
                                Icon(Icons.favorite_border,
                                    color: Colors.white),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "1.2 M",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.thumb_up_alt_outlined,
                                    color: Colors.white),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "100 k",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.message_outlined,
                                    color: Colors.white),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "20",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.share, color: Colors.white),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "10",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/sec.jpeg'), // Artist Image
                              radius: 30,
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Artist Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Release Date: Oct 2, 2024',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/sec.jpeg', // Artist Image
                              width: 40,
                              height: 40,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Women's Videos Section with views icon
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text("Women's Videos",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Spacer(),
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '230',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200, // Provide height to avoid overflow
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildVideoCard(
                            'assets/sec.jpeg', 'Title 1', '230K views'),
                        _buildVideoCard(
                            'assets/sec.jpeg', 'Title 2', '230K views'),
                        _buildVideoCard(
                            'assets/sec.jpeg', 'Title 3', '230K views'),
                        _buildVideoCard(
                            'assets/sec.jpeg', 'Title 4', '230K views'),
                      ],
                    ),
                  ),
                  // Comment Section
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Comments',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              _buildComment('User1', 'Amazing artwork!'),
                              _buildComment(
                                  'User2', 'Love this video, so inspiring.'),
                              _buildComment(
                                  'User3', 'Great artist! Keep it up.'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(String imageUrl, String title, String views) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl), // Local asset image
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          // Circular image at top left
          const Positioned(
            top: 5,
            left: 5,
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/sec.jpeg'), // Circular Image
              radius: 15,
            ),
          ),
          // 3 dots icon at top right
          const Positioned(
            top: 5,
            right: 5,
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String username, String comment) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/sec.jpeg'), // Local asset image
                radius: 15,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    comment,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 2,
          height: 30,
          width: 30,
          child: Image.asset('assets/sec.jpeg'), // Flag image
        ),
      ],
    );
  }
}
