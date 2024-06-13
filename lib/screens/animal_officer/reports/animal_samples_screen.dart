import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/models/LoggedInUserModel.dart';
import 'package:marcci/models/SampleModel.dart';
import 'package:marcci/widgets/appbar.dart';

class AnimalSamplesScreen extends StatefulWidget {
  @override
  _AnimalSamplesScreenState createState() => _AnimalSamplesScreenState();
}

class _AnimalSamplesScreenState extends State<AnimalSamplesScreen> {
  List<SampleModel> samples = [];
  List<SampleModel> filteredSamples = [];
  bool isLoading = true;
  late LoggedInUserModel _loggedInUser;
  TextEditingController searchController = TextEditingController();

  Future<void> _fetchLoggedInUser() async {
    _loggedInUser = await LoggedInUserModel.getLoggedInUser();
  }

  @override
  void initState() {
    super.initState();
    fetchSamples();
  }

  void fetchSamples() async {
    await _fetchLoggedInUser();
    print("Logged in user: ${_loggedInUser.role_name}");
    List<SampleModel> fetchedSamples = await SampleModel.getItems();
    setState(() {
      samples = fetchedSamples;
      filteredSamples = fetchedSamples;
      isLoading = false;
    });
  }

  void filterSamples(String query) {
    List<SampleModel> results = [];
    if (query.isEmpty) {
      results = samples;
    } else {
      results = samples.where((sample) {
        String farmId = '';
        return sample.sampleUUID.contains(query) || farmId.contains(query);
      }).toList();
    }

    setState(() {
      filteredSamples = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FxAppBar(
        titleText: "Animal Samples",
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
                labelText: 'Search by Farm ID or Sample ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterSamples('');
                  },
                ),
              ),
              onChanged: (value) {
                filterSamples(value);
              },
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(
                    child: SpinKitFadingCircle(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                : filteredSamples.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: filteredSamples.length,
                          itemBuilder: (context, index) {
                            return SampleCard(sample: filteredSamples[index]);
                          },
                        ),
                      )
                    : Center(child: Text("No samples available")),
          ],
        ),
      ),
    );
  }
}

class SampleCard extends StatelessWidget {
  final SampleModel sample;

  const SampleCard({required this.sample});

  Future<String> getFarmId(String reportId) async {
    ReportModel report = await ReportModel.getItemById(reportId);
    return report.farmID;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getFarmId(sample.reportID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String farmId = snapshot.data ?? 'Unknown';
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sample.sampleType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: sample.status.toLowerCase() == 'pending'
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          sample.status,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Date: ${sample.sampleDate}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Sample ID: ${sample.sampleUUID}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Farm ID: $farmId',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 5),
                  sample.status.toLowerCase() == 'completed'
                      ? ElevatedButton(
                          onPressed: () {
                            // Navigate to sample results screen if needed
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color.fromARGB(255, 1, 50, 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('View Results'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Sample needs to be submitted for review."),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'View Results',
                            style:
                                TextStyle(color: Color.fromARGB(255, 1, 59, 3)),
                          ),
                        ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
