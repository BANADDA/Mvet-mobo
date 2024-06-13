import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/screens/animal_officer/reports/report_details_screen.dart';
import 'package:marcci/utils/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmDetailScreen extends StatefulWidget {
  final FarmModel farm;

  const FarmDetailScreen({Key? key, required this.farm}) : super(key: key);

  @override
  _FarmDetailScreenState createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  List<ReportModel> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  void loadReports() async {
    List<ReportModel> loadedReports =
        await ReportModel.getReportsByFarmId(widget.farm.farmID);
    setState(() {
      reports = loadedReports;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Animals: ${widget.farm.animalsData}");
    String cleanData = widget.farm.managementSystemsData;
    // Remove the leading and trailing brackets and trim extra spaces if any
    cleanData = cleanData.substring(1, cleanData.length - 1).trim();
    // Split the string into a list, considering quotes and commas
    List<String> managementSystems =
        cleanData.split('","').map((str) => str.replaceAll('"', '')).toList();

    // Decode the JSON-encoded string of animalsData into a List<Map<String, dynamic>>
    List<Map<String, dynamic>> animals = [];
    try {
      animals =
          List<Map<String, dynamic>>.from(json.decode(widget.farm.animalsData));
    } catch (e) {
      // Handle potential errors in decoding
      print('Error decoding animalsData: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: FxText('${widget.farm.farmName} Details',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: ColorResources.getPrimaryColor(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green[200], // Light green background for the header
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FxText("Farmer Names: ",
                            color: Color.fromARGB(255, 1, 43, 2),
                            fontSize: 20,
                            fontWeight: 900),
                        FxText(widget.farm.farmerName,
                            color: Color.fromARGB(255, 1, 43, 2),
                            fontSize: 18,
                            fontWeight: 900),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 175, 215, 177),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FxText('Village:',
                                    color: Color.fromARGB(255, 1, 43, 2),
                                    fontSize: 16,
                                    fontWeight: 800),
                                FxText(widget.farm.villageName,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FxText('Parish:',
                                    color: Color.fromARGB(255, 1, 43, 2),
                                    fontSize: 16,
                                    fontWeight: 800),
                                FxText(widget.farm.parishName,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FxText('Subcounty:',
                                    color: Color.fromARGB(255, 1, 43, 2),
                                    fontSize: 16,
                                    fontWeight: 800),
                                FxText(widget.farm.subcountyName,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FxText('District:',
                                    color: Color.fromARGB(255, 1, 43, 2),
                                    fontSize: 16,
                                    fontWeight: 800),
                                FxText(widget.farm.districtName,
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FxText('Phone Number:',
                            color: Color.fromARGB(255, 1, 43, 2),
                            fontSize: 16,
                            fontWeight: 800),
                        InkWell(
                            onTap: () =>
                                launch('tel:${widget.farm.farmerPhone}'),
                            child: Row(
                              children: [
                                Icon(Icons.phone, color: Colors.green[800]),
                                SizedBox(width: 8),
                                FxText(widget.farm.farmerPhone,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.green[800])),
                              ],
                            )),
                      ],
                    )
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ManagementSystemWidget(
                        managementSystems: managementSystems),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AnimalWidget(animals: animals),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    color: Color.fromARGB(255, 7, 79, 9),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Icon(Icons.file_copy_sharp, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: FxText('Farm Reports', color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (reports.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text("No reports found for this farm"),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: reports.map((report) {
                          return InkWell(
                            onTap: () {
                              Get.to(() => ReportDetailsScreen(report: report));
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 8),
                              color: Color.fromARGB(255, 235, 250, 235),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Farm ID: ${report.farmID}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 7, 0),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color:
                                                  report.status.toLowerCase() ==
                                                          'submitted'
                                                      ? Colors.greenAccent
                                                          .withOpacity(0.2)
                                                      : report.status.isEmpty
                                                          ? Colors.grey
                                                              .withOpacity(0.2)
                                                          : Colors.redAccent
                                                              .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: Text(
                                              report.status.isEmpty
                                                  ? 'No Status'
                                                  : report.status,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w700,
                                                color: report.status
                                                            .toLowerCase() ==
                                                        'submitted'
                                                    ? Colors.green
                                                    : report.status.isEmpty
                                                        ? Colors.grey
                                                        : Color.fromARGB(
                                                            255, 160, 4, 4),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    report.creationDate.isNotEmpty
                                        ? report.creationDate
                                        : 'Created Date',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          const Color.fromARGB(255, 16, 52, 17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ManagementSystemWidget extends StatelessWidget {
  final List<String> managementSystems;

  const ManagementSystemWidget({Key? key, required this.managementSystems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Color.fromARGB(255, 7, 79, 9),
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(Icons.business, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: FxText('Management Systems', color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Building a list of Text widgets, each prefixed with a bullet
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              managementSystems.map((system) => Text('• $system')).toList(),
        ),
      ],
    );
  }
}

class AnimalWidget extends StatelessWidget {
  final List<Map<String, dynamic>> animals;

  const AnimalWidget({Key? key, required this.animals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Color.fromARGB(255, 7, 79, 9),
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Icon(Icons.pets, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: FxText('Animals', color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color.fromARGB(255, 58, 144, 190);
          }),
          border: TableBorder.all(
            color: Color.fromARGB(255, 57, 142, 187),
            width: 2,
            style: BorderStyle.solid,
          ),
          columns: [
            DataColumn(
                label: FxText(
              'Animal',
              color: Colors.white,
              fontWeight: 600,
              fontSize: 14,
            )),
            DataColumn(
                label: FxText(
              'Count',
              color: Colors.white,
              fontWeight: 600,
              fontSize: 14,
            )),
          ],
          rows: animals
              .map(
                (animal) => DataRow(cells: [
                  DataCell(FxText(
                    animal['type'],
                    fontSize: 15,
                    fontWeight: 600,
                  )),
                  DataCell(FxText(
                    animal['total'].toString(),
                    fontSize: 15,
                    fontWeight: 600,
                  )),
                ]),
              )
              .toList(),
        ),
      ],
    );
  }
}
