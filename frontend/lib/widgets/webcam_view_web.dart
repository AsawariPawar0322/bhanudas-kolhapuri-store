import 'package:flutter/material.dart';
import 'webcam_preview.dart';

Widget createWebcamPreview({
  required Function(dynamic) onVideoCreated,
  required Function(String) onError,
}) {
  return WebcamPreview(
    onVideoCreated: (videoElement) {
      onVideoCreated(videoElement);
    },
    onError: onError,
  );
}
