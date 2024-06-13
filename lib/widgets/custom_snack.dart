import 'package:flutter/material.dart';
import 'package:marcci/utils/color_resources.dart';
import 'package:marcci/utils/styles.dart';

void showCustomSnackBar(
  String message, {
  bool isError = true,
  String? title,
  BuildContext? context,
}) {
  if (message != null && message.isNotEmpty) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        backgroundColor: ColorResources.getBlackColor(context),
        content: Text(
          message,
          style: urbanistBold.copyWith(
              fontSize: 12, color: ColorResources.getWhiteColor(context)),
        ),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }
}
