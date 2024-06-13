import 'package:flutx/flutx.dart';



class SectionDashboardController extends FxController {
  late List<String> filterTime;
  late String time;

  @override
  void initState() {
    super.initState();
    filterTime = ["Today", "Yesterday", "This week", "30 days ago", 'All time'];
    time = filterTime.first;

  }

  void changeFilter(String time) {
    this.time = time;
    update();
  }

  @override
  String getTag() {
    return "shopping_login_controller";
  }
}
