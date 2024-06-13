import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/screens/animal_officer/farms/farms_screen.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/utils/color_resources.dart';
import 'package:marcci/utils/styles.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:marcci/widgets/notebook_card.dart'; // Ensure correct import path

class FarmsListScreen extends StatefulWidget {
  @override
  _FarmsListScreenState createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends State<FarmsListScreen> {
  late Future<List<FarmModel>> _farms;
  List<FarmModel> _filteredFarms = [];
  String _filterVillage = "All";
  String _filterParish = "All";

  TextEditingController _searchController = TextEditingController();

  // Use a setter to automatically update and filter the farms list whenever the search text changes.
  String _searchText = "";
  set searchText(String value) {
    _searchText = value.toLowerCase();
    _filterFarms();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      searchText = _searchController.text;
    });
    _fetchFarms();
  }

  void _fetchFarms() {
    _farms = FarmModel.get_items();
    _farms.then((farms) {
      setState(() {
        _filteredFarms = farms;
      });
    });
  }

  void _filterFarms() {
    if (_farms != null) {
      _farms.then((farms) {
        setState(() {
          _filteredFarms = farms.where((farm) {
            return (farm.farmName.toLowerCase().contains(_searchText) &&
                (_filterVillage == "All" ||
                    farm.villageName == _filterVillage) &&
                (_filterParish == "All" || farm.parishName == _filterParish));
          }).toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Registered Farms",
        onSettings: () {
          Get.to(() => const AppSettings());
        },
        onBack: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: const Color.fromARGB(255, 233, 251, 233),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredFarms.isEmpty
                ? Center(child: Text("No farms present"))
                : ListView.builder(
                    itemCount: _filteredFarms.length,
                    itemBuilder: (context, index) {
                      return NotebookCard(
                        farm: _filteredFarms[index],
                        options: () {
                          // Define actions when options icon is tapped
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromARGB(255, 1, 70, 4),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          print("Navigate pressed");
          Get.off(() => FarmsScreen());
        },
        label: Text(
          "New Farm",
          style: urbanistRegular.copyWith(
            color: ColorResources.getWhiteColor(context),
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFarms);
    _searchController.dispose();
    super.dispose();
  }
}
