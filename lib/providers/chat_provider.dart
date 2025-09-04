import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_message.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  IO.Socket? _socket;

  // Current chat state
  String _currentChatRoomId = 'default_room';
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;

  // Typing indicators
  final Map<String, bool> _typingUsers = {};
  bool _isTyping = false;

  // User info
  String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  String _currentUserName = 'Anonymous User';

  // Getters
  String get currentChatRoomId => _currentChatRoomId;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  Map<String, bool> get typingUsers => _typingUsers;
  bool get isTyping => _isTyping;
  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  // Initialize socket connection (for demo, using local mock)
  void initializeSocket() {
    try {
      // For demo purposes, we'll simulate socket connection
      // In production, replace with real socket server URL
      _socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket?.connect();

      _socket?.on('connect', (_) {
        _isConnected = true;
        notifyListeners();
        print('Connected to chat server');
      });

      _socket?.on('disconnect', (_) {
        _isConnected = false;
        notifyListeners();
        print('Disconnected from chat server');
      });

      _socket?.on('message', (data) {
        _handleNewMessage(data);
      });

      _socket?.on('typing', (data) {
        _handleTypingIndicator(data);
      });

      // Simulate connection for demo
      _simulateConnection();
    } catch (e) {
      print('Socket connection error: $e');
      // Fallback to offline mode
      _isConnected = false;
      notifyListeners();
    }
  }

  // Simulate connection for demo purposes
  void _simulateConnection() {
    Future.delayed(const Duration(seconds: 1), () {
      _isConnected = true;
      notifyListeners();
    });
  }

  void setUserInfo(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
    notifyListeners();
  }

  // Load messages from database
  Future<void> loadMessages([String? chatRoomId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final roomId = chatRoomId ?? _currentChatRoomId;
      _currentChatRoomId = roomId;

      if (!kIsWeb) {
        final messages = await _databaseService.getMessages(roomId);
        _messages = messages;
      } else {
        // For web, use in-memory storage
        _messages = [];
      }

      // Add some demo messages if empty
      if (_messages.isEmpty) {
        await _addDemoMessages();
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add demo messages for testing
  Future<void> _addDemoMessages() async {
    final demoMessages = [
      ChatMessage(
        senderId: 'demo_user_1',
        senderName: 'Alice Johnson',
        message: 'Hey! Ready for our video call today?',
        chatRoomId: _currentChatRoomId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ChatMessage(
        senderId: _currentUserId,
        senderName: _currentUserName,
        message: 'Yes, looking forward to it! 👍',
        chatRoomId: _currentChatRoomId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      ChatMessage(
        senderId: 'demo_user_1',
        senderName: 'Alice Johnson',
        message: 'I have some exciting updates to share about the project.',
        chatRoomId: _currentChatRoomId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      ChatMessage(
        senderId: 'ai_assistant',
        senderName: 'AI Assistant',
        message:
            '🤖 I can help generate meeting notes and summaries during your call!',
        chatRoomId: _currentChatRoomId,
        isAiGenerated: true,
        messageType: 'ai_generated',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    for (final message in demoMessages) {
      if (!kIsWeb) {
        await _databaseService.insertMessage(message);
      }
      _messages.add(message);
    }

    notifyListeners();
  }

  // Send a new message
  Future<void> sendMessage(String text, {String messageType = 'text'}) async {
    if (text.trim().isEmpty) return;

    final message = ChatMessage(
      senderId: _currentUserId,
      senderName: _currentUserName,
      message: text.trim(),
      chatRoomId: _currentChatRoomId,
      messageType: messageType,
    );

    // Add to local state immediately
    _messages.add(message);
    notifyListeners();

    try {
      // Save to database (skip on web)
      if (!kIsWeb) {
        await _databaseService.insertMessage(message);
      }

      // Send via socket if connected
      if (_isConnected && _socket != null) {
        _socket!.emit('message', message.toMap());
      }

      // Simulate AI response for demo
      if (text.toLowerCase().contains('ai') ||
          text.toLowerCase().contains('help')) {
        _simulateAIResponse();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Remove from local state if failed to save
      _messages.removeLast();
      notifyListeners();
    }
  }

  // Simulate AI response for demo
  void _simulateAIResponse() {
    Future.delayed(const Duration(seconds: 2), () async {
      final aiResponses = [
        "🤖 I'm here to help! I can generate meeting summaries, take notes, and suggest action items.",
        "🤖 Would you like me to create a summary of your conversation so far?",
        "🤖 I can help with brainstorming ideas or generating creative content during your calls!",
        "🤖 Let me know if you'd like me to generate any images or visual content to support your discussion.",
      ];

      final randomResponse =
          aiResponses[DateTime.now().millisecond % aiResponses.length];

      final aiMessage = ChatMessage(
        senderId: 'ai_assistant',
        senderName: 'AI Assistant',
        message: randomResponse,
        chatRoomId: _currentChatRoomId,
        isAiGenerated: true,
        messageType: 'ai_generated',
      );

      _messages.add(aiMessage);
      if (!kIsWeb) {
        await _databaseService.insertMessage(aiMessage);
      }
      notifyListeners();
    });
  }

  // Handle incoming messages from socket
  void _handleNewMessage(dynamic data) {
    try {
      final message = ChatMessage.fromMap(Map<String, dynamic>.from(data));
      if (message.chatRoomId == _currentChatRoomId) {
        _messages.add(message);
        if (!kIsWeb) {
          _databaseService.insertMessage(message);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  // Handle typing indicators
  void _handleTypingIndicator(dynamic data) {
    try {
      final userId = data['userId'] as String;
      final isTyping = data['isTyping'] as bool;

      if (userId != _currentUserId) {
        _typingUsers[userId] = isTyping;
        if (!isTyping) {
          _typingUsers.remove(userId);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error handling typing indicator: $e');
    }
  }

  // Set typing indicator
  void setTyping(bool typing) {
    if (_isTyping == typing) return;

    _isTyping = typing;
    notifyListeners();

    // Send typing indicator via socket
    if (_isConnected && _socket != null) {
      _socket!.emit('typing', {
        'userId': _currentUserId,
        'userName': _currentUserName,
        'chatRoomId': _currentChatRoomId,
        'isTyping': typing,
      });
    }
  }

  // Join a chat room
  Future<void> joinChatRoom(String chatRoomId) async {
    if (_currentChatRoomId == chatRoomId) return;

    _currentChatRoomId = chatRoomId;
    await loadMessages(chatRoomId);

    // Join room via socket
    if (_isConnected && _socket != null) {
      _socket!.emit('join_room', {
        'chatRoomId': chatRoomId,
        'userId': _currentUserId,
        'userName': _currentUserName,
      });
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      _messages.removeWhere((msg) => msg.id == messageId);
      notifyListeners();

      // In a real app, you'd delete from database and notify server
      // For demo, we'll just remove locally
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Search messages
  Future<List<ChatMessage>> searchMessages(String query) async {
    try {
      if (!kIsWeb) {
        return await _databaseService.searchMessages(query);
      } else {
        // For web, search in memory
        return _messages
            .where(
              (message) =>
                  message.message.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  // Get typing indicator text
  String getTypingIndicatorText() {
    final typingUserNames = _typingUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (typingUserNames.isEmpty) return '';

    if (typingUserNames.length == 1) {
      return '${typingUserNames.first} is typing...';
    } else if (typingUserNames.length == 2) {
      return '${typingUserNames[0]} and ${typingUserNames[1]} are typing...';
    } else {
      return 'Multiple users are typing...';
    }
  }

  // Clean up
  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
