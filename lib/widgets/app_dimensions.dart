import 'package:get/get.dart';

class DynamicDimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

//dynamic height padding and margin
  static double height10 = screenHeight / 84.4;
  static double height15 = screenHeight / 56.27;
  static double height20 = screenHeight / 42.2;
  static double height30 = screenHeight / 28.13;
  static double height45 = screenHeight / 18.76;

//dynamic width padding and margin
  static double width10 = screenWidth / 84.4;
  static double width15 = screenWidth / 56.27;
  static double width20 = screenWidth / 42.2;
  static double width30 = screenWidth / 28.13;
  static double width45 = screenWidth / 18.76;

//dynamic font size
  static double font12 = screenHeight / 70.33;
  static double font14 = screenHeight / 60.28;
  static double font16 = screenHeight / 52.75;
  static double font18 = screenHeight / 46.11;
  static double font20 = screenHeight / 42.2;
  static double font26 = screenHeight / 32.46;

//dynamic radius
  static double radius15 = screenHeight / 56.27;
  static double radius20 = screenHeight / 42.2;
  static double radius30 = screenHeight / 28.13;

  //icon size
  static double iconSize24 = screenHeight / 35.17;
  static double iconSize16 = screenHeight / 52.75;
  static double iconSize20 = screenHeight / 42.2;

  //splash screen dimensions
  static double splashImg = screenHeight / 3.38;
}
