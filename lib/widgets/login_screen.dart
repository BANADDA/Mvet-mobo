import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/RespondModel.dart';
import 'package:marcci/screens/OnBoardingScreen.dart';
import 'package:marcci/screens/farmers/RegisterFarmerScreen.dart';
import 'package:marcci/utils/AppConfig.dart';
import 'package:marcci/utils/Utils.dart';
import 'package:marcci/utils/dimensions.dart';

class LoginWidget extends StatefulWidget {
  final String userType;
  LoginWidget({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 56, 10),
        title:
            const Text("Login to M-Vet", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildForm(screenHeight, screenWidth),
            ),
          ),
          if (isSubmitting)
            Container(
              color: Colors.black45,
              child: const Center(
                child: SpinKitCircle(color: Colors.white, size: 50.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildForm(double screenHeight, double screenWidth) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(AppConfig.logo, width: screenWidth * 0.4),
          const SizedBox(height: 20),
          Text(
            'Login as ${widget.userType}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          _buildTextField(phoneController, Icons.phone, 'Phone Number'),
          const SizedBox(height: 10),
          _buildTextField(passwordController, Icons.lock, 'Password',
              isPassword: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 17, 78, 19),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
              child: const Text('LOGIN'),
            ),
          ),
          if (widget.userType == 'Farmer') // Show Register button for Farmers
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterFarmerScreen()),
                );
              },
              child: const Text(
                'Register as Farmer',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, IconData icon, String labelText,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);
      final data = {
        'phoneNumber': phoneController.text,
        'password': passwordController.text,
        'roleName': widget.userType,
      };

      try {
        RespondModel resp =
            RespondModel(await Utils.httpPost("login-with-role", data));
        if (resp.code == 1) {
          LoggedInUserModel u = LoggedInUserModel.fromJson(resp.data);
          if (await u.save()) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => OnBoardingScreen()));
          } else {
            _showSnackBar("Failed to log you in.");
          }
        } else {
          _showSnackBar("Error during login, check your credentials.");
        }
      } catch (e) {
        _showSnackBar("Error connecting to the server.");
      } finally {
        setState(() => isSubmitting = false);
      }
    } else {
      _showSnackBar("Please check your entries and try again.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 145, 14, 5),
      margin: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
    ));
  }
}
