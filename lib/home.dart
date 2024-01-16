import 'package:drowsiness_detection/cam-server/kamera-server.dart';
import 'package:drowsiness_detection/stream-cam/stream-cam.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEB000),
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Show the modal popup when the "START" button is clicked
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    'Akses Live Kamera',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 40),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => Kamera(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFFEB000),
                                      onPrimary: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      minimumSize: Size(200, 50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cameraswitch_sharp,
                                            color: Colors
                                                .white), // Ganti ikon sesuai keinginan
                                        SizedBox(
                                            width:
                                                8), // Jarak antara ikon dan teks
                                        Text(
                                          'Kamera Server',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => StreamKamera(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Color(0xFFFEB000),
                                      onPrimary: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      minimumSize: Size(200, 50),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt,
                                            color: Colors
                                                .white), // Ganti ikon sesuai keinginan
                                        SizedBox(
                                            width:
                                                8), // Jarak antara ikon dan teks
                                        Text(
                                          'Kamera TF Lite',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: Size(150, 50),
                      ),
                      child: Text(
                        'START',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Tap to start!',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 70,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(0), // Gunakan padding 0 pada DrawerHeader
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    18, 0, 16.0, 25), // Sesuaikan padding di sini
                color: Color(0xFFFEB000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aplikasi\nDrowsiness Detection',
                      style: TextStyle(
                        color: Color.fromARGB(255, 243, 243, 243),
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_outlined),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_sharp),
              title: Text(
                'Kamera TF Lite',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => StreamKamera(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.work_outline_rounded),
              title: Text(
                'Our Team',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                'About',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
