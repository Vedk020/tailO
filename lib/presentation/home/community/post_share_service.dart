import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PostShareService {
  static Future<void> captureAndShare(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("Error: Boundary is null");
        return;
      }

      // 1. Capture Image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Save to Temp
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/tailo_story.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);

      // 3. Share
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Check out this story on #tailO! 🐾');
    } catch (e) {
      debugPrint("Error sharing post: $e");
    }
  }
}
