import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marcci/models/AnimalFormModel.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/screens/animal_officer/animals/AnimalFormDetailsScreen.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsScreen({Key? key, required this.report}) : super(key: key);

  Future<List<AnimalFormModel>> fetchAnimalForms() async {
    print("Report id: ${report.report_id}");
    List<AnimalFormModel> allForms = await AnimalFormModel.getItems();
    print("Animal form report id: ${allForms.first.reportID}");
    // Filter forms by reportID
    return allForms.where((form) => form.reportID == report.report_id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 1, 78, 3),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Farm Details'),
                _buildFarmDetailsCard(),
                SizedBox(height: 20.0),
                _buildSectionTitle('Status'),
                _buildStatusCard(),
                SizedBox(height: 20.0),
                _buildSectionTitle('Survey Details'),
                _buildSurveyDetailsCard(),
                SizedBox(height: 20.0),
                _buildSectionTitle('Security Measures'),
                _buildSecurityMeasuresCard(),
                SizedBox(height: 20.0),
                _buildSectionTitle('Animal Forms'),
                _buildAnimalFormsSection(),
                SizedBox(height: 80.0), // Extra space for the submit button
              ],
            ),
          ),
          if (report.status.toLowerCase() == 'pending')
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _buildSubmitButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 1, 78, 3),
      ),
    );
  }

  Widget _buildFarmDetailsCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(Icons.agriculture, 'Farm ID', report.farmID),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.location_on, 'Farm', report.content),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.calendar_today, 'Created Date', report.creationDate),
        ],
      ),
    );
  }

  Widget _buildSurveyDetailsCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(
              Icons.supervised_user_circle, 'Survey Type', report.surveyType),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.cloud_done, 'Season', report.season),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.local_hospital, 'Disease Type', report.diseaseType),
        ],
      ),
    );
  }

  Widget _buildSecurityMeasuresCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(Icons.security, 'Bio Security Measures',
              report.bioSecurityMeasures),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.fastfood, 'Feeding Mechanisms', report.feedingMechanisms),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return _buildGlassContainer(
      child: _buildIconTextRow(
        Icons.info_outline,
        'Status',
        report.status.isEmpty ? 'No Status' : report.status,
        color: report.status.toLowerCase() == 'submitted'
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  Widget _buildAnimalFormsSection() {
    return FutureBuilder<List<AnimalFormModel>>(
      future: fetchAnimalForms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching animal forms'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No animal forms available'));
        }

        List<AnimalFormModel> animalForms = snapshot.data!;
        return Column(
          children: animalForms.map((animalForm) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AnimalFormDetailsScreen(animalForm: animalForm),
                  ),
                );
              },
              child: _buildGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAnimalContainer(
                            Icons.pets, 'Animal ID', animalForm.animalID),
                        SizedBox(height: 10.0),
                        _buildAnimalContainer(
                            Icons.tag, 'Gender', animalForm.sex),
                        SizedBox(height: 10.0),
                        _buildAnimalContainer(
                            Icons.label, 'Breed', animalForm.breed),
                      ],
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimalFormDetailsScreen(
                                  animalForm: animalForm),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 1, 78, 3),
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'View',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAnimalContainer(IconData icon, String title, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30.0,
          color: color ?? const Color.fromARGB(255, 1, 78, 3),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 1, 78, 3),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                  color: const Color.fromARGB(255, 0, 7, 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextRow(IconData icon, String title, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30.0,
          color: color ?? const Color.fromARGB(255, 1, 78, 3),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 1, 78, 3),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                  color: const Color.fromARGB(255, 0, 7, 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Submit action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report Submitted Successfully')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 1, 78, 3),
        padding: EdgeInsets.symmetric(vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Center(
        child: Text(
          'Submit Report',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
