import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/screens/animal_officer/reports/new_report.dart';
import 'package:marcci/screens/settings.dart';
import 'package:marcci/widgets/ReportContainer.dart';
import 'package:marcci/widgets/appbar.dart';
import 'package:uuid/uuid.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String _status =
      'all'; // 'all' for all reports, 'pending' for pending reports, 'submitted' for submitted reports
  DateTime? _selectedDate;
  String _searchFarmId = '';
  List<ReportModel> reports = [];
  List<ReportModel> allReports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    print("Fetching reports");
    List<ReportModel> fetchedReports = await ReportModel.get_items();
    setState(() {
      allReports = fetchedReports;
      filterReports();
    });
  }

  void filterReports() {
    setState(() {
      reports = allReports.where((report) {
        bool matchesDate = _selectedDate == null ||
            report.creationDate ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!);
        bool matchesStatus = _status == 'all' ||
            (_status == 'pending' && report.status == 'pending') ||
            (_status == 'submitted' &&
                report.status.toLowerCase() == 'submitted');
        bool matchesFarmId =
            _searchFarmId.isEmpty || report.farmID.contains(_searchFarmId);
        return matchesDate && matchesStatus && matchesFarmId;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Reports",
        onSettings: () {
          Get.to(() => AppSettings());
          print("Settings pressed");
        },
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            onChanged: (String? newValue) {
                              setState(() {
                                _status = newValue!;
                                filterReports();
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                            ),
                            dropdownColor: Colors.white,
                            items: [
                              DropdownMenuItem(
                                child: Text("All"),
                                value: 'all',
                              ),
                              DropdownMenuItem(
                                child: Text("Pending"),
                                value: 'pending',
                              ),
                              DropdownMenuItem(
                                child: Text("Submitted"),
                                value: 'submitted',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ListTile(
                            title: Text(_selectedDate == null
                                ? 'Select Date'
                                : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                  filterReports();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Search by Farm ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchFarmId = value;
                          filterReports();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: reports.isNotEmpty
                  ? ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return ReportContainer(
                          report: reports[index],
                        );
                      },
                    )
                  : Center(child: Text("No reports available")),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generate a new UUID
          var uuid = Uuid().v4();
          // Navigate to the screen where a new report can be created and pass the UUID
          print("Add new report");
          Get.to(() => CreateReportScreen(
                reportId: uuid,
                onFormAdded: fetchReports,
              ));
        },
        child: const Icon(Icons.add),
        tooltip: 'New Report',
      ),
    );
  }
}
