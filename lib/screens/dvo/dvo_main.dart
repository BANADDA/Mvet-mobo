import 'package:flutter/material.dart';

class DvoDashboard extends StatefulWidget {
  const DvoDashboard({Key? key}) : super(key: key);
  @override
  State<DvoDashboard> createState() => _DvoDashboardState();
}

class _DvoDashboardState extends State<DvoDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DVO Dashboard"),
      ),
      body: Center(
        child: Text(
          "Welcome, District Veterinary Officer!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
