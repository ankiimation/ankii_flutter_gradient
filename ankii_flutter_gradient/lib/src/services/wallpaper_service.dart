import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

//ANDROID ONLY
const String wallpaperPath = "/GradientWallpapers";

class WallpaperService {
  static Future<Uint8List> createPng(GlobalKey globalKey) async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }

  static Future<String> save(ByteData byteData,
      {String fileName = "ankiimation.png"}) async {
    var rootPath = await getExternalStorageDirectory();
    String fullPath = rootPath.path + wallpaperPath + "/" + fileName;
    await Directory(rootPath.path + wallpaperPath).create();
    File file = await File(fullPath).create();
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }
}
