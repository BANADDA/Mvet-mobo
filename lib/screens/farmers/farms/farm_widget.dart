import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

class ReportWidget extends StatelessWidget {
  final int reportID;
  final String submissionDate;
  final String status;

  const ReportWidget({
    Key? key,
    required this.reportID,
    required this.submissionDate,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the detailed report screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => ReportDetailScreen(reportID: reportID)),
        // );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText('Report ID: $reportID'),
                SizedBox(height: 4),
                FxText('Submitted on: $submissionDate'),
              ],
            ),
            FxText('Status: $status', color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
