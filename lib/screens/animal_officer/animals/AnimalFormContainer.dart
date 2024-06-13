import 'package:flutter/material.dart';
import 'package:marcci/models/AnimalFormModel.dart';
import 'package:marcci/models/FieldReportModel.dart';

class AnimalFormContainer extends StatelessWidget {
  final AnimalFormModel animalForm;
  final ReportModel report;
  final VoidCallback onViewDetails;

  const AnimalFormContainer({
    Key? key,
    required this.animalForm,
    required this.report,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.green),
                SizedBox(width: 8),
                Text('Date  Created',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(report.creationDate),
              ],
            ),
            Divider(),
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.green),
                SizedBox(width: 8),
                Text('Farm ID', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(report.farmID),
              ],
            ),
            Divider(),
            Row(
              children: [
                Icon(Icons.pets, color: Colors.green),
                SizedBox(width: 8),
                Text('Animal ID',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(animalForm.animalID),
              ],
            ),
            Divider(),
            Row(
              children: [
                Icon(Icons.female, color: Colors.green),
                SizedBox(width: 8),
                Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(animalForm.sex),
              ],
            ),
            Divider(),
            Row(
              children: [
                Icon(Icons.grass, color: Colors.green),
                SizedBox(width: 8),
                Text('Breed', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(animalForm.breed),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Button color
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'View',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
