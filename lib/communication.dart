import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CommunicationApp extends StatelessWidget {
  final String userName;
  final String id;

  const CommunicationApp({super.key, required this.userName, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BFA5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChatPage(userName: userName, id: id),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String userName;
  final String id;

  const ChatPage({super.key, required this.userName, required this.id});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  late final types.User _user;
  late io.Socket socket;
  late String room;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.id, firstName: widget.userName);
    _connectToWebSocket();
  }

  void _connectToWebSocket() async {
    var box = await Hive.openBox('authBox');
    String? token = box.get('token');
    if (token == null) {
      _showErrorDialog('User not authenticated. Please log in again.');
      return;
    }

    socket = io
        .io('https://catermanage-388b2a1ca8bc.herokuapp.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token}
    });

    socket.connect();

    socket.onConnect((_) {

      socket.emit('join_private_room',
          {'token': 'your_jwt_token_here', 'receiver_id': _user.id});
      print('Connected and joined room $room');
    });

    socket.on(
        'receive_private_message', (data) => _handleReceivedMessage(data));

    socket.onDisconnect((_) => print('Disconnected'));
  }

  void _handleReceivedMessage(data) {
    final message = types.TextMessage(
      author: types.User(id: data['authorId'], firstName: data['authorName']),
      id: const Uuid().v4(),
      text: data['text'],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Chat(
      messages: _messages,
      onSendPressed: _handleSendMessage,
      user: _user,
      showUserAvatars: true,
      showUserNames: true,
    );
  }

  void _handleSendMessage(types.PartialText message) {
    final newMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    socket.emit('send_private_message', {
      'text': message.text,
      'token': 'your_jwt_token_here',
      'receiver_id': _user.id,
    });

    setState(() {
      _messages.insert(0, newMessage);
    });
  }

  @override
  void dispose() {
    socket.emit('leave', {'room': room});
    socket.disconnect();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
}
