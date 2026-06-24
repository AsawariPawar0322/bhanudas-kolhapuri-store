import 'package:flutter/material.dart';
import 'camera_mobile_preview.dart';

Widget createWebcamPreview({
  required Function(dynamic) onVideoCreated,
  required Function(String) onError,
}) {
  return CameraMobilePreview(
    onVideoCreated: onVideoCreated,
    onError: onError,
  );
}
