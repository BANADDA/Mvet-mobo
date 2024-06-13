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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildTextField(
                              phoneController, Icons.phone, 'Phone Number'),
                          const SizedBox(height: 10),
                          _buildTextField(nameController, Icons.person, 'Name'),
                          const SizedBox(height: 10),
                          _buildDatePicker(dobController, 'Date of Birth'),
                          const SizedBox(height: 10),
                          _buildGenderPicker(),
                          const SizedBox(height: 10),
                          _buildSwitchTile(),
                          const SizedBox(height: 20),
                          _buildRegisterButton(),
                          const SizedBox(height: 20),
                          _buildLoginOption(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Please enter your details',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
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

      setState(() {
        isSubmitting = true;
      });

      // Check internet connection
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // If connected to the internet, register farmer using the API
        String endpoint = '${AppConfig.API_BASE_URL}/register-farmer';

        print("Farmer register endpoint: $endpoint");
        print("Payload: ${jsonEncode(farmer.toJson())}");

        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(farmer.toJson()),
          );

          if (response.statusCode == 201) {
            final responseData = jsonDecode(response.body);
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
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
            throw Exception('Failed to register farmer');
          }
        } catch (e) {
          print("Failed to register farmer: ${e.toString()}");
          setState(() {
            isSubmitting = false;
          });
        }
      } else {
        // If not connected to the internet, save farmer locally
        await FarmerModel.saveLocally(farmer);
        setState(() {
          isSubmitting = false;
        });
        Utils.toast(
            "Farmer registered locally. Sync will happen when internet is available.");
        Navigator.pop(context);
      }
    }
  }

  void _showRegistrationSuccessDialog(String phoneNumber, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Farmer registered successfully.'),
              SizedBox(height: 10),
              Text('Phone Number: $phoneNumber'),
              Text('Password: $password'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
