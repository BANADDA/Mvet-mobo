import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/screens/animal_officer/farms/farm_list.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/utils/dimensions.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmDetails extends StatefulWidget {
  final String district_name;

  const FarmDetails({Key? key, required this.district_name}) : super(key: key);

  @override
  State<FarmDetails> createState() => _FarmDetailsState();
}

class _FarmDetailsState extends State<FarmDetails> {
  List<Map<String, TextEditingController>> animalsControllers = [];
  // Create a list of management systems to be displayed as checkboxes

  // Declare the management systems list as a state variable
  late List<Map<String, dynamic>> managementSystems;
  List<Map<String, dynamic>> defaultManagementSystems = [
    {'name': 'Intensive (Zero grazing)', 'isChecked': false},
    {'name': 'Extensive', 'isChecked': false},
    {'name': 'Semi-intensive', 'isChecked': false},
    {'name': 'Communal grazing', 'isChecked': false},
    {'name': 'Paddock grazing', 'isChecked': false},
    {'name': 'Tethering', 'isChecked': false},
    {'name': 'Free-range', 'isChecked': false},
    {'name': 'Seasonal grazing', 'isChecked': false},
  ];

  @override
  void initState() {
    super.initState();
    managementSystems =
        List<Map<String, dynamic>>.from(defaultManagementSystems);
    loadDataFromSharedPreferences();
  }

  void loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? managementSystemsData =
        prefs.getStringList('managementSystemsData');

    if (managementSystemsData != null) {
      var tempSystems =
          List<Map<String, dynamic>>.from(defaultManagementSystems);
      for (var data in managementSystemsData) {
        List<String> splitData = data.split(':');
        if (splitData.length == 2) {
          String name = splitData[0];
          bool isChecked = splitData[1] == 'true';
          int index =
              tempSystems.indexWhere((system) => system['name'] == name);
          if (index != -1) {
            tempSystems[index]['isChecked'] = isChecked;
          }
        }
      }
      setState(() {
        managementSystems = tempSystems;
      });
    }
  }

  void addAnimal() {
    setState(() {
      animalsControllers.add({
        "type": TextEditingController(),
        "total": TextEditingController(),
      });
    });
  }

  void removeAnimal(int index) {
    setState(() {
      animalsControllers[index]["type"]?.dispose();
      animalsControllers[index]["total"]?.dispose();
      animalsControllers.removeAt(index);
    });
  }

  void toggleManagementSystem(int index) {
    setState(() {
      managementSystems[index]['isChecked'] =
          !managementSystems[index]['isChecked'];
    });
  }

  @override
  void dispose() {
    saveDataToSharedPreferences(); // Save data when leaving the screen
    // Dispose all controllers to prevent memory leaks
    for (var animalController in animalsControllers) {
      animalController["type"]?.dispose();
      animalController["total"]?.dispose();
    }
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: FxAppBar(
          titleText: "Farm Profiling",
          onSettings: () {
            Get.to(() => const AppSettings());
          },
          onBack: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 6, 98, 1),
                        ),
                        child: FxText(
                          "Farm Details",
                          color: Colors.white,
                          fontWeight: 900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  ...animalsControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, TextEditingController> controllers =
                        entry.value;
                    return Container(
                      color: Color.fromARGB(255, 235, 247, 236),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              controller: controllers["type"],
                              decoration: InputDecoration(
                                  labelText: "Animal",
                                  hintText: "Enter animal type",
                                  filled: true,
                                  fillColor:
                                      Color.fromARGB(255, 235, 247, 236)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter animal type';
                                }
                                return null;
                              },
                            )),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: controllers["total"],
                                decoration: InputDecoration(
                                    labelText: "Total",
                                    hintText: "Enter total number",
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 235, 247, 236)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter number of animals';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => removeAnimal(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: addAnimal,
                              child: Text("Add Animal +"),

                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 1, 78, 3),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 15, // Responsive padding
                                  )),
                              //... Other buttons like "Back" and "Next"
                            ))
                      ])),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 6, 98, 1),
                        ),
                        child: FxText(
                          "Management System",
                          color: Colors.white,
                          fontWeight: 900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  for (var managementSystem in managementSystems)
                    CheckboxListTile(
                      title: Text(managementSystem['name']),
                      value: managementSystem['isChecked'],
                      onChanged: (bool? value) {
                        setState(() {
                          managementSystem['isChecked'] = value!;
                        });
                      },
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 80.0,
                      ),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submitForm();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 1, 78, 3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.0098,
                                horizontal:
                                    screenWidth * 0.15, // Responsive padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      3.0), // Rounded top-left corner
                                  topRight: Radius.circular(
                                      3.0), // Rounded top-right corner
                                  bottomLeft: Radius.circular(
                                      3.0), // No rounding on bottom-left corner
                                  bottomRight: Radius.circular(
                                      3.0), // No rounding on bottom-right corner
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FxText(
                                  'Submit',
                                  color: Colors.white,
                                  fontSize: screenHeight *
                                      0.025, // Responsive font size
                                  fontWeight: 800,
                                ),
                                Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        )));
  }

  void saveDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save animalsControllers data
    List<String> animalsData = [];
    for (var controllerData in animalsControllers) {
      animalsData.add(
          '${controllerData["type"]!.text}:${controllerData["total"]!.text}');
    }
    prefs.setStringList('animalsData', animalsData);
    // Save management systems data
    List<String> managementSystemsData = [];
    for (var system in managementSystems) {
      managementSystemsData.add('${system["name"]}:${system["isChecked"]}');
    }
    prefs.setStringList('managementSystemsData', managementSystemsData);
  }

  String generateFarmId(String districtName) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final random = Random();

    // Generate 1 random letter
    String randomLetter = String.fromCharCodes(
      Iterable.generate(
          1, (_) => letters.codeUnitAt(random.nextInt(letters.length))),
    );

    // Generate 1 random number
    String randomNumber = String.fromCharCodes(
      Iterable.generate(
          1, (_) => numbers.codeUnitAt(random.nextInt(numbers.length))),
    );

    // Extract the first letter or the first two letters of the district name
    List<String> districtWords = districtName.split(' ');
    String districtPrefix = districtWords.length > 1
        ? districtWords[0][0] + districtWords[1][0]
        : districtWords[0][0];

    // Combine district prefix with random letter and number
    return '$districtPrefix-$randomLetter$randomNumber';
  }

  void submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Generate unique farm ID
      String farmId = generateFarmId(widget.district_name);

      // Collecting form data
      FarmModel farm = FarmModel(
        farmID: farmId,
        farmName: prefs.getString('farmName') ?? "",
        farmerName: prefs.getString('farmerName') ?? "",
        farmerDOB: prefs.getString('farmerDOB') ?? "",
        farmerPhone: prefs.getString('farmerPhone') ?? "",
        villageName: prefs.getString('villageName') ?? "",
        parishName: prefs.getString('parishName') ?? "",
        subcountyName: prefs.getString('subcountyName') ?? "",
        districtName: prefs.getString('districtName') ?? "",
        animalsData: json.encode(animalsControllers
            .map((controller) => {
                  "type": controller["type"]!.text,
                  "total": controller["total"]!.text
                })
            .toList()),
        managementSystemsData: json.encode(managementSystems
            .where((system) => system['isChecked'])
            .map((system) => system['name'])
            .toList()),
        isSynced: false, // Mark as not synced by default
      );

      print("Farm Profile: ${farm}");

      // Save locally
      try {
        await FarmModel.saveLocally(farm);
        // Optionally navigate or reset state further as needed
        Get.off(() => FarmsListScreen());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(
              child: Text("Farm registered successfully",
                  style: TextStyle(color: Colors.white))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 15, 166, 4),
          duration: Duration(seconds: 2),
          margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        ));
      } catch (e) {
        print("Error registering farm ${e}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(
              child: Text("Error registering farm",
                  style: TextStyle(color: Colors.white))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color.fromARGB(255, 145, 14, 5),
          duration: Duration(seconds: 2),
          margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        ));
      }

      // Clearing SharedPreferences entries related to the form
      // [Remove prefs settings if not needed anymore]

      // Provide feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Farm details saved locally and pending sync."),
      ));
    }
  }
}
