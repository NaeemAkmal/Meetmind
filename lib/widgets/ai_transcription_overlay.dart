// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AITranscriptionOverlay extends StatefulWidget {
  final List<String> transcriptions;
  final bool isTranscribing;

  const AITranscriptionOverlay({
    super.key,
    required this.transcriptions,
    required this.isTranscribing,
  });

  @override
  State<AITranscriptionOverlay> createState() => _AITranscriptionOverlayState();
}

class _AITranscriptionOverlayState extends State<AITranscriptionOverlay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(AITranscriptionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcriptions.length > oldWidget.transcriptions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: widget.isTranscribing ? Colors.purple : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Transcription',
                  style: TextStyle(
                    color:
                        widget.isTranscribing ? Colors.purple : Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (widget.isTranscribing)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms),
              ],
            ),
          ),

          // Transcription content
          Flexible(
            child: widget.transcriptions.isEmpty
                ? _buildEmptyState()
                : _buildTranscriptionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isTranscribing ? Icons.mic : Icons.mic_off,
            color: Colors.white54,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isTranscribing
                ? 'Listening for speech...'
                : 'Start speaking to see transcription',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionList() {
    // Add some demo transcriptions if empty
    List<String> displayTranscriptions = widget.transcriptions.isNotEmpty
        ? widget.transcriptions
        : [
            "Welcome to MeetMind!",
            "This is a demo of our AI transcription feature.",
            "All your conversations are automatically transcribed.",
          ];

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: displayTranscriptions.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayTranscriptions[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              Text(
                _formatTime(DateTime.now()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideX(begin: -0.3);
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
