// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../widgets/call_controls.dart';
import '../widgets/ai_transcription_overlay.dart';
import '../screens/chat_screen.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isCallActive = false;
  bool _showTranscription = false;
  bool _showChatOverlay = false;
  final AIService _aiService = AIService();
  final AudioRecorder _recorder = AudioRecorder();
  bool _cameraInitialized = false;

  // For web speech recognition simulation
  List<String> _demoTranscriptions = [];
  int _transcriptionIndex = 0;

  // Call timer
  DateTime? _callStartTime;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  // Transcription timer
  Timer? _transcriptionTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await [
        Permission.camera,
        Permission.microphone,
        Permission.storage,
      ].request();
    } else {
      // Web permissions are handled by browser
      await [Permission.camera, Permission.microphone].request();
    }
  }

  void _startCall() async {
    setState(() {
      _isCallActive = true;
      _callStartTime = DateTime.now();
      _callDuration = Duration.zero;
    });

    // Start call timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime!);
        });
      }
    });

    final appState = context.read<AppState>();
    appState.startCall('demo-call-${DateTime.now().millisecondsSinceEpoch}');

    // Initialize camera and start recording
    await _initializeCamera();
    await _startRecording();

    // Auto-start transcription for demo
    setState(() {
      _showTranscription = true;
    });
    await _startSpeechRecognition();
  }

  Future<void> _initializeCamera() async {
    try {
      if (kIsWeb) {
        // For web, simulate camera initialization
        setState(() {
          _cameraInitialized = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📸 Camera ready (Web simulation)'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      final appState = context.read<AppState>();

      if (kIsWeb) {
        // Web speech recognition simulation
        appState.startRecording();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎤 Recording started (Web simulation)'),
              backgroundColor: Colors.purple,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Mobile recording
        bool hasPermission = await _recorder.hasPermission();
        if (hasPermission) {
          const config = RecordConfig(encoder: AudioEncoder.wav);
          await _recorder.start(config, path: 'temp_recording.wav');
          appState.startRecording();
        }
      }
    } catch (e) {
      print('Recording error: $e');
    }
  }

  Future<void> _startSpeechRecognition() async {
    final appState = context.read<AppState>();

    try {
      if (kIsWeb) {
        // Web: Simulate speech recognition with demo data
        _demoTranscriptions = [
          'Welcome to MeetMind AI-powered calling!',
          'This is a demonstration of real-time transcription.',
          'Our AI can understand and transcribe conversations.',
          'You can see live captions during your calls.',
          'AI will also generate smart summaries after calls.',
        ];

        _simulateTranscription();
      } else {
        // Mobile: Use real speech recognition
        await _aiService.startListening(
          onResult: (text) {
            appState.addTranscription(text);
          },
          onError: (error) {
            print('Speech recognition error: $error');
          },
        );
      }
    } catch (e) {
      print('Speech recognition initialization error: $e');
    }
  }

  void _simulateTranscription() {
    if (!_isCallActive || _transcriptionIndex >= _demoTranscriptions.length) {
      return;
    }

    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isCallActive || !_showTranscription) {
        timer.cancel();
        return;
      }

      if (_transcriptionIndex < _demoTranscriptions.length) {
        final appState = context.read<AppState>();
        appState.addTranscription(_demoTranscriptions[_transcriptionIndex]);
        _transcriptionIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  void _endCall() {
    setState(() {
      _isCallActive = false;
    });

    // Clean up timers
    _callTimer?.cancel();
    _transcriptionTimer?.cancel();

    final appState = context.read<AppState>();
    appState.endCall();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _transcriptionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video area
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a1a2e),
                      Color(0xFF16213e),
                      Color(0xFF0f3460),
                    ],
                  ),
                ),
                child: _isCallActive ? _buildActiveCallUI() : _buildPreCallUI(),
              ),
            ),

            // AI Transcription Overlay
            if (_showTranscription && _isCallActive)
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: AITranscriptionOverlay(
                  transcriptions: appState.callTranscriptions,
                  isTranscribing: appState.isTranscribing,
                ).animate().slideY(begin: -1),
              ),

            // Chat Overlay
            if (_showChatOverlay && _isCallActive)
              Positioned(
                right: 16,
                top: 100,
                bottom: 120,
                width: MediaQuery.of(context).size.width * 0.3,
                child: _buildChatOverlay().animate().slideX(begin: 1),
              ),

            // Call Controls
            if (_isCallActive)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: CallControls(
                  isVideoEnabled: appState.isVideoEnabled,
                  isAudioEnabled: appState.isAudioEnabled,
                  isRecording: appState.isRecording,
                  onVideoToggle: () {
                    appState.toggleVideo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appState.isVideoEnabled
                              ? '📹 Camera turned on'
                              : '📹 Camera turned off',
                        ),
                        backgroundColor:
                            appState.isVideoEnabled ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onAudioToggle: () {
                    appState.toggleAudio();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appState.isAudioEnabled
                              ? '🎤 Microphone turned on'
                              : '🎤 Microphone turned off',
                        ),
                        backgroundColor:
                            appState.isAudioEnabled ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onEndCall: _endCall,
                  onToggleTranscription: () {
                    setState(() {
                      _showTranscription = !_showTranscription;
                    });
                  },
                  onToggleChat: () {
                    setState(() {
                      _showChatOverlay = !_showChatOverlay;
                    });
                  },
                ).animate().slideY(begin: 1),
              ),

            // Back button (only when not in call)
            if (!_isCallActive)
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreCallUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(Icons.video_call, size: 64, color: Colors.white),
          ).animate().scale(),

          const SizedBox(height: 32),

          Text(
            'MeetMind',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),

          const SizedBox(height: 8),

          Text(
            'AI-Powered Video Calling',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 48),

          // Start call button
          ElevatedButton(
            onPressed: _startCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Start Demo Call',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ).animate().scale(delay: 400.ms),

          const SizedBox(height: 24),

          // Features preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Transcription',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.summarize, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Summaries',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Persistent Chat',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildActiveCallUI() {
    return Stack(
      children: [
        // Remote video placeholder
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 16),
                  Text(
                    'Demo Participant',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Connected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ),
        ),

        // Local video preview (bottom right)
        Positioned(
          bottom: 140,
          right: 20,
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appState.isVideoEnabled
                        ? Colors.green.withOpacity(0.6)
                        : Colors.white.withOpacity(0.3),
                    width: appState.isVideoEnabled ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: appState.isVideoEnabled
                          ? const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            )
                          : null,
                      color: appState.isVideoEnabled ? null : Colors.grey[900],
                    ),
                    child: appState.isVideoEnabled
                        ? Stack(
                            children: [
                              // Simulated camera preview with gradient
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFF4c6ef5),
                                      Color(0xFF364fc7),
                                      Color(0xFF1864ab),
                                    ],
                                  ),
                                ),
                              ),
                              // Camera preview overlay with user icon
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Camera active indicator
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.videocam_off,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Camera Off',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            },
          ).animate().slideX(begin: 1, delay: 300.ms),
        ),

        // Call duration
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_callDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ),
      ],
    );
  }

  Widget _buildChatOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: const ChatScreen(
        chatRoomId: 'video_call_chat',
        chatTitle: 'Call Chat',
        showInCall: true,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
