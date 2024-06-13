import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/utils/my_widgets.dart';

import '../../theme/custom_theme.dart';

class FarmsPickerScreen extends StatefulWidget {
  const FarmsPickerScreen({Key? key}) : super(key: key);

  @override
  FarmsPickerScreenState createState() => FarmsPickerScreenState();
}

class FarmsPickerScreenState extends State<FarmsPickerScreen> {
  List<FarmModel> items = [];
  List<FarmModel> filteredItems = []; // List to hold filtered items
  TextEditingController searchController =
      TextEditingController(); // Controller for search text

  @override
  void initState() {
    super.initState();
    doRefresh();
    searchController.addListener(onSearchTextChanged);
  }

  Future<dynamic> doRefresh() async {
    futureInit = init();
    setState(() {});
  }

  late Future<dynamic> futureInit;

  void onSearchTextChanged() {
    filteredItems = items.where((farm) {
      return farm.farmName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
          farm.farmerPhone.contains(searchController.text);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        titleSpacing: 0,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: FxText.titleLarge('Select Farm', color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: futureInit,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return myListLoaderWidget(context);
            }

            return RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: doRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search by farm name or phone number",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        FarmModel m = filteredItems[index];
                        return buildFarmItem(m);
                      },
                      childCount: filteredItems.length,
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget buildFarmItem(FarmModel m) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, m);
      },
      child: Column(
        children: [
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: FxText.bodyLarge(
                      m.farmName.substring(0, 1).toUpperCase(),
                      fontWeight: 700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(m.farmName,
                          fontWeight: 700, color: Colors.black),
                      FxText.bodyLarge(m.farmerPhone,
                          fontWeight: 700, color: Colors.grey.shade700),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3),
          Divider(),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    items = await FarmModel.get_items();
    items.sort((a, b) => a.farmName.compareTo(b.farmName));
    filteredItems =
        List.from(items); // Initially, filteredItems shows all items
    setState(() {});
  }
}
