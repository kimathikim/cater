import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
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
  bool isConnected = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

  void _connectToWebSocket() {
    try {
      print('Connecting to WebSocket...');

      // Initialize the socket
      socket = io.io(
        'https://web-production-3e0c9.up.railway.app/',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': {'user_id': widget.id},
        },
      );

      socket.connect();
      print(socket.connect());

      socket.onConnect((_) {
        print('Connected to WebSocket');
        isConnected = true;

        // Ensure both users join the room after connecting
        socket.emit('join_private_room', {
          'sender_id': widget.id,
          'receiver_id': widget.receiverId,
        });
        print('Joined room: $room');
      });

      socket.on('room_joined', (data) {
        if (data['status'] == 'success') {
          print('Successfully joined room: ${data['room']}');
        } else {
          print('Failed to join room: ${data['message']}');
        }
      });

      socket.on('receive_private_message', (data) {
        print('Received message: $data');
        _handleReceivedMessage(data);
      });

      socket.onDisconnect((_) {
        print('Disconnected from WebSocket');
        isConnected = false;
        _showErrorDialog('Disconnected from server. Please reconnect.');
      });

      socket.onConnectError((err) {
        print('Connection Error: $err');
        _showErrorDialog('Unable to connect to server. Please try again.');
      });

      socket.onError((err) {
        print('WebSocket Error: $err');
        _showErrorDialog('An error occurred: $err');
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _showErrorDialog('An error occurred while connecting to WebSocket.');
    }
  }

  void _handleReceivedMessage(dynamic data) {
    try {
      final senderId = data['authorId'];
      final senderName = data['authorName'];
      final text = data['text'];
      final timestamp = data['timestamp'];

      if (senderId == null || text == null) {
        print('receive_private_message: Missing senderId or text');
        return;
      }

      final message = types.TextMessage(
        author: types.User(
          id: senderId,
          firstName: senderName,
        ),
        id: const Uuid().v4(),
        text: text,
        createdAt: DateTime.tryParse(timestamp)?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
      );

    } catch (e) {
      print('Error handling received message: $e');
    }
  }

  void _handleSendMessage(types.PartialText message) {
    try {
      final newMessage = types.TextMessage(
        author: _user,
        id: const Uuid().v4(),
        text: message.text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      socket.emit('send_private_message', {
        'sender_id': widget.id,
        'sender_name': widget.userName,
        'text': message.text,
        'receiver_id': widget.receiverId,
      });

      print('Sending message: ${message.text}');
      setState(() {
        _messages.insert(0, newMessage);
      });

      // Optionally, handle acknowledgment
      socket.on('message_sent_ack', (data) {
        if (data['status'] == 'success') {
          print('Message sent successfully');
        } else {
          print('Failed to send message: ${data['message']}');
        }
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    try {
      if (isConnected) {
        print('Leaving room: $room');
        socket.emit('leave', {'room': room});
        socket.disconnect();
      }
    } catch (e) {
      print('Error during dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => Chat(
            messages: _messages,
            onSendPressed: _handleSendMessage,
            user: _user,
            showUserAvatars: true,
            showUserNames: true,
            theme: const DefaultChatTheme(
              inputBackgroundColor: Colors.white,
              inputTextColor: Colors.black,
              primaryColor: Color(0xFF00BFA5),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    try {
      if (_navigatorKey.currentContext != null) {
        showDialog(
          context: _navigatorKey.currentContext!,
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
      } else {
        print('Error: Navigator context is null');
      }
    } catch (e) {
      print('Error showing dialog: $e');
    }
  }
}
