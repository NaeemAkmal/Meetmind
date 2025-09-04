// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? chatTitle;
  final bool showInCall;

  const ChatScreen({
    super.key,
    this.chatRoomId,
    this.chatTitle,
    this.showInCall = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.initializeSocket();
    chatProvider.setUserInfo('current_user', 'You');

    if (widget.chatRoomId != null) {
      chatProvider.joinChatRoom(widget.chatRoomId!);
    } else {
      chatProvider.loadMessages();
    }

    _animationController.forward();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.showInCall
          ? Colors.black.withOpacity(0.3)
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showInCall ? null : _buildAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Auto-scroll when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (chatProvider.messages.isNotEmpty) {
              _scrollToBottom();
            }
          });

          return Container(
            decoration: widget.showInCall
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  )
                : null,
            child: Column(
              children: [
                if (widget.showInCall) _buildInCallHeader(),

                Expanded(
                  child: chatProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMessagesList(chatProvider),
                ),

                // Typing indicator
                if (chatProvider.getTypingIndicatorText().isNotEmpty)
                  TypingIndicator(
                    text: chatProvider.getTypingIndicatorText(),
                  ),

                // Message input
                MessageInput(
                  onSendMessage: (message) {
                    chatProvider.sendMessage(message);
                  },
                  onTypingChanged: (isTyping) {
                    chatProvider.setTyping(isTyping);
                  },
                  onAttachmentTap: _showAttachmentOptions,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chatTitle ?? 'MeetMind Chat',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Text(
                chatProvider.isConnected
                    ? 'Online • ${chatProvider.messages.length} messages'
                    : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showChatOptions,
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInCallHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chat during call',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chatProvider.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chatProvider.isConnected ? 'Live' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: chatProvider.isConnected
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    if (chatProvider.messages.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            )),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(chatProvider, index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatProvider chatProvider, int index) {
    final message = chatProvider.messages[index];
    final isMe = message.senderId == chatProvider.currentUserId;

    // Show date separator if needed
    bool showDateSeparator = false;
    if (index == 0) {
      showDateSeparator = true;
    } else {
      final previousMessage = chatProvider.messages[index - 1];
      final currentDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );
      final previousDate = DateTime(
        previousMessage.timestamp.year,
        previousMessage.timestamp.month,
        previousMessage.timestamp.day,
      );
      showDateSeparator = !currentDate.isAtSameMomentAs(previousDate);
    }

    // Show avatar if it's the first message from this sender in a group
    bool showAvatar = false;
    if (!isMe &&
        (index == 0 ||
            chatProvider.messages[index - 1].senderId != message.senderId ||
            showDateSeparator)) {
      showAvatar = true;
    }

    return Column(
      children: [
        if (showDateSeparator) MessageDateSeparator(date: message.timestamp),
        MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar,
          showTime: true,
          onLongPress: () => _showMessageOptions(message),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.showInCall
                ? 'Start chatting during your call'
                : 'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showInCall
                ? 'Share ideas, notes, and files with participants'
                : 'Send a message to start the conversation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!widget.showInCall)
            ElevatedButton.icon(
              onPressed: () {
                // Quick start with AI assistant
                context.read<ChatProvider>().sendMessage(
                      'Hi AI! Can you help me get started?',
                    );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Ask AI Assistant'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement reply functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement forward functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // Copy message text to clipboard
                // TODO: Implement copy functionality
              },
            ),
            if (message.senderId == context.read<ChatProvider>().currentUserId)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().deleteMessage(message.id);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.green),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                _sharePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _shareDocument();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.purple),
              title: const Text('AI Generated Image'),
              onTap: () {
                Navigator.pop(context);
                _generateAIImage();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search messages'),
              onTap: () {
                Navigator.pop(context);
                _showSearchDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Generate AI summary'),
              onTap: () {
                Navigator.pop(context);
                _generateAISummary();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _sharePhoto() {
    context
        .read<ChatProvider>()
        .sendMessage('📷 Shared a photo', messageType: 'image');
  }

  void _shareDocument() {
    context
        .read<ChatProvider>()
        .sendMessage('📄 Shared a document', messageType: 'file');
  }

  void _generateAIImage() {
    context.read<ChatProvider>().sendMessage(
          '🎨 AI Generated: Beautiful sunset over mountains with vibrant colors',
          messageType: 'ai_generated',
        );
  }

  void _generateAISummary() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(
      '📋 AI Summary: This conversation covered project updates, meeting planning, and AI assistance features. Key topics included video call integration and real-time collaboration tools.',
      messageType: 'ai_generated',
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement search functionality
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
