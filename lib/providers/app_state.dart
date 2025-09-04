import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // User State
  String? _currentUserId;
  String? _userName;
  bool _isLoggedIn = false;

  // Call State
  bool _isInCall = false;
  String? _currentCallId;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isRecording = false;

  // AI State
  final List<String> _callTranscriptions = [];
  String? _currentCallSummary;
  bool _isTranscribing = false;

  // Chat State
  int _unreadMessages = 0;
  bool _isTyping = false;

  // Getters
  String? get currentUserId => _currentUserId;
  String? get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isRecording => _isRecording;
  List<String> get callTranscriptions => _callTranscriptions;
  String? get currentCallSummary => _currentCallSummary;
  bool get isTranscribing => _isTranscribing;
  int get unreadMessages => _unreadMessages;
  bool get isTyping => _isTyping;

  // User Methods
  void login(String userId, String userName) {
    _currentUserId = userId;
    _userName = userName;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUserId = null;
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Call Methods
  void startCall(String callId) {
    _isInCall = true;
    _currentCallId = callId;
    _callTranscriptions.clear();
    _currentCallSummary = null;
    notifyListeners();
  }

  void endCall() {
    _isInCall = false;
    _currentCallId = null;
    _isRecording = false;
    _isTranscribing = false;
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoEnabled = !_isVideoEnabled;
    notifyListeners();
  }

  void toggleAudio() {
    _isAudioEnabled = !_isAudioEnabled;
    notifyListeners();
  }

  void startRecording() {
    _isRecording = true;
    _isTranscribing = true;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    _isTranscribing = false;
    notifyListeners();
  }

  // AI Methods
  void addTranscription(String transcription) {
    _callTranscriptions.add(transcription);
    notifyListeners();
  }

  void setCallSummary(String summary) {
    _currentCallSummary = summary;
    notifyListeners();
  }

  void setTranscribing(bool isTranscribing) {
    _isTranscribing = isTranscribing;
    notifyListeners();
  }

  // Chat Methods
  void setUnreadMessages(int count) {
    _unreadMessages = count;
    notifyListeners();
  }

  void markMessagesAsRead() {
    _unreadMessages = 0;
    notifyListeners();
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }
}
