import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marcci/auth/BoardingWelcomeScreen.dart';
import 'package:marcci/controllers/MainController.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/ManifestModel.dart';
import 'package:marcci/screens/animal_officer/officer_main.dart';
import 'package:marcci/screens/dvo/dvo_main.dart';
import 'package:marcci/screens/farmers/new_fram.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../theme/custom_theme.dart';
import '../utils/AppConfig.dart';
import '../utils/Utils.dart';

class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    init();
    futureInit = my_init();
    // my_init();
    super.initState();
    AppTheme.init();
  }

  ManifestModel item = ManifestModel();
  Future<dynamic> init() async {
    await ManifestModel.getOnlineData();
    mainController.man = await ManifestModel.getItems();
    await mainController.init();
    await mainController.getMan();
    item = mainController.man;
    setState(() {});
  }

  late Future<dynamic> futureInit;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: CustomTheme.primary));
      return Scaffold(
        body: FutureBuilder(
            future: futureInit,
            builder: (context, snapshot) {
              return Center(
                child: InkWell(
                  onTap: () {
                    re_load();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                          image: AssetImage(
                            AppConfig.logo,
                          ),
                          fit: BoxFit.cover,
                          width: 200),
                      SizedBox(
                        height: 50,
                      ),
                      Text("⌛ Loading...")
                    ],
                  ),
                ),
              );
            }),
      );
    });
  }

  MainController mainController = Get.put(MainController());

  ManifestModel itemData = ManifestModel();

  Future<dynamic> my_init() async {
    final prefs = await SharedPreferences.getInstance();
    LoggedInUserModel lu = await LoggedInUserModel.getLoggedInUser();
    print("Token Id: ${lu.remember_token}");
    print("User Id: ${lu.id}");
    if (lu.id == null) {
      Utils.logout();
      BoardingWelcomeScreen();
    }

    if (lu.remember_token.length < 20) {
      print("Token Id: ${lu.remember_token}");
      Get.off(BoardingWelcomeScreen());
      return;
    }

    await mainController.getLoggedInUser();
    await mainController.getMan();
    itemData = mainController.man;

    if (lu.id < 1) {
      print("Error User Id: ${lu.id}");
      Get.off(BoardingWelcomeScreen());
      return;
    } else if (lu.id > 0) {
      // Fetch user role possibly from lu object or another method
      switch (lu.role_id) {
        case "2":
          Get.offAll(() => OfficerDashboard());
          break;
        case "3":
          Get.offAll(() => DvoDashboard());
          break;
        case "6":
          Get.offAll(() => NewFarm());
          break;
        default:
          Get.offAll(() => BoardingWelcomeScreen());
          break;
      }
    } else {
      Get.offAll(() => BoardingWelcomeScreen());
    }

    return "Done";
  }

  bool is_loading = true;

  void re_load() {
    setState(() {
      futureInit = my_init();
    });
  }
}
