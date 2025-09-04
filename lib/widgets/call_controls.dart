// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CallControls extends StatelessWidget {
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final bool isRecording;
  final VoidCallback onVideoToggle;
  final VoidCallback onAudioToggle;
  final VoidCallback onEndCall;
  final VoidCallback onToggleTranscription;
  final VoidCallback onToggleChat;

  const CallControls({
    super.key,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
    required this.isRecording,
    required this.onVideoToggle,
    required this.onAudioToggle,
    required this.onEndCall,
    required this.onToggleTranscription,
    required this.onToggleChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Video toggle
          _buildControlButton(
            icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            isActive: isVideoEnabled,
            onTap: onVideoToggle,
            backgroundColor:
                isVideoEnabled ? Colors.white.withOpacity(0.2) : Colors.red,
          ).animate().scale(delay: 100.ms),

          // Audio toggle
          _buildControlButton(
            icon: isAudioEnabled ? Icons.mic : Icons.mic_off,
            isActive: isAudioEnabled,
            onTap: onAudioToggle,
            backgroundColor:
                isAudioEnabled ? Colors.white.withOpacity(0.2) : Colors.red,
          ).animate().scale(delay: 200.ms),

          // AI Transcription toggle
          _buildControlButton(
            icon: Icons.auto_awesome,
            isActive: isRecording,
            onTap: onToggleTranscription,
            backgroundColor:
                isRecording ? Colors.purple : Colors.white.withOpacity(0.2),
            size: 48,
          ).animate().scale(delay: 300.ms),

          // Chat toggle
          _buildControlButton(
            icon: Icons.chat,
            isActive: false,
            onTap: onToggleChat,
            backgroundColor: Colors.white.withOpacity(0.2),
          ).animate().scale(delay: 400.ms),

          // End call
          _buildControlButton(
            icon: Icons.call_end,
            isActive: false,
            onTap: onEndCall,
            backgroundColor: Colors.red,
            size: 56,
          ).animate().scale(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color backgroundColor,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
}
