import 'package:get/get.dart';
import 'package:marcci/models/ManifestModel.dart';

import '../models/LoggedInUserModel.dart';

class MainController extends GetxController {
  var count = 0.obs;
  LoggedInUserModel loggedInUser = LoggedInUserModel();

  ManifestModel man = ManifestModel();

  Future<void> getMan() async {
    man = await ManifestModel.getItems();
  }

  Future<void> init() async {
    await getMan();
    await getLoggedInUser();
    // await getEligibleMembers();
    return;
    await getLoggedInUser();
  }

  Future<void> getLoggedInUser() async {
    loggedInUser = await LoggedInUserModel.getLoggedInUser();
    if (loggedInUser.id < 1) {
      return;
    }
    //userModel =loggedInUser;
    return;
  }
}
