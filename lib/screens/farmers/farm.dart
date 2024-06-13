import 'package:flutter/material.dart';
import 'package:marcci/models/FarmModel.dart';

class MyFarmScreen extends StatelessWidget {
  final FarmModel farm;
  const MyFarmScreen({Key? key, required this.farm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget buildServiceButton(String title, String iconPath) {
      return Container(
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
                  buildServiceButton("Feeds", "assets/images/weather.png"),
                  buildServiceButton("Health", "assets/images/equipment.png"),
                  buildServiceButton("Animal", "assets/images/my_crops.png"),
                  buildServiceButton("Yields", "assets/images/my_cattle.png"),
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          // Add task action
                        },
                        backgroundColor: Colors.green,
                        child: Icon(Icons.add),
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
}
