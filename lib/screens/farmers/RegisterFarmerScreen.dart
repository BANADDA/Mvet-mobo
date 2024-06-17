import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:marcci/main.dart';
import 'package:marcci/models/FarmerModel.dart';
import 'package:marcci/utils/AppConfig.dart';
import 'package:marcci/utils/Utils.dart';
import 'package:marcci/utils/dimensions.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterFarmerScreen extends StatefulWidget {
  @override
  _RegisterFarmerScreenState createState() => _RegisterFarmerScreenState();
}

class _RegisterFarmerScreenState extends State<RegisterFarmerScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? selectedGender;
  bool isPWD = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController farmNameController = TextEditingController();
  List<Map<String, dynamic>> animals = [];
  final TextEditingController farmCreatedDateController =
      TextEditingController();
  List<String> selectedFarmingSystems = [];
  List<String> specifiedFarmingSystems = [];
  List<String> selectedBioSecurityMeasures = [];
  List<String> specifiedBioSecurityMeasures = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    if (await Permission.location.request().isGranted) {
      _getCurrentLocation();
    } else {
      setState(() {
        isLoading = false;
      });
      _showPermissionDeniedDialog();
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      print("Lat: $latitude \n Lon: $longitude");
      isLoading = false;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
              'Location permission is required to register a farmer. Please grant the permission.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addAnimal() {
    setState(() {
      animals.add({
        'type': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeAnimal(int index) {
    setState(() {
      animals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Register Farmer",
        onBack: () {
          Navigator.pop(context);
        },
        onSettings: () {},
      ),
      body: isLoading
          ? Center(
              child: SpinKitCircle(color: Colors.green, size: 50.0),
            )
          : ModalProgressHUD(
              inAsyncCall: isSubmitting,
              opacity: 0.5,
              progressIndicator:
                  SpinKitFadingCircle(color: Colors.teal, size: 50.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildFarmerProfileSection(),
                      const SizedBox(height: 20),
                      _buildFarmProfileSection(),
                      const SizedBox(height: 20),
                      _buildRegisterButton(),
                      const SizedBox(height: 20),
                      _buildLoginOption(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFarmerProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farmer Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(phoneController, Icons.phone, 'Phone Number'),
        const SizedBox(height: 10),
        _buildTextField(nameController, Icons.person, 'Name'),
        const SizedBox(height: 10),
        _buildDatePicker(dobController, 'Date of Birth'),
        const SizedBox(height: 10),
        _buildGenderPicker(),
        const SizedBox(height: 10),
        _buildSwitchTile(),
      ],
    );
  }

  Widget _buildFarmProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(farmNameController, Icons.home, 'Farm Name'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    TextEditingController(text: latitude.toString()),
                    Icons.location_on,
                    'Latitude')),
            const SizedBox(width: 10),
            Expanded(
                child: _buildTextField(
                    TextEditingController(text: longitude.toString()),
                    Icons.location_on,
                    'Longitude')),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 14.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Center(
            child: Text(
              'Capture GPS Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Animals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 10),
        ...animals.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> animal = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      animal['type'], Icons.pets, 'Animal Type'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(animal['quantity'],
                      Icons.format_list_numbered, 'Quantity'),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _removeAnimal(index);
                  },
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addAnimal,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(vertical: 14.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Center(
            child: Text(
              'Add Animal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildMultiSelectChip(
          'Farming Systems',
          ['Zero Grazing', 'Paddock', 'Free Range', 'Others'],
          selectedFarmingSystems,
          specifiedFarmingSystems,
        ),
        const SizedBox(height: 10),
        _buildDatePicker(farmCreatedDateController, 'Date Farm Was Created'),
        const SizedBox(height: 10),
        _buildMultiSelectChip(
          'Bio Security Measures',
          ['Fencing', 'Quarantine', 'Vaccination', 'Others'],
          selectedBioSecurityMeasures,
          specifiedBioSecurityMeasures,
        ),
      ],
    );
  }

  Widget _buildMultiSelectChip(String title, List<String> options,
      List<String> selectedValues, List<String> specifiedValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.teal,
            fontSize: 16,
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selectedValues.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedValues.add(option);
                    if (option == 'Others') {
                      _showSpecificationDialog(title, specifiedValues);
                    }
                  } else {
                    selectedValues.remove(option);
                    if (option == 'Others') {
                      specifiedValues.clear();
                    }
                  }
                });
              },
              selectedColor: Colors.teal,
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
        if (selectedValues.contains('Others'))
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: specifiedValues
                  .map(
                    (value) => Chip(
                      label: Text(value),
                      onDeleted: () {
                        setState(() {
                          specifiedValues.remove(value);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showSpecificationDialog(String title, List<String> specifiedValues) {
    TextEditingController specificationController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Specify $title'),
          content: TextField(
            controller: specificationController,
            decoration: InputDecoration(hintText: 'Enter specification'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (specificationController.text.isNotEmpty) {
                  setState(() {
                    specifiedValues.add(specificationController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, IconData icon, String labelText,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 16,
          ),
        ),
        ListTile(
          title: const Text('Male'),
          leading: Radio<String>(
            value: 'Male',
            groupValue: selectedGender,
            onChanged: (String? value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Female'),
          leading: Radio<String>(
            value: 'Female',
            groupValue: selectedGender,
            onChanged: (String? value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
        ),
        if (selectedGender == null || selectedGender!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              'Please select Gender',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      title: const Text('Are you a PWD (People with Disabilities) ?'),
      value: isPWD,
      onChanged: (bool value) {
        setState(() {
          isPWD = value;
        });
      },
      activeColor: Colors.teal,
      secondary: const Icon(Icons.accessible, color: Colors.teal),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Center(
        child: Text(
          'Register',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Column(
      children: [
        const Text('Already have an account?',
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Create FarmerModel object
      FarmerModel farmer = FarmerModel(
        phoneNumber: phoneController.text,
        name: nameController.text,
        dateOfBirth: dobController.text,
        latitude: latitude,
        longitude: longitude,
        gender: selectedGender!,
        isPWD: isPWD,
      );

      // Create FarmModel object
      // FarmModel farm = FarmModel(
      //   name: farmNameController.text,
      //   latitude: latitude,
      //   longitude: longitude,
      //   animals: animals
      //       .map((animal) => {
      //             'type': animal['type'].text,
      //             'quantity': int.parse(animal['quantity'].text),
      //           })
      //       .toList(),
      //   farmingSystems: selectedFarmingSystems + specifiedFarmingSystems,
      //   createdDate: farmCreatedDateController.text,
      //   bioSecurityMeasures: selectedBioSecurityMeasures + specifiedBioSecurityMeasures,
      // );

      setState(() {
        isSubmitting = true;
      });

      // Check internet connection
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // If connected to the internet, register farmer and farm using the API
        String farmerEndpoint = '${AppConfig.API_BASE_URL}/register-farmer';
        String farmEndpoint = '${AppConfig.API_BASE_URL}/register-farm';

        print("Farmer register endpoint: $farmerEndpoint");
        print("Payload: ${jsonEncode(farmer.toJson())}");
        print("Farm register endpoint: $farmEndpoint");
        // print("Payload: ${jsonEncode(farm.toJson())}");

        try {
          final farmerResponse = await http.post(
            Uri.parse(farmerEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(farmer.toJson()),
          );

          // final farmResponse = await http.post(
          //   Uri.parse(farmEndpoint),
          //   headers: {'Content-Type': 'application/json'},
          //   body: jsonEncode(farm.toJson()),
          // );

          if (farmerResponse.statusCode == 201
              //  &&
              // farmResponse.statusCode == 201
              ) {
            final responseData = jsonDecode(farmerResponse.body);
            final password = responseData['password'];
            final phoneNumber = farmer.phoneNumber;
            setState(() {
              isSubmitting = false;
            });
            print("Response: ${responseData}");
            await showNotification("Farmer account created successfully",
                "Use phone number $phoneNumber and password $password to access your account");
            print("Farmer phone number: $phoneNumber && Password: $password");
            void _showSnackBar(String message) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(message, style: const TextStyle(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color.fromARGB(255, 145, 14, 5),
                margin: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              ));
            }

            Get.back();
            // _showRegistrationSuccessDialog(phoneNumber, password);
          } else {
            print("Farmer response status: ${farmerResponse.statusCode}");
            print("Farmer response body: ${farmerResponse.body}");
            // print("Farm response status: ${farmResponse.statusCode}");
            // print("Farm response body: ${farmResponse.body}");
            throw Exception('Failed to register farmer and farm');
          }
        } catch (e) {
          print("Failed to register farmer and farm: ${e.toString()}");
          setState(() {
            isSubmitting = false;
          });
        }
      } else {
        // If not connected to the internet, save farmer and farm locally
        await FarmerModel.saveLocally(farmer);
        // await FarmModel.saveLocally(farm);
        setState(() {
          isSubmitting = false;
        });
        Utils.toast(
            "Farmer and farm registered locally. Sync will happen when internet is available.");
        Navigator.pop(context);
      }
    }
  }
}
