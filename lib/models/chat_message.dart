import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String messageType; // 'text', 'image', 'audio', 'ai_generated'
  final String chatRoomId;
  final bool isAiGenerated;

  ChatMessage({
    String? id,
    required this.senderId,
    required this.senderName,
    required this.message,
    DateTime? timestamp,
    this.messageType = 'text',
    required this.chatRoomId,
    this.isAiGenerated = false,
  }) : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'message_type': messageType,
      'chat_room_id': chatRoomId,
      'is_ai_generated': isAiGenerated ? 1 : 0,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      senderId: map['sender_id'],
      senderName: map['sender_name'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      messageType: map['message_type'] ?? 'text',
      chatRoomId: map['chat_room_id'],
      isAiGenerated: map['is_ai_generated'] == 1,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    String? messageType,
    String? chatRoomId,
    bool? isAiGenerated,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }
}
