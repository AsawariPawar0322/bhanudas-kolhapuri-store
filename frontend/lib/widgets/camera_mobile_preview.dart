import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraMobilePreview extends StatefulWidget {
  final Function(dynamic) onVideoCreated;
  final Function(String) onError;

  const CameraMobilePreview({
    super.key,
    required this.onVideoCreated,
    required this.onError,
  });

  @override
  State<CameraMobilePreview> createState() => _CameraMobilePreviewState();
}

class _CameraMobilePreviewState extends State<CameraMobilePreview> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _handleError('No cameras found on this device. Fallback to Simulator.');
        return;
      }

      // Try environment (back) camera first, else fallback to any
      CameraDescription? selectedCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }
      selectedCamera ??= cameras.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        widget.onVideoCreated(_controller!);
      }
    } catch (e) {
      _handleError('Camera Init Error: $e');
    }
  }

  void _handleError(String msg) {
    if (mounted) {
      setState(() {
        _errorMessage = msg;
      });
      widget.onError(msg);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white38, size: 36),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(Colors.white38),
          ),
        ),
      );
    }

    return ClipRect(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }
}
