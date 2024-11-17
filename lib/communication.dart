import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CommunicationApp extends StatelessWidget {
  final String userName;
  final String id; // Current user's ID
  final String receiverName;
  final String receiverId;

  const CommunicationApp({
    super.key,
    required this.userName,
    required this.id,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00BFA5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChatPage(
        userName: userName,
        id: id,
        receiverName: receiverName,
        receiverId: receiverId,
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String userName;
  final String id; // Current user's ID
  final String receiverName;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.userName,
    required this.id,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  late final types.User _user;
  late final io.Socket socket;
  late final String room;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.id, firstName: widget.userName);
    room = _generateRoom(widget.id, widget.receiverId);
    _connectToWebSocket();
  }

  String _generateRoom(String senderId, String receiverId) {
    final ids = [senderId, receiverId]..sort();
    return 'private_${ids[0]}_${ids[1]}';
  }

  void _connectToWebSocket() async {
    var box = await Hive.openBox('authBox');
    String? token = box.get('token');

    if (token == null) {
      _showErrorDialog('User not authenticated. Please log in again.');
      return;
    }

    socket = io.io(
      'https://catermanage-388b2a1ca8bc.herokuapp.com',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'token': token},
      },
    );

    socket.connect();

    socket.onConnect((_) {
      print('Connected to WebSocket');
      socket.emit('join_private_room', {'room': room});
      print('Joined room: $room');
    });

    socket.on('receive_private_message', (data) => _handleReceivedMessage(data));
    socket.onDisconnect((_) => print('Disconnected from WebSocket'));
    socket.onConnectError((err) => print('Connection Error: $err'));
    socket.onError((err) => print('WebSocket Error: $err'));
  }

  void _handleReceivedMessage(dynamic data) {
    final message = types.TextMessage(
      author: types.User(
        id: data['authorId'],
        firstName: data['authorName'],
      ),
      id: const Uuid().v4(),
      text: data['text'],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, message);
    });
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
      'receiver_id': widget.receiverId,
      'room': room,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}

