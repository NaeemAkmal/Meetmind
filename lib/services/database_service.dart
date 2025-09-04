import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/call_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'meetmind.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Chat messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        message_type TEXT DEFAULT 'text',
        chat_room_id TEXT NOT NULL,
        is_ai_generated INTEGER DEFAULT 0
      )
    ''');

    // Call records table
    await db.execute('''
      CREATE TABLE call_records (
        id TEXT PRIMARY KEY,
        participants TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER,
        transcription TEXT,
        ai_summary TEXT,
        call_type TEXT DEFAULT 'video'
      )
    ''');

    // User contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar_url TEXT,
        last_seen INTEGER,
        is_online INTEGER DEFAULT 0
      )
    ''');

    // AI generated content table
    await db.execute('''
      CREATE TABLE ai_content (
        id TEXT PRIMARY KEY,
        content_type TEXT NOT NULL,
        content TEXT NOT NULL,
        generated_for TEXT,
        timestamp INTEGER NOT NULL,
        call_id TEXT
      )
    ''');
  }

  // Chat message operations
  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert('chat_messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessages(String chatRoomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  // Call record operations
  Future<void> insertCallRecord(CallRecord record) async {
    final db = await database;
    await db.insert('call_records', record.toMap());
  }

  Future<void> updateCallRecord(String callId, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'call_records',
      updates,
      where: 'id = ?',
      whereArgs: [callId],
    );
  }

  Future<List<CallRecord>> getCallHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'call_records',
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      return CallRecord.fromMap(maps[i]);
    });
  }

  // AI content operations
  Future<void> saveAIContent({
    required String id,
    required String contentType,
    required String content,
    String? generatedFor,
    String? callId,
  }) async {
    final db = await database;
    await db.insert('ai_content', {
      'id': id,
      'content_type': contentType,
      'content': content,
      'generated_for': generatedFor,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'call_id': callId,
    });
  }

  Future<List<Map<String, dynamic>>> getAIContent({String? callId}) async {
    final db = await database;
    
    if (callId != null) {
      return await db.query(
        'ai_content',
        where: 'call_id = ?',
        whereArgs: [callId],
        orderBy: 'timestamp DESC',
      );
    }
    
    return await db.query(
      'ai_content',
      orderBy: 'timestamp DESC',
    );
  }

  // Contact operations
  Future<void> addContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return await db.query('contacts', orderBy: 'name ASC');
  }

  // Search functionality
  Future<List<ChatMessage>> searchMessages(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      where: 'message LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  // Clear data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chat_messages');
    await db.delete('call_records');
    await db.delete('ai_content');
  }
}
