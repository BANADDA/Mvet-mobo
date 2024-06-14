// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/FarmModel.dart';

class MyFarmScreen extends StatefulWidget {
  final FarmModel farm;
  const MyFarmScreen({Key? key, required this.farm}) : super(key: key);
  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget buildServiceButton(
        String title, String iconPath, VoidCallback onPressed) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFDFF7D6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                height: 50,
                width: 50,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Farm",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                children: [
                  buildServiceButton("Feeds", "assets/images/weather.png", () {
                    _showAnimalFeedsBottomSheet(context);
                  }),
                  buildServiceButton(
                      "Health", "assets/images/health.png", () {}),
                  buildServiceButton("Animal", "assets/images/cow.png", () {}),
                  buildServiceButton(
                      "Yields", "assets/images/yields.png", () {}),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Farm Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "30 April 2023",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Tasks",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          buildTaskItem("Milk yield", 10),
                          buildTaskItem("Health check", 5),
                          buildTaskItem("Animal record", 3),
                          buildTaskItem("Feed stock", 8),
                          buildTaskItem("Breeding", 4),
                          buildTaskItem("Calving", 2),
                          buildTaskItem("Buy new seeds", 6),
                          buildTaskItem("Check crops growth", 7),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskItem(String title, int quantity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(
          quantity.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      trailing: Text(
        "Tasks",
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAnimalFeedsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<Map<String, dynamic>> feedData = [{}];
            List<Widget> feedForms = [
              _buildFeedForm(0, setState, feedData),
            ];

            void addFeedForm() {
              setState(() {
                feedData.add({});
                feedForms.add(
                    _buildFeedForm(feedData.length - 1, setState, feedData));
              });
            }

            void removeFeedForm(int index) {
              setState(() {
                feedData.removeAt(index);
                feedForms.removeAt(index);
              });
            }

            void submitFeedData() {
              bool isValid = true;
              feedData.forEach((feed) {
                if (feed['name'] == null ||
                    feed['quantity'] == null ||
                    feed['date'] == null) {
                  isValid = false;
                }
              });

              if (isValid) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields'),
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Animal Feeds",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: feedForms,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ElevatedButton(
                        //   onPressed: addFeedForm,
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.white,
                        //     backgroundColor: Colors.blue, // foreground
                        //   ),
                        //   child: Text("Add New Feed"),
                        // ),
                        ElevatedButton(
                          onPressed: submitFeedData,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // foreground
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("Submit Feeds"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedForm(
      int index, StateSetter setState, List<Map<String, dynamic>> feedData) {
    TextEditingController dateController = TextEditingController();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
          feedData[index]['date'] = dateController.text;
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  feedData[index]['name'] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Feed Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  feedData[index]['quantity'] = value;
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _selectDate(context as BuildContext);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
            // IconButton(
            //   icon: Icon(Icons.delete),
            //   onPressed: () => removeFeedForm(index),
            // ),
          ],
        ),
      ),
    );
  }
}
