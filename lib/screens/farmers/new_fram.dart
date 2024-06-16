import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/FeedsModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
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

  void _showBottomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ServiceCard(
                              title: 'Farm Statistics',
                              subtitle: 'Click to view farm statistics',
                              services: [
                                {'title': 'Animal Feeds', 'onPressed': () {}},
                                {'title': 'Health Status', 'onPressed': () {}},
                                {'title': 'Animal Stock', 'onPressed': () {}},
                                {'title': 'Farm Yields', 'onPressed': () {}},
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
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnimalFeedsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<Map<String, dynamic>> feedData = [{}];
            List<Widget> feedForms = [
              _buildFeedForm(0, setState, feedData),
            ];

            void addFeedForm() {
              setState(() {
                feedData.add({});
                feedForms.add(
                  _buildFeedForm(feedData.length - 1, setState, feedData),
                );
              });
            }

            void removeFeedForm(int index) {
              setState(() {
                feedData.removeAt(index);
                feedForms.removeAt(index);
              });
            }

            void submitFeedData() async {
              bool isValid = true;
              for (var feed in feedData) {
                if (feed['name'] == null ||
                    feed['quantity'] == null ||
                    feed['date'] == null) {
                  isValid = false;
                  break;
                }
              }

              if (isValid) {
                for (var feed in feedData) {
                  FeedModel newFeed = FeedModel(
                    feedName: feed['name'],
                    quantity: feed['quantity'],
                    date: feed['date'],
                    farmID: (await _firstFarmFuture)!.farmID,
                  );
                  await newFeed.save();
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Feeds saved successfully'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields'),
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Animal Feeds",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: feedForms,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: addFeedForm,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green, // foreground
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("Add Feed"),
                        ),
                        ElevatedButton(
                          onPressed: submitFeedData,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // foreground
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text("Submit Feeds"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedForm(
      int index, StateSetter setState, List<Map<String, dynamic>> feedData) {
    TextEditingController dateController = TextEditingController();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
          feedData[index]['date'] = dateController.text;
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                feedData[index]['name'] = value;
              },
              decoration: InputDecoration(
                labelText: 'Feed Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              onChanged: (value) {
                feedData[index]['quantity'] = value;
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
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
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedAnimal != null && _symptoms.isNotEmpty) {
                            print({
                              'animal': _selectedAnimal,
                              'symptoms': _symptoms,
                            });
                            Navigator.pop(context);
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
                        child: Text('Submit'),
                      ),
                    ),
                  ]),
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

                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
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
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedAnimal != null &&
                              _quantity != null &&
                              _date != null) {
                            print({
                              'animal': _selectedAnimal,
                              'quantity': _quantity,
                              'date': _date,
                            });
                            Navigator.pop(context);
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
                        child: Text('Submit'),
                      ),
                    ),
                  ]),
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
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Form(
                        key: formKey,
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
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
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate() &&
                                    _date != null &&
                                    _selectedAnimal != null &&
                                    _selectedYield != null &&
                                    _selectedUnit != null) {
                                  formKey.currentState!.save();
                                  print({
                                    'animal': _selectedAnimal,
                                    'yield': _selectedYield,
                                    'quantity': _quantity,
                                    'unit': _selectedUnit,
                                    'date': _date,
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Navigator.pop(context);
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
                              child: Text('Submit'),
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
