import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:marcci/widgets/login_screen.dart';

import '../utils/AppConfig.dart';

class BoardingWelcomeScreen extends StatefulWidget {
  BoardingWelcomeScreen({Key? key}) : super(key: key);

  @override
  _CourseTasksScreenState createState() => _CourseTasksScreenState();
}

class _CourseTasksScreenState extends State<BoardingWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double padding =
        screenWidth * 0.05; // Dynamic padding based on screen width

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.local_group),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Opacity(
                opacity:
                    0.7, // You can adjust this value to increase or decrease overall opacity
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 1, 13, 0)
                          .withOpacity(0.9), // White with 30% opacity
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  // Ensures usability on small devices
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "${AppConfig.APP_NAME}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: screenWidth * 0.08, // Dynamic font size
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ClipOval(
                        child: Image(
                            image: AssetImage(AppConfig.logo),
                            width: screenWidth * 0.4, // Responsive image size
                            height: screenWidth * 0.4,
                            fit: BoxFit.cover),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: ClipRect(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.black.withOpacity(1)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Welcome to MVet",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth *
                                            0.045, // Responsive text size
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    FxText.bodyLarge(
                                      "MVet is pioneering innovative AI-driven solutions to enhance livestock health in Uganda. Leveraging data analytics and AI, our initiatives aim to advance diagnosis, treatment, and prevention strategies, improving the livelihoods of farmers and the health of their livestock.",
                                      fontWeight: 600,
                                      textAlign: TextAlign.justify,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: _showLoginOptionDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green[800], // Dark green background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded edges
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FxText(
                                'Get Started',
                                color: Colors.white,
                                fontSize:
                                    screenWidth * 0.045, // Responsive font size
                                fontWeight: 900,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Icon(
                                Icons.forward,
                                size: 24.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginOptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Login as:'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => LoginWidget(userType: 'Farmer'));
              },
              child: Text('Farmer'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => LoginWidget(userType: 'Animal Officer'));
              },
              child: Text('Animal Officer'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => LoginWidget(userType: 'DVO'));
              },
              child: Text('DVO'), // DVO stands for District Veterinary Officer
            ),
          ],
        );
      },
    );
  }
}
