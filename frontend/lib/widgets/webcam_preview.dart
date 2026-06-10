import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebcamPreview extends StatefulWidget {
  final Function(html.VideoElement) onVideoCreated;
  final Function(String)? onError;

  const WebcamPreview({
    super.key,
    required this.onVideoCreated,
    this.onError,
  });

  @override
  State<WebcamPreview> createState() => _WebcamPreviewState();
}

class _WebcamPreviewState extends State<WebcamPreview> {
  html.VideoElement? _videoElement;
  bool _isStreaming = false;
  String? _error;
  late String _viewId;
  html.MediaStream? _mediaStream;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..setAttribute('webkit-playsinline', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Register the platform view factory using modern dart:ui_web
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement!,
    );

    // Explicitly call play when metadata is loaded to ensure it handles autoplay policies
    _videoElement!.onLoadedMetadata.listen((_) {
      _videoElement!.play().catchError((e) {
        debugPrint('Error starting video playback: $e');
      });
    });

    _startWebcam();
  }

  Future<void> _startWebcam() async {
    try {
      if (html.window.navigator.mediaDevices == null) {
        _handleError('navigator.mediaDevices is null. Please ensure you are running on localhost or HTTPS.');
        return;
      }

      html.MediaStream? stream;
      try {
        // Try getting environment (back) camera first (ideal, not mandatory)
        stream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': {
            'facingMode': {'ideal': 'environment'}
          }
        });
      } catch (e) {
        debugPrint('Failed to get environment camera, trying fallback: $e');
        // Fallback to any available video stream (like front webcam on desktop)
        stream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': true
        });
      }
      
      if (mounted) {
        setState(() {
          _mediaStream = stream;
          _videoElement!.srcObject = stream;
          _isStreaming = true;
        });
        widget.onVideoCreated(_videoElement!);
      }
    } catch (e) {
      _handleError('Camera access error: $e\n\nEnsure camera permissions are allowed in your browser.');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _error = message;
      });
      if (widget.onError != null) {
        widget.onError!(message);
      }
    }
  }

  @override
  void dispose() {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) {
        try {
          track.stop();
        } catch (e) {
          debugPrint('Error stopping camera track: $e');
        }
      });
    }
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white38, size: 36),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_isStreaming) {
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

    return HtmlElementView(viewType: _viewId);
  }
}
