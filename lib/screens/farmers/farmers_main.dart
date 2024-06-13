import 'package:flutter/material.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/screens/farmers/farm.dart';
import 'package:marcci/screens/farmers/farms/farms_screen.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:marcci/widgets/user_container.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);
  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  LoggedInUserModel? user;
  late Future<LoggedInUserModel> _loggedInUserFuture;
  late Future<FarmModel?> _firstFarmFuture;

  @override
  void initState() {
    super.initState();
    _loggedInUserFuture = LoggedInUserModel.getLoggedInUser();
    _firstFarmFuture = _checkFarmProfile();
  }

  Future<FarmModel?> _checkFarmProfile() async {
    user = await LoggedInUserModel.getLoggedInUser();
    print("Farmer: ${user?.id}");
    FarmModel? firstFarm =
        await FarmModel.getFirstFarmByFarmerId(user!.id.toString());
    print("Farm: ${firstFarm?.farmName}");
    print("Farmer Id: ${firstFarm?.farmerID}");
    return firstFarm;
  }

  Widget buildFarmDetails(FarmModel farm) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        children: [
          buildServiceButton(
              "My Farm", "assets/images/my_farm.png", Color(0xFFDFF7D6), () {
            Get.to(() => MyFarmScreen());
            // Navigate to My Farm screen
          }),
          buildServiceButton(
              "Market", "assets/images/shop.png", Color(0xFFDFF7D6), () {
            // Navigate to Market screen
          }),
          buildServiceButton("Financial Service",
              "assets/images/financial_service.png", Color(0xFFF4F4D8), () {
            // Navigate to Financial Service screen
          }),
          buildServiceButton(
              "Training", "assets/images/training.png", Color(0xFFF4F4D8), () {
            // Navigate to Training screen
          }),
          buildServiceButton("Agricultural Support",
              "assets/images/agricultural_support.png", Color(0xFFDFF7D6), () {
            _showBottomSheet(context, "Agricultural Support",
                "Detailed information about Agricultural Support.");
          }),
          buildServiceButton("Customer Support",
              "assets/images/customer_support.png", Color(0xFFF4F4D8), () {
            _showBottomSheet(context, "Customer Support",
                "Detailed information about Customer Support.");
          }),
        ],
      ),
    );
  }

  Widget buildServiceButton(String title, String iconPath,
      Color backgroundColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 216, 246, 217),
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

  void _showBottomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Farmer Dashboard",
        onBack: () {},
        onSettings: () {
          Get.to(() => AppSettings());
          print("Settings pressed");
        },
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: FutureBuilder<LoggedInUserModel>(
                future: _loggedInUserFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    LoggedInUserModel _loggedInUser = snapshot.data!;
                    return UserContainer(
                      userName: _loggedInUser.name,
                      imagePath: _loggedInUser.avatar,
                      district: _loggedInUser.district_name,
                      districtIcon: Icons.location_city,
                      role: _loggedInUser.role_name,
                      roleIcon: Icons.pets,
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<FarmModel?>(
                future: _firstFarmFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/oops.png',
                          ), // Ensure this image exists in your assets
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No farm profile found. Please register your farm with M-Vet",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 129, 130, 129),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              print("Pressed...");
                              Get.to(() => FarmsScreen(farmer_id: user!.id));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .green[800], // Dark green background color
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
                                    'Profile Farm',
                                    color: Colors.white,
                                    fontSize: screenWidth *
                                        0.045, // Responsive font size
                                    fontWeight: 900,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Icon(
                                    Icons.add_home_work,
                                    size: 24.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return buildFarmDetails(snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
