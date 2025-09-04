// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(bool) onTypingChanged;
  final VoidCallback? onAttachmentTap;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onTypingChanged,
    this.onAttachmentTap,
    this.isEnabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;

    if (_isComposing != hasText) {
      setState(() {
        _isComposing = hasText;
      });
    }

    // Handle typing indicator
    if (hasText) {
      widget.onTypingChanged(true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        widget.onTypingChanged(false);
      });
    } else {
      widget.onTypingChanged(false);
      _typingTimer?.cancel();
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty || !widget.isEnabled) return;

    widget.onSendMessage(text.trim());
    _textController.clear();
    widget.onTypingChanged(false);
    _typingTimer?.cancel();

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;

    // Handle case when text is empty or no valid selection
    final start = selection.isValid && selection.start >= 0
        ? selection.start
        : text.length;
    final end =
        selection.isValid && selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(
      start,
      end,
      emoji,
    );

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + emoji.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              IconButton(
                onPressed: widget.isEnabled ? widget.onAttachmentTap : null,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: widget.isEnabled ? Colors.grey[600] : Colors.grey[400],
                ),
                tooltip: 'Attach file',
              ),

              // Message input field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          enabled: widget.isEnabled,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          onSubmitted: _handleSubmitted,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.2,
                          ),
                        ),
                      ),

                      // Emoji button
                      IconButton(
                        onPressed: widget.isEnabled ? _showEmojiPicker : null,
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: widget.isEnabled
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        tooltip: 'Add emoji',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send/Voice button
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _isComposing && widget.isEnabled
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isComposing && widget.isEnabled
                      ? () => _handleSubmitted(_textController.text)
                      : (widget.isEnabled ? _showVoiceRecorder : null),
                  icon: Icon(
                    _isComposing ? Icons.send : Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip:
                      _isComposing ? 'Send message' : 'Record voice message',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    // Simple emoji picker implementation
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmojiPickerBottomSheet(
        onEmojiSelected: _insertEmoji,
      ),
    );
  }

  void _showVoiceRecorder() {
    // Show voice recording modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _VoiceRecorderBottomSheet(
        onVoiceMessageSent: (String voiceMessage) {
          widget.onSendMessage('🎤 Voice message: $voiceMessage');
        },
      ),
    );
  }
}

class _EmojiPickerBottomSheet extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const _EmojiPickerBottomSheet({
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = [
      '😀',
      '😂',
      '🤣',
      '😊',
      '😍',
      '🥰',
      '😘',
      '😎',
      '🤔',
      '😴',
      '😇',
      '🤗',
      '🙃',
      '😉',
      '🤤',
      '😋',
      '👍',
      '👎',
      '👏',
      '🙌',
      '👌',
      '🤞',
      '✌️',
      '🤘',
      '❤️',
      '💕',
      '💖',
      '💗',
      '💓',
      '💙',
      '💚',
      '💛',
      '🔥',
      '⭐',
      '✨',
      '💫',
      '🌟',
      '💯',
      '✅',
      '❌',
      '🎉',
      '🎊',
      '🎈',
      '🎁',
      '🎂',
      '🍕',
      '🍔',
      '🍿',
    ];

    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
              'Choose an emoji',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onEmojiSelected(emojis[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        emojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceRecorderBottomSheet extends StatefulWidget {
  final Function(String) onVoiceMessageSent;

  const _VoiceRecorderBottomSheet({
    required this.onVoiceMessageSent,
  });

  @override
  State<_VoiceRecorderBottomSheet> createState() =>
      _VoiceRecorderBottomSheetState();
}

class _VoiceRecorderBottomSheetState extends State<_VoiceRecorderBottomSheet>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    _animationController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });

    _timer?.cancel();
    _animationController.stop();

    // Simulate voice message transcription
    final transcription = _getSimulatedTranscription();
    widget.onVoiceMessageSent(transcription);

    Navigator.pop(context);
  }

  void _cancelRecording() {
    _timer?.cancel();
    _animationController.stop();
    Navigator.pop(context);
  }

  String _getSimulatedTranscription() {
    final transcriptions = [
      'This is a voice message',
      'Let me share some thoughts about this',
      'I think we should discuss this further',
      'Great idea! I agree with your proposal',
      'Can we schedule a follow-up meeting?',
    ];
    return transcriptions[DateTime.now().millisecond % transcriptions.length];
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (_isRecording) ...[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 80 + (_animationController.value * 20),
                  height: 80 + (_animationController.value * 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Recording...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                GestureDetector(
                  onTap: _cancelRecording,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // Send button
                GestureDetector(
                  onTap: _stopRecording,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
