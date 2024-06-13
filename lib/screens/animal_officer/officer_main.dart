import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcci/screens/animal_officer/ComingSoonScreen.dart';
import 'package:marcci/screens/animal_officer/reports.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/appbar.dart';

import 'home_screen.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({Key? key}) : super(key: key);

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  int currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: _getAppBarTitle(currentPageIndex),
        onBack: _handleBack,
        onSettings: () {
          Get.to(() => AppSettings());
          print("Settings pressed");
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: onTabTapped,
        indicatorColor: Colors.green,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_open_sharp),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.messenger_sharp),
            label: 'Chats',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: [
          HomeScreen(),
          ReportsScreen(),
          ComingSoonScreen(), // Display ComingSoonScreen for Chats tab
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "M-Vet Dashboard";
      case 1:
        return "Field Reports";
      case 2:
        return "Chats";
      default:
        return "M-Vet Dashboard";
    }
  }

  void _handleBack() {
    if (currentPageIndex == 0) {
      Navigator.maybePop(context);
    } else {
      setState(() {
        currentPageIndex = 0;
        _pageController.jumpToPage(0);
      });
    }
  }
}
