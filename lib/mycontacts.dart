import 'package:flutter/material.dart';
import 'communication.dart';
import 'newconv.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MessageListPage(),
    );
  }
}

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'name': 'John Doe',
      'lastMessage': 'Hey, how are you?',
      'time': '5 min ago',
      'avatarUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Looking forward to our meeting.',
      'time': 'Yesterday',
      'avatarUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Mike Johnson',
      'lastMessage': 'Can you send me the file?',
      'time': '2 days ago',
      'avatarUrl': 'https://via.placeholder.com/150',
    },
  ];

  void _startNewConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const ContactListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(_messages[index]['avatarUrl']),
            ),
            title: Text(_messages[index]['name']),
            subtitle: Text(_messages[index]['lastMessage']),
            trailing: Text(_messages[index]['time'],
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            onTap: () {
              // Navigate to chat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CommunicationApp(id: "ehjo", userName: _messages[index]['name']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        tooltip: 'New Message',
        child: const Icon(Icons.message),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
