import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marcci/models/AnimalFormModel.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/screens/animal_officer/animals/AnimalFormContainer.dart';
import 'package:marcci/screens/animal_officer/animals/AnimalFormDetailsScreen.dart';
import 'package:marcci/widgets/appbar.dart';

class AnimalFormsScreen extends StatefulWidget {
  @override
  _AnimalFormsScreenState createState() => _AnimalFormsScreenState();
}

class _AnimalFormsScreenState extends State<AnimalFormsScreen> {
  List<AnimalFormModel> animalForms = [];
  List<AnimalFormModel> filteredAnimalForms = [];
  Map<String, ReportModel> reports = {};
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAnimalForms();
  }

  void fetchAnimalForms() async {
    List<AnimalFormModel> fetchedForms = await AnimalFormModel.getItems();
    Map<String, ReportModel> fetchedReports = {};

    for (var form in fetchedForms) {
      print("Form report id: ${form.reportID}");
      ReportModel report = await getReport(form.reportID);
      fetchedReports[form.animalID] = report;
    }

    setState(() {
      animalForms = fetchedForms;
      reports = fetchedReports;
      filteredAnimalForms = fetchedForms;
      isLoading = false;
    });
  }

  Future<ReportModel> getReport(String reportId) async {
    ReportModel report = await ReportModel.getItemById(reportId);
    if (report != null) {
      print("Report fetched: ${report.toString()}");
      print("Report ids: ${report.report_id}");
      return report;
    } else {
      print("Report not found for id: $reportId");
      return Future.value(null);
    }
  }

  void filterAnimalForms() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredAnimalForms = animalForms;
      } else {
        filteredAnimalForms = animalForms.where((form) {
          final animalIdMatch =
              form.animalID.toLowerCase().contains(_searchQuery.toLowerCase());
          final farmIdMatch = reports[form.animalID]
                  ?.farmID
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false;
          return animalIdMatch || farmIdMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Animal Forms",
        onBack: () {
          Navigator.pop(context);
        },
        onSettings: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Animal ID or Farm ID',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  filterAnimalForms();
                });
              },
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    )
                  : filteredAnimalForms.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredAnimalForms.length,
                          itemBuilder: (context, index) {
                            return AnimalFormContainer(
                              animalForm: filteredAnimalForms[index],
                              report: reports[
                                      filteredAnimalForms[index].animalID] ??
                                  ReportModel(),
                              onViewDetails: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnimalFormDetailsScreen(
                                      animalForm: filteredAnimalForms[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : Center(child: Text("No animal forms available")),
            ),
          ],
        ),
      ),
    );
  }
}
