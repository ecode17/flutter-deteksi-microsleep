import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(KameraPreview());
}

class KameraPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Kamera(),
    );
  }
}

class Kamera extends StatefulWidget {
  @override
  _KameraState createState() => _KameraState();
}

class _KameraState extends State<Kamera> {
  List<CameraDescription>? cameras;
  CameraController? controller;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  void switchCamera() async {
    if (cameras != null && cameras!.length > 1) {
      int currentCameraIndex = cameras!.indexOf(controller!.description);
      int newCameraIndex = (currentCameraIndex + 1) % cameras!.length;
      CameraDescription newCamera = cameras![newCameraIndex];
      await controller!.dispose();
      controller = CameraController(newCamera, ResolutionPreset.max);
      await controller!.initialize();
      setState(() {});
    }
  }

  Future<void> loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      await controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } else {
      print("No camera found");
    }
  }

  Future<void> sendImageToServer(Uint8List imageData) async {
    try {
      var uri = Uri.parse('http://192.168.205.106:5000/driver');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('image', imageData,
            filename: 'image.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Response: ${await response.stream.bytesToString()}');
      } else {
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending image: $error');
    }
  }

  Future<void> _onCapturePressed() async {
    try {
      XFile? file = await controller!.takePicture();
      if (file != null) {
        Uint8List imageBytes = await File(file.path).readAsBytes();
        await sendImageToServer(imageBytes);
        print('Image path: ${file.path}');
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Camera"),
        backgroundColor: Color(0xFFFEB000),
        actions: [
          FloatingActionButton(
            onPressed: () {
              switchCamera();
            },
            child: Icon(
              Icons.switch_camera,
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ],
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 700,
                width: 600,
                child: controller == null
                    ? Center(child: Text("Loading Camera..."))
                    : !controller!.value.isInitialized
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : CameraPreview(controller!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
