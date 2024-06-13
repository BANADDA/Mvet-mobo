import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/widgets/ReportContainer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _status = true; // true for submitted, false for not submitted
  DateTime? _selectedDate;
  List<ReportModel> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void fetchReports() async {
    print("Fetching reports");
    List<ReportModel> fetchedReports = await ReportModel.get_items();
    setState(() {
      reports = fetchedReports;
      print("Reports data: ${reports.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<bool>(
                          value: _status,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _status = newValue!;
                              fetchReports();
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              child: Text("Submitted"),
                              value: true,
                            ),
                            DropdownMenuItem(
                              child: Text("Not Submitted"),
                              value: false,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(_selectedDate == null
                              ? 'Select Date'
                              : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                          trailing: Icon(
                            Icons.calendar_month_sharp,
                            color: const Color.fromARGB(255, 1, 80, 4),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                                fetchReports();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                reports.isNotEmpty
                    ? Column(
                        children: reports.map((report) {
                          return ReportContainer(
                            report: report,
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("No reports available"),
                        ],
                      )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen where a new report can be created
          print("Add new report");
          // Implement navigation logic as needed
        },
        child: const Icon(Icons.add),
        tooltip: 'New Report',
      ),
    );
  }
}
