import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
                // Your content for messages screen
                ),
          );
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
              // Your content for messages screen
              ),
        );
      },
    );
  }
}
