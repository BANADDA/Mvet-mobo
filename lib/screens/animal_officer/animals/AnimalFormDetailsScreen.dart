import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marcci/models/AnimalFormModel.dart';

class AnimalFormDetailsScreen extends StatelessWidget {
  final AnimalFormModel animalForm;

  const AnimalFormDetailsScreen({Key? key, required this.animalForm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Animal Form Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 1, 78, 3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Animal Details'),
            _buildAnimalDetailsCard(),
            SizedBox(height: 20.0),
            _buildSectionTitle('Health Information'),
            _buildHealthInformationCard(),
            SizedBox(height: 20.0),
            _buildSectionTitle('Treatment Details'),
            _buildTreatmentDetailsCard(),
          ],
        ),
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

  Widget _buildAnimalDetailsCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(Icons.label, 'Tag Number', animalForm.tagNumber),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.pets, 'Animal Name', animalForm.animalName),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.calendar_today, 'Age', animalForm.age.toString()),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.list_alt, 'Breed', animalForm.breed),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.male, 'Sex', animalForm.sex),
        ],
      ),
    );
  }

  Widget _buildHealthInformationCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(Icons.local_hospital, 'Vaccination Status',
              animalForm.vaccinationStatus),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.healing, 'Deworming Status', animalForm.dewormingStatus),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.sick, 'Previous Illness', animalForm.previousIllness),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.accessibility, 'Body Posture', animalForm.bodyPosture),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.score, 'Body Score', animalForm.bodyScore.toString()),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.sentiment_satisfied, 'Temperament', animalForm.temperament),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.thermostat, 'Rectal Temperature',
              '${animalForm.rectalTemperature}°C'),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.favorite, 'Heart Sounds', animalForm.heartSounds),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.favorite, 'Heart Rate', '${animalForm.heartRate} bpm'),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.air, 'Lung Sounds', animalForm.lungSounds),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.air, 'Respiratory Rate',
              '${animalForm.respiratoryRate} breaths/min'),
        ],
      ),
    );
  }

  Widget _buildTreatmentDetailsCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTextRow(
              Icons.calendar_today, 'Stocking Date', animalForm.stockingDate),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.source, 'Cattle Source', animalForm.cattleSource),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.sick, 'Clinical Symptoms', animalForm.clinicalSymptoms),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.healing, 'Tentative Diagnosis',
              animalForm.tentativeDiagnosis),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.bug_report, 'Other Suspected Disease',
              animalForm.otherSuspectedDisease),
          SizedBox(height: 10.0),
          _buildIconTextRow(Icons.medical_services, 'Supportive Treatment',
              animalForm.supportiveTreatment),
          SizedBox(height: 10.0),
          _buildIconTextRow(
              Icons.check_circle, 'Prognosis', animalForm.prognosis),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
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
}
