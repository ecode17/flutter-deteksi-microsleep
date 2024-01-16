import 'package:drowsiness_detection/home.dart';
import 'package:drowsiness_detection/plugin-notif/notif.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(StreamKamera());
}

class StreamKamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teachable Machine Flutter',
      theme: ThemeData.dark(),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;
  late List<String> labels = [];
  bool isDetecting = false;
  String recognizedLabel = ''; // Store the recognized label
  int countingClosed = 0;
  late Timer countingTimer;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    NotificationWidget.init();
    loadModel();

    _cameraController = CameraController(
      CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
      ResolutionPreset.medium,
    );

    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    // Initialize countingTimer
    countingTimer = Timer(Duration(seconds: 0), () {});

    // Initialize AudioPlayer
    audioPlayer = AudioPlayer();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );

    try {
      String labelsData = await rootBundle.loadString('assets/labels.txt');
      labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      print('Error loading labels: $e');
    }
  }

  Future<void> runModel(CameraImage image) async {
    if (isDetecting) return;

    isDetecting = true;

    List? recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      // Update the recognized label
      setState(() {
        recognizedLabel = recognitions[0]['label'] ?? '';
        if (recognizedLabel == 'Closed') {
          // Increase the countingClosed
          countingClosed++;

          if (countingClosed > 10) {
            showNotification();
            countingClosed = 0;
          }
        } else {
          countingClosed = 0;
        }
      });
    }

    isDetecting = false;
  }

  Future<void> _toggleCamera() async {
    final lensDirection = _cameraController.description.lensDirection;
    CameraDescription? newCameraDescription;

    if (lensDirection == CameraLensDirection.back) {
      newCameraDescription = (await _getCamera(CameraLensDirection.front))!;
    } else {
      newCameraDescription = await _getCamera(CameraLensDirection.back);
    }

    if (newCameraDescription != null) {
      await _cameraController.dispose();
      _cameraController = CameraController(
        newCameraDescription,
        ResolutionPreset.medium,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<CameraDescription?> _getCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();
    final availableCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == direction,
      // orElse: () => null,
    );

    return availableCamera;
  }

  void showNotification() {
    print('Notification: Time to rest!');
    NotificationWidget.showNotification(
        title: "Notif", body: 'Waktunya Istirahat 🤪🫠');
  }

  @override
  void dispose() {
    countingTimer.cancel(); // Cancel the timer when disposing the widget
    _cameraController.dispose();
    Tflite.close();
    audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    return WillPopScope(
      onWillPop: () async {
        // Tambahkan logika yang diperlukan sebelum kembali
        // Jika ingin tetap di halaman ini, kembalikan nilai false
        // Jika ingin kembali ke halaman sebelumnya, kembalikan nilai true
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onSwitchCamera: _toggleCamera,
        ),
        body: Center(
          child: Stack(
            children: [
              CameraPreview(_cameraController),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label: $recognizedLabel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Closed Count: $countingClosed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      if (countingClosed > 10)
                        Text(
                          'Time to Rest!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _cameraController.startImageStream((CameraImage image) {
              runModel(image);
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFEB000),
            ),
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSwitchCamera;

  CustomAppBar({required this.onSwitchCamera});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        },
      ),
      backgroundColor: Color(0xFFFEB000),
      title: Text('Live Kamera TF Lite'),
      actions: [
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.switch_camera),
          onPressed: onSwitchCamera,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
