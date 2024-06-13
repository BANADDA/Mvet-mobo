import 'package:flutter/material.dart';

class ReportWidget extends StatelessWidget {
  final String farmName;
  final String farmerName;
  final String dateCreated;
  final String sampleId;

  const ReportWidget({
    Key? key,
    required this.farmName,
    required this.farmerName,
    required this.dateCreated,
    this.sampleId = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(Icons.description, color: Colors.green),
        title: Text(farmName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: $farmerName'),
            Text('Date: $dateCreated'),
            if (sampleId.isNotEmpty) Text('Sample ID: $sampleId'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
