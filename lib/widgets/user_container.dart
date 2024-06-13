import 'dart:io';

import 'package:flutter/material.dart';

class UserContainer extends StatefulWidget {
  final String imagePath;
  final String userName;
  final String role; // New parameter for the user's role
  final IconData
      roleIcon; // New parameter for the icon representing the user's role
  final String district; // New parameter for the user's district
  final IconData
      districtIcon; // New parameter for the icon representing the user's district
  final bool savingsRecorded; // New parameter to indicate savings status

  const UserContainer({
    Key? key,
    required this.imagePath,
    required this.userName,
    required this.role,
    required this.roleIcon,
    required this.district,
    required this.districtIcon,
    this.savingsRecorded = false, // Default value is false
  }) : super(key: key);

  @override
  _UserContainerState createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: Color.fromARGB(255, 233, 252, 232),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: widget.imagePath.isNotEmpty
                            ? FileImage(File(widget.imagePath))
                            : AssetImage('assets/images/user.jpg')
                                as ImageProvider<Object>,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(widget.districtIcon,
                                  size: 14,
                                  color: Color.fromARGB(255, 1, 164, 7)),
                              SizedBox(width: 4),
                              Text(
                                widget.district,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(widget.roleIcon,
                                  size: 14,
                                  color: Color.fromARGB(255, 1, 164, 7)),
                              SizedBox(width: 4),
                              Text(
                                widget.role,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.info, color: const Color.fromARGB(255, 0, 19, 1))
            ],
          ),
        ),
      ),
    );
  }
}
