import 'package:flutter/material.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/SampleModel.dart';
import 'package:marcci/screens/animal_officer/animals/AnimalFormsScreen.dart';
import 'package:marcci/screens/animal_officer/farms/farm_list.dart';
import 'package:marcci/screens/animal_officer/reports/animal_samples_screen.dart';
import 'package:marcci/screens/animal_officer/reports/reports_screen.dart';
import 'package:marcci/widgets/user_container.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LoggedInUserModel _loggedInUser;
  int _reportCount = 7;
  int _farmCount = 7;
  int _sampleCount = 7;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _fetchLoggedInUser() async {
    _loggedInUser = await LoggedInUserModel.getLoggedInUser();
  }

  Future<void> _init() async {
    if (!_isLoading) return;
    _isLoading = true;
    await _fetchLoggedInUser();
    _reportCount = await ReportModel.report_count();
    _farmCount = await FarmModel.farm_count();
    _sampleCount = await SampleModel.sample_count();
    setState(() {
      _isLoading = false;
    });
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading // Check if data is still loading
        ? Center(
            child: CircularProgressIndicator(), // Show loading indicator
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                color: Color.fromARGB(255, 241, 249, 241),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: _loggedInUser != null
                          ? UserContainer(
                              userName: _loggedInUser.name,
                              imagePath: _loggedInUser.avatar,
                              district: _loggedInUser.district_name,
                              districtIcon: Icons.location_city,
                              role: _loggedInUser.role_name,
                              roleIcon: Icons.pets,
                            )
                          : SizedBox(), // Display nothing if user data is not available
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          FxText(
                            "Statistics",
                            fontWeight: 800,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 246, 248, 246),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // First Section
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(Icons.people),
                                      SizedBox(height: 8),
                                      Text('${_farmCount}'),
                                      Text('Farms'),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 5,
                                  width: 24,
                                  color: Color.fromARGB(255, 14, 14, 14),
                                ),
                                // Second Section
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(Icons.file_copy),
                                      SizedBox(height: 8),
                                      Text('${_reportCount}'),
                                      Text('Reports'),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 5,
                                  width: 24,
                                  color: Color.fromARGB(255, 14, 14, 14),
                                ),
                                // Third Section
                                Expanded(
                                  child: Column(
                                    children: [
                                      Icon(Icons.science),
                                      SizedBox(height: 8),
                                      Text('${_sampleCount}'),
                                      Text('Samples'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          FxText(
                            "M-Vet Menu",
                            fontWeight: 800,
                            fontSize: 16,
                          ),
                          SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            padding: const EdgeInsets.all(4.0),
                            mainAxisSpacing: 40.0,
                            crossAxisSpacing: 40.0,
                            children: <Widget>[
                              MenuItemCard(
                                icon: 'assets/images/farmer.png',
                                title: "Farm Records",
                                onTap: () {
                                  print("Managing Farmer Records tapped");
                                  Get.to(() => FarmsListScreen());
                                },
                              ),
                              MenuItemCard(
                                icon: 'assets/images/reports.png',
                                title: "Field Reports",
                                onTap: () {
                                  print("Field Reports tapped");
                                  Get.to(() => Reports());
                                },
                              ),
                              MenuItemCard(
                                icon: 'assets/images/animals.png',
                                title: "Animal Forms",
                                onTap: () {
                                  print("Animal Forms tapped");
                                  Get.to(() => AnimalFormsScreen());
                                },
                              ),
                              MenuItemCard(
                                icon: 'assets/images/samples.png',
                                title: "Animal Samples",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AnimalSamplesScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          );
  }
}

class MenuItemCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const MenuItemCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip
          .antiAlias, // Ensures the image does not bleed outside the rounded corners
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              color: const Color.fromARGB(255, 1, 41, 2).withOpacity(0.8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
