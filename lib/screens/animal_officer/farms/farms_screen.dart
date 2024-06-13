import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({Key? key}) : super(key: key);

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController farmNameController = TextEditingController();
  TextEditingController farmerNameController = TextEditingController();
  TextEditingController villageNameController = TextEditingController();
  TextEditingController parishNameController = TextEditingController();
  TextEditingController subcountyNameController = TextEditingController();
  TextEditingController districtNameController = TextEditingController();

  List<dynamic> villages = [];
  Map<String, dynamic> selectedLocation = {};
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedImagePath = path.join(appDir.path, fileName);
      final File savedImage = await File(pickedFile.path).copy(savedImagePath);
      setState(() {
        _images.add(savedImage);
      });
    }
  }

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    loadVillages();
    // loadDataFromPrefs();
  }

  Future<void> loadDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    farmNameController.text = prefs.getString('farmName') ?? '';
    farmerNameController.text = prefs.getString('farmerName') ?? '';
    dateController.text = prefs.getString('farmerDOB') ?? '';
    phoneController.text = prefs.getString('farmerPhone') ?? '';
    villageNameController.text = prefs.getString('villageName') ?? '';
    parishNameController.text = prefs.getString('parishName') ?? '';
    subcountyNameController.text = prefs.getString('subcountyName') ?? '';
    districtNameController.text = prefs.getString('districtName') ?? '';
  }

  @override
  void dispose() {
    dateController.dispose();
    phoneController.dispose();
    farmNameController.dispose();
    farmerNameController.dispose();
    villageNameController.dispose();
    parishNameController.dispose();
    subcountyNameController.dispose();
    districtNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Widget buildTextFormField(
      String label, String hint, TextEditingController controller,
      {bool isDate = false, bool isNumeric = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
            ),
            onTap: isDate ? () => _selectDate(context) : null,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            readOnly: isDate,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> loadVillages() async {
    final String response =
        await rootBundle.loadString('assets/data/geographical_hierarchy.json');
    final data = json.decode(response);
    for (var district in data['districts']) {
      for (var subcounty in district['subcounties']) {
        for (var parish in subcounty['parishes']) {
          for (var village in parish['villages']) {
            villages.add({
              "villageName": village['name'],
              "parishName": parish['name'],
              "subcountyName": subcounty['name'],
              "districtName": district['name']
            });
          }
        }
      }
    }
    setState(() {});
  }

  void onVillageSelected(String selectedVillage) {
    var location = villages.firstWhere(
      (village) => village['villageName'] == selectedVillage,
      orElse: () => {},
    );
    setState(() {
      selectedLocation = location;
      villageNameController.text = selectedLocation['villageName'];
      parishNameController.text = selectedLocation['parishName'];
      subcountyNameController.text = selectedLocation['subcountyName'];
      districtNameController.text = selectedLocation['districtName'];
    });
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  String generateFarmId(String districtName) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final random = Random();

    String randomLetters = String.fromCharCodes(
      Iterable.generate(
          3, (_) => letters.codeUnitAt(random.nextInt(letters.length))),
    );

    // Generate three random numbers
    String randomNumbers = String.fromCharCodes(
      Iterable.generate(
          3, (_) => numbers.codeUnitAt(random.nextInt(numbers.length))),
    );

    return '$districtName-$randomLetters$randomNumbers';
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _getLocation();
      saveDataToPrefs(); // Save data to shared preferences

      // Create a FarmModel instance and add the captured image paths
      FarmModel farm = FarmModel(
        farmName: farmNameController.text,
        farmerName: farmerNameController.text,
        farmerDOB: dateController.text,
        farmerPhone: phoneController.text,
        villageName: villageNameController.text,
        parishName: parishNameController.text,
        subcountyName: subcountyNameController.text,
        districtName: districtNameController.text,
        // farmPhotos: _images.map((file) => file.path).toList(),
      );

      // Further processing with the captured data...
      farm.save(); // Save the farm data locally

      print('Farm Name: ${farmNameController.text}');
      print('Farmer Name: ${farmerNameController.text}');
      print('Farmer DOB: ${dateController.text}');
      print('Farmer Phone: ${phoneController.text}');
      print('Village Name: ${villageNameController.text}');
      print('Parish Name: ${parishNameController.text}');
      print('Subcounty Name: ${subcountyNameController.text}');
      print('District Name: ${districtNameController.text}');
      print('Latitude: $latitude');
      print('Longitude: $longitude');
      print('Farm Photos: ${farm.farmPhotos}');

      Get.to(() => FarmsScreen());
    }
  }

  // void submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     _getLocation();
  //     saveDataToPrefs(); // Save data to shared preferences
  //     // Further processing with the captured data...
  //     print('Farm Name: ${farmNameController.text}');
  //     print('Farmer Name: ${farmerNameController.text}');
  //     print('Farmer DOB: ${dateController.text}');
  //     print('Farmer Phone: ${phoneController.text}');
  //     print('Village Name: ${villageNameController.text}');
  //     print('Parish Name: ${parishNameController.text}');
  //     print('Subcounty Name: ${subcountyNameController.text}');
  //     print('District Name: ${districtNameController.text}');
  //     print('Latitude: $latitude');
  //     print('Longitude: $longitude');
  //     Get.to(() => FarmDetails(district_name: districtNameController.text));
  //   }
  // }

  Future<void> saveDataToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('farmName', farmNameController.text);
    prefs.setString('farmerName', farmerNameController.text);
    prefs.setString('farmerDOB', dateController.text);
    prefs.setString('farmerPhone', phoneController.text);
    prefs.setString('villageName', villageNameController.text);
    prefs.setString('parishName', parishNameController.text);
    prefs.setString('subcountyName', subcountyNameController.text);
    prefs.setString('districtName', districtNameController.text);
  }

  Widget buildImageContainer() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: const Color.fromARGB(255, 0, 69, 3)),
        color: Color.fromARGB(255, 233, 252, 232),
      ),
      child: Column(
        children: [
          Text(
            "Capture farm pictures",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _images.isNotEmpty
                ? Image.file(
                    _images.first,
                    fit: BoxFit.fill,
                  )
                : Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 100,
                  ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: index < _images.length - 1
                        ? Stack(
                            children: [
                              Image.file(
                                _images[index + 1],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _images.removeAt(index + 1);
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 50,
                          ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _images.length < 6 ? _pickImage : null,
            icon: Icon(Icons.camera_alt),
            label: Text("Capture Farm Photo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Farm Profiling",
        onSettings: () {
          Get.to(() => const AppSettings());
          print("Settings pressed");
        },
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    // horizontal: 10.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 6, 98, 1),
                        ),
                        child: FxText(
                          "Farm Profile",
                          color: Colors.white,
                          fontWeight: 900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    buildImageContainer(),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            'Farm Name',
                            'Enter farm name',
                            farmNameController,
                            icon: Icons.landscape,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Adjust spacing between text fields
                        Expanded(
                          child: buildTextFormField(
                            'Farmer Name',
                            'Enter farmer name',
                            farmerNameController,
                            icon: Icons.person,
                          ),
                        ),
                      ],
                    ),
                    buildTextFormField(
                        'Farmer DOB', 'Select DOB', dateController,
                        isDate: true, icon: Icons.calendar_today),
                    buildTextFormField(
                        'Farmer Phone', 'Enter phone number', phoneController,
                        isNumeric: true, icon: Icons.phone),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Farm Village",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownSearch(
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "Please select your village",
                              filled: true,
                              fillColor: Colors.green.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            fit: FlexFit.loose,
                            showSearchBox:
                                true, // Add this line to enable the search box
                          ),
                          items: villages
                              .map((village) => village['villageName'])
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onVillageSelected(value.toString());
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            'Parish',
                            'Enter parish',
                            parishNameController,
                            icon: Icons.home_filled,
                          ),
                        ),
                        SizedBox(
                            width: 10), // Adjust spacing between text fields
                        Expanded(
                          child: buildTextFormField(
                            'Subcounty',
                            'Enter subcounty',
                            subcountyNameController,
                            icon: Icons.location_city_sharp,
                          ),
                        ),
                      ],
                    ),
                    buildTextFormField(
                        'District', 'Enter district', districtNameController,
                        icon: Icons.maps_home_work),
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
                              onPressed: submitForm,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FxText(
                                    'Next',
                                    color: Colors.white,
                                    fontSize: screenHeight *
                                        0.025, // Responsive font size
                                    fontWeight: 800,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
