import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marcci/models/FieldReportModel.dart';
import 'package:marcci/screens/animal_officer/reports/report_details_screen.dart';

class ReportContainer extends StatelessWidget {
  final ReportModel report;

  const ReportContainer({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ReportDetailsScreen(report: report));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
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
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        const Color.fromARGB(255, 21, 90, 23).withOpacity(0.6),
                    child: Icon(
                      Icons.insert_drive_file,
                      color: Color.fromARGB(255, 239, 246, 240),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    color: report.status.toLowerCase() ==
                                            'submitted'
                                        ? Colors.greenAccent.withOpacity(0.2)
                                        : report.status.isEmpty
                                            ? Colors.grey.withOpacity(0.2)
                                            : Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Text(
                                    report.status.isEmpty
                                        ? 'No Status'
                                        : report.status,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      color: report.status.toLowerCase() ==
                                              'submitted'
                                          ? Colors.green
                                          : report.status.isEmpty
                                              ? Colors.grey
                                              : Color.fromARGB(255, 160, 4, 4),
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
                            color: const Color.fromARGB(255, 16, 52, 17),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
