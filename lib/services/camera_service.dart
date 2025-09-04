import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isVideoEnabled => _controller?.value.isRecordingVideo ?? false;

  // Initialize camera
  Future<bool> initializeCamera() async {
    try {
      if (kIsWeb) {
        // For web, we'll create a simple camera placeholder
        // Real WebRTC implementation would go here
        _isInitialized = true;
        return true;
      }

      // For mobile platforms
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return false;

      _controller = CameraController(_cameras.first, ResolutionPreset.medium);

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  // Start camera preview
  Future<void> startCamera() async {
    if (!_isInitialized) {
      await initializeCamera();
    }

    if (kIsWeb) {
      // Web: Request user media access
      print('Starting web camera...');
      // In real implementation, we'd use WebRTC getUserMedia()
      return;
    }

    // Mobile: Start camera controller
    if (_controller != null && !_controller!.value.isInitialized) {
      await _controller!.initialize();
    }
  }

  // Stop camera
  Future<void> stopCamera() async {
    if (kIsWeb) {
      print('Stopping web camera...');
      return;
    }

    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  // Toggle camera on/off
  Future<void> toggleCamera() async {
    if (kIsWeb) {
      // For web, we'll simulate camera toggle
      print('Toggling web camera...');
      return;
    }

    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        await stopCamera();
      } else {
        await startCamera();
      }
    }
  }

  // Switch between front and back camera (mobile only)
  Future<void> switchCamera() async {
    if (kIsWeb || _cameras.length < 2) return;

    final currentCamera = _controller?.description;
    final newCamera = _cameras.firstWhere(
      (camera) => camera != currentCamera,
      orElse: () => _cameras.first,
    );

    await _controller?.dispose();
    _controller = CameraController(newCamera, ResolutionPreset.medium);
    await _controller!.initialize();
  }

  // Get camera preview widget
  Widget getCameraPreview() {
    if (kIsWeb) {
      // For web, return a placeholder that looks like camera
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, color: Colors.white, size: 32),
              SizedBox(height: 8),
              Text(
                'Camera Active',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // For mobile, return actual camera preview
    if (_controller != null && _controller!.value.isInitialized) {
      return CameraPreview(_controller!);
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Camera Off',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void dispose() {
    _controller?.dispose();
  }
}
