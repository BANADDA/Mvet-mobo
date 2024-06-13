import 'package:flutter/material.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';

import '../theme/custom_theme.dart';

class TestHomeScreen extends StatelessWidget {
  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final Controller c = Get.put(Controller());

    return Scaffold(
        appBar: AppBar(
            title: Obx(
          () => FxText(
            "Clicks: ${c.count}",
            color: CustomTheme.primary,
          ),
        )),

        // Replace the 8 lines Navigator.push by a simple Get.to(). You don't need context
        body: Center(
            child: ElevatedButton(
                child: Text("Go to Other"),
                onPressed: () => Get.to(OtherScreen()))),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: c.increment));
  }
}

class OtherScreen extends StatelessWidget {
  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final Controller c = Get.find();

    return WillPopScope(
      onWillPop: () async {
        print("pressed");
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
              title: Obx(
            () => FxText(
              "Clicks: ${c.count} OtherScreen",
              color: CustomTheme.primary,
            ),
          )),

          // Replace the 8 lines Navigator.push by a simple Get.to(). You don't need context
          body: Center(
              child: Column(
            children: [

            ],
          )),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add), onPressed: c.decrement)),
    );
  }
}

class Controller extends GetxController {
  var count = 0.obs;

  increment() => count++;

  decrement() => count--;
}
