import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:marcci/models/AnimalsModel.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/FeedsModel.dart'; // Add imports for your models
import 'package:marcci/models/HealthModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/YieldsModel.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:marcci/widgets/buildServiceCard.dart';
import 'package:marcci/widgets/user_container.dart';

class NewFarm extends StatefulWidget {
  const NewFarm({Key? key}) : super(key: key);

  @override
  State<NewFarm> createState() => _NewFarmState();
}

class _NewFarmState extends State<NewFarm> {
  LoggedInUserModel? user;
  late Future<LoggedInUserModel> _loggedInUserFuture;
  late Future<FarmModel?> _firstFarmFuture;

  List<Map<String, dynamic>> submittedFeeds = [];
  List<Map<String, dynamic>> tempSavedFeeds = [];
  List<Map<String, dynamic>> tempSavedHealth = [];
  List<Map<String, dynamic>> tempSavedAnimal = [];
  List<Map<String, dynamic>> tempSavedYields = [];

  @override
  void initState() {
    super.initState();
    _loggedInUserFuture = LoggedInUserModel.getLoggedInUser();
    _firstFarmFuture = _checkFarmProfile();
  }

  Future<FarmModel?> _checkFarmProfile() async {
    user = await LoggedInUserModel.getLoggedInUser();
    print("Farmer: ${user?.id}");
    FarmModel? firstFarm =
        await FarmModel.getFirstFarmByFarmerId(user!.id.toString());
    print("Farm: ${firstFarm?.farmName}");
    print("Farmer Id: ${firstFarm?.farmerID}");
    return firstFarm;
  }

  Widget buildServiceButton(
      String title, String iconPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 252, 254, 252),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      10.0), // Optional: Adds padding around the image
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    width: 120,
                    height: 120, // Sets a specific height for the image
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Color.fromARGB(255, 2, 84, 6),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedsHistory(BuildContext context) async {
    List<FeedsModel> feeds = await FeedsModel.get_items();
    Map<String, List<FeedsModel>> groupedFeeds = _groupDataByDate(feeds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Color.fromARGB(255, 2, 84, 6),
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Feeds History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildHistoryList(groupedFeeds, (feed) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animal: ${feed.animal}'),
                          Text('Feed: ${feed.name}'),
                          Text('Quantity: ${feed.quantity} ${feed.unit}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHealthHistory(BuildContext context) async {
    List<HealthModel> healthData = await HealthModel.get_items();
    Map<String, List<HealthModel>> groupedHealth = _groupDataByDate(healthData);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Color.fromARGB(255, 2, 84, 6),
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Health History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildHistoryList(groupedHealth, (health) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animal: ${health.animal}'),
                          Text('Symptoms: ${health.symptoms}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnimalStockHistory(BuildContext context) async {
    List<AnimalsModel> animals = await AnimalsModel.get_items();
    Map<String, List<AnimalsModel>> groupedAnimals = _groupDataByDate(animals);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Color.fromARGB(255, 2, 84, 6),
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Stock History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildHistoryList(groupedAnimals, (animal) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animal: ${animal.animal}'),
                          Text('Quantity: ${animal.quantity}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showYieldsHistory(BuildContext context) async {
    List<YieldsModel> yields = await YieldsModel.get_items();
    Map<String, List<YieldsModel>> groupedYields = _groupDataByDate(yields);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Color.fromARGB(255, 2, 84, 6),
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Yields History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildHistoryList(groupedYields, (yieldData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animal: ${yieldData.animal}'),
                          Text('Yield: ${yieldData.yieldType}'),
                          Text(
                              'Quantity: ${yieldData.quantity} ${yieldData.unit}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, List<T>> _groupDataByDate<T>(List<T> data) {
    Map<String, List<T>> groupedData = {};
    for (T item in data) {
      String date = (item as dynamic)
          .date
          .split(' ')[0]; // Assuming date format includes time
      if (groupedData.containsKey(date)) {
        groupedData[date]!.add(item);
      } else {
        groupedData[date] = [item];
      }
    }
    return groupedData;
  }

  Widget _buildHistoryList<T>(
      Map<String, List<T>> groupedData, Widget Function(T) itemBuilder) {
    List<Widget> sections = [];
    groupedData.forEach((date, items) {
      sections.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...items.map((item) => Container(
                    width: double.infinity,
                    height: 80, // Fixed height
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: itemBuilder(item),
                  )),
            ],
          ),
        ),
      );
    });
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Farmer Dashboard",
        onBack: () {},
        onSettings: () {
          Get.to(() => AppSettings());
          print("Settings pressed");
        },
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: FutureBuilder<LoggedInUserModel>(
                future: _loggedInUserFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    LoggedInUserModel _loggedInUser = snapshot.data!;
                    return UserContainer(
                      userName: _loggedInUser.name,
                      imagePath: _loggedInUser.avatar,
                      district: _loggedInUser.district_name,
                      districtIcon: Icons.location_city,
                      role: _loggedInUser.role_name,
                      roleIcon: Icons.pets,
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<FarmModel?>(
                future: _firstFarmFuture,
                builder: (context, snapshot) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ServiceCard(
                            title: 'Farm Statistics',
                            subtitle: 'Click to view farm statistics',
                            services: [
                              {
                                'title': 'Animal Feeds',
                                'onPressed': () {
                                  _showFeedsHistory(context);
                                }
                              },
                              {
                                'title': 'Health Status',
                                'onPressed': () {
                                  _showHealthHistory(context);
                                }
                              },
                              {
                                'title': 'Animal Stock',
                                'onPressed': () {
                                  _showAnimalStockHistory(context);
                                }
                              },
                              {
                                'title': 'Farm Yields',
                                'onPressed': () {
                                  _showYieldsHistory(context);
                                }
                              },
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            shrinkWrap: true,
                            children: [
                              buildServiceButton(
                                  "Feeds", "assets/images/weather.png", () {
                                _showAnimalFeedsBottomSheet(context);
                              }),
                              buildServiceButton(
                                  "Health", "assets/images/health.png", () {
                                _showAnimalHealthBottomSheet(context);
                              }),
                              buildServiceButton(
                                  "Animal", "assets/images/cow.png", () {
                                _showAnimalAnimalBottomSheet(context);
                              }),
                              buildServiceButton(
                                  "Yields", "assets/images/yields.png", () {
                                _showAnimalYieldsBottomSheet(context);
                              }),
                            ],
                          ),
                        ),
                        // Display submitted feeds
                        if (submittedFeeds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: submittedFeeds
                                    .map((feed) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                              'Animal: ${feed['animal']}, Feed: ${feed['name']}, Quantity: ${feed['quantity']} ${feed['unit']}, Date: ${feed['date']}'),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnimalFeedsBottomSheet(BuildContext context) {
    String? _selectedAnimal;
    String _feedName = '';
    String _quantity = '';
    String? _selectedUnit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final List<String> _animals = [
                  'Cattle',
                  'Goats',
                  'Sheep',
                  'Poultry',
                  'Pigs',
                  'Rabbits',
                  'Fish'
                ];
                final List<String> _units = ['Kg', 'Litre', 'Bags'];

                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Color.fromARGB(255, 2, 84, 6),
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Animal Feeds',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          child: DropdownButton2<String>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                            ),
                            isExpanded: true,
                            hint: Text('Select Animal',
                                style: TextStyle(fontSize: 16)),
                            value: _selectedAnimal,
                            items: _animals
                                .map((animal) => DropdownMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Text(
                                          animal,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      value: animal,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAnimal = value!;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _feedName = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Feed Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _quantity = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          child: DropdownButton2<String>(
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                            ),
                            isExpanded: true,
                            hint: Text('Select Unit',
                                style: TextStyle(fontSize: 16)),
                            value: _selectedUnit,
                            items: _units
                                .map((unit) => DropdownMenuItem(
                                      child: Text(
                                        unit,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      value: unit,
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedAnimal != null &&
                                      _feedName.isNotEmpty &&
                                      _quantity.isNotEmpty &&
                                      _selectedUnit != null) {
                                    setState(() {
                                      tempSavedFeeds.add({
                                        'animal': _selectedAnimal,
                                        'name': _feedName,
                                        'quantity': _quantity,
                                        'unit': _selectedUnit,
                                        'date': DateTime.now().toString(),
                                      });
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please fill all fields'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green[500]),
                                child: Text('Save'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (tempSavedFeeds.isNotEmpty) {
                                    setState(() {
                                      submittedFeeds.addAll(tempSavedFeeds);
                                    });
                                    print("Feed objectS: $tempSavedFeeds");

                                    // Save to database using FeedsModel
                                    await Future.forEach(tempSavedFeeds,
                                        (feed) async {
                                      FeedsModel feedModel = FeedsModel(
                                        farmID: user!.id.toString(),
                                        animal: feed['animal'],
                                        name: feed['name'],
                                        quantity:
                                            double.parse(feed['quantity']),
                                        unit: feed['unit'],
                                        date: feed['date'],
                                      );
                                      await FeedsModel.saveLocally(feedModel);
                                      print("Feed object: $feed");
                                    });
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg:
                                            "Feeds data submitted successfully",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('No data to submit'),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    tempSavedFeeds.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green[500]),
                                child: Text('Submit'),
                              ),
                            ],
                          ),
                        ),
                        if (tempSavedFeeds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: tempSavedFeeds
                                  .map((feed) => Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  'Animal: ${feed['animal']}, Feed: ${feed['name']}, Quantity: ${feed['quantity']} ${feed['unit']}, Date: ${feed['date']}'),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  tempSavedFeeds.remove(feed);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAnimalHealthBottomSheet(BuildContext context) {
    String? _selectedAnimal;
    String _symptoms = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final List<String> _animals = [
                  'Cattle',
                  'Goats',
                  'Sheep',
                  'Poultry',
                  'Pigs',
                  'Rabbits',
                  'Fish'
                ];

                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                        width: double.infinity,
                        color: Color.fromARGB(255, 2, 84, 6),
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Animal Health',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: DropdownButton2<String>(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200]),
                          ),
                          isExpanded: true,
                          hint: Text('Select Animal',
                              style: TextStyle(fontSize: 16)),
                          value: _selectedAnimal,
                          items: _animals
                              .map((animal) => DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        animal,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    value: animal,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAnimal = value!;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text('Symptoms and Status',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  _symptoms = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey[200]!, width: 1.0)),
                              ),
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_selectedAnimal != null &&
                                    _symptoms.isNotEmpty) {
                                  setState(() {
                                    tempSavedHealth.add({
                                      'animal': _selectedAnimal,
                                      'symptoms': _symptoms,
                                      'date': DateTime.now().toString(),
                                    });
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500]),
                              child: Text('Save'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (tempSavedHealth.isNotEmpty) {
                                  setState(() {
                                    submittedFeeds.addAll(tempSavedHealth);
                                  });
                                  // Save to database using HealthModel
                                  tempSavedHealth.forEach((health) {
                                    HealthModel healthModel = HealthModel(
                                      farmID: user!.id.toString(),
                                      animal: health['animal'],
                                      symptoms: health['symptoms'],
                                      date: health['date'],
                                    );
                                    HealthModel.saveLocally(healthModel);
                                  });
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg:
                                          "Health status data submitted successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No data to submit'),
                                    ),
                                  );
                                }
                                setState(() {
                                  tempSavedHealth.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500]),
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                      if (tempSavedHealth.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: tempSavedHealth
                                .map((health) => Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                                'Animal: ${health['animal']}, Symptoms: ${health['symptoms']}'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                tempSavedHealth.remove(health);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAnimalAnimalBottomSheet(BuildContext context) {
    String? _selectedAnimal;
    String? _quantity;
    DateTime? _date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final List<String> _animals = [
                  'Cattle',
                  'Goats',
                  'Sheep',
                  'Poultry',
                  'Pigs',
                  'Rabbits',
                  'Fish'
                ];

                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      Container(
                        width: double.infinity,
                        color: Color.fromARGB(255, 2, 84, 6),
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Animal Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: DropdownButton2<String>(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                          ),
                          isExpanded: true,
                          hint: Text('Select Animal',
                              style: TextStyle(fontSize: 16)),
                          value: _selectedAnimal,
                          items: _animals
                              .map((animal) => DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(
                                        animal,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    value: animal,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAnimal = value!;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _quantity = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            ).then((value) {
                              setState(() {
                                _date = value;
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green[500]),
                          child: Text('Select Date'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_selectedAnimal != null &&
                                    _quantity != null &&
                                    _date != null) {
                                  setState(() {
                                    tempSavedAnimal.add({
                                      'animal': _selectedAnimal,
                                      'quantity': _quantity,
                                      'date': _date,
                                    });
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500]),
                              child: Text('Save'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (tempSavedAnimal.isNotEmpty) {
                                  setState(() {
                                    submittedFeeds.addAll(tempSavedAnimal);
                                  });
                                  // Save to database using AnimalsModel
                                  tempSavedAnimal.forEach((animal) {
                                    AnimalsModel animalModel = AnimalsModel(
                                      farmID: user!.id.toString(),
                                      animal: animal['animal'],
                                      quantity:
                                          double.parse(animal['quantity']),
                                      date: animal['date'].toString(),
                                    );
                                    AnimalsModel.saveLocally(animalModel);
                                  });
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg:
                                          "Animal stock data submitted successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No data to submit'),
                                    ),
                                  );
                                }
                                setState(() {
                                  tempSavedAnimal.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500]),
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                      if (tempSavedAnimal.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: tempSavedAnimal
                                .map((animal) => Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                                'Animal: ${animal['animal']}, Quantity: ${animal['quantity']}, Date: ${animal['date']}'),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                tempSavedAnimal.remove(animal);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAnimalYieldsBottomSheet(BuildContext context) {
    String? _selectedAnimal;
    String? _selectedYield;
    String? _selectedUnit;
    String _quantity = '';
    DateTime? _date;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final List<String> _animals = [
                  'Cattle',
                  'Goats',
                  'Sheep',
                  'Poultry',
                  'Pigs',
                  'Rabbits',
                  'Fish'
                ];
                final List<String> _yields = [
                  'Milk',
                  'Meat',
                  'Eggs',
                  'Wool',
                  'Hides',
                  'Manure',
                  'Fish'
                ];
                final List<String> _units = ['Litres', 'Kgs', 'None'];

                return SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Form(
                        key: formKey,
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Container(
                            width: double.infinity,
                            color: Color.fromARGB(255, 2, 84, 6),
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Animal Yields',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: DropdownButton2<String>(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200]),
                              ),
                              isExpanded: true,
                              hint: Text('Select Animal',
                                  style: TextStyle(fontSize: 16)),
                              value: _selectedAnimal,
                              items: _animals
                                  .map((animal) => DropdownMenuItem(
                                        child: Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Text(
                                            animal,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        value: animal,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAnimal = value!;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: DropdownButton2<String>(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200]),
                              ),
                              isExpanded: true,
                              hint: Text('Select Yield',
                                  style: TextStyle(fontSize: 16)),
                              value: _selectedYield,
                              items: _yields
                                  .map((yield) => DropdownMenuItem(
                                        child: Text(
                                          yield,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        value: yield,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYield = value!;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  _quantity = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide()),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: DropdownButton2<String>(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200]),
                              ),
                              isExpanded: true,
                              hint: Text('Select Units',
                                  style: TextStyle(fontSize: 16)),
                              value: _selectedUnit,
                              items: _units
                                  .map((unit) => DropdownMenuItem(
                                        child: Text(
                                          unit,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        value: unit,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                            ),
                          ),
                          //DATE
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: ElevatedButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                ).then((value) {
                                  setState(() {
                                    _date = value;
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green[500]),
                              child: Text('Select Date'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate() &&
                                        _selectedAnimal != null &&
                                        _selectedYield != null &&
                                        _quantity.isNotEmpty &&
                                        _selectedUnit != null) {
                                      setState(() {
                                        tempSavedYields.add({
                                          'animal': _selectedAnimal,
                                          'yield': _selectedYield,
                                          'quantity': _quantity,
                                          'unit': _selectedUnit,
                                          'date': _date.toString(),
                                        });
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Please fill all fields'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green[500]),
                                  child: Text('Save'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (tempSavedYields.isNotEmpty) {
                                      setState(() {
                                        submittedFeeds.addAll(tempSavedYields);
                                      });
                                      // Save to database using YieldsModel
                                      tempSavedYields.forEach((yield) {
                                        YieldsModel yieldModel = YieldsModel(
                                          farmID: user!.id.toString(),
                                          animal: yield['animal'],
                                          yieldType: yield['yield'],
                                          quantity:
                                              double.parse(yield['quantity']),
                                          unit: yield['unit'],
                                          date: yield['date'].toString(),
                                        );
                                        YieldsModel.saveLocally(yieldModel);
                                      });
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(
                                          msg:
                                              "Farm yield data submitted successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('No data to submit'),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      tempSavedYields.clear();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green[500]),
                                  child: Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                          if (tempSavedYields.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: tempSavedYields
                                    .map((yield) => Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    'Animal: ${yield['animal']}, Yield: ${yield['yield']}, Quantity: ${yield['quantity']} ${yield['unit']}, Date: ${yield['date']}'),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  setState(() {
                                                    tempSavedYields
                                                        .remove(yield);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ])),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
