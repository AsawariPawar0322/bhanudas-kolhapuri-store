import 'package:flutter/material.dart';

Widget createWebcamPreview({
  required Function(dynamic) onVideoCreated,
  required Function(String) onError,
}) {
  return Container(
    color: Colors.black,
    child: const Center(
      child: Text(
        'Camera Preview Placeholder',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
  );
}
