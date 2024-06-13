import 'package:flutter/material.dart';
import 'package:flutx/widgets/container/container.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:shimmer/shimmer.dart';

import 'Utils.dart';

Widget valueUnitWidget2(dynamic title, dynamic value,
    {double fontSize = 6,
    double letterSpacing = -1,
    Color titleColor = Colors.grey,
    Color color = Colors.black,
    fontWeight = FontWeight.w500}) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.bodySmall(
          '${title.toString().toUpperCase()}:',
          height: 0,
          color: titleColor,
        ),
        FxText.bodyLarge(
          value.toString(),
          height: 0,
          color: color,
          letterSpacing: -.5,
        ),
      ],
    ),
  );
}

Widget valueUnitWidget(BuildContext context, dynamic value, dynamic unit,
    {double fontSize = 6,
    double letterSpacing = -1,
    Color color = Colors.grey,
    Color titleColor = Colors.black,
    fontWeight = FontWeight.w500}) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        height: 1,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(
          text: '${value.toString()}',
          style: TextStyle(
              color: titleColor,
              letterSpacing: letterSpacing,
              fontSize: Utils.mediaWidth(context) / fontSize,
              fontWeight: fontWeight),
        ),
        TextSpan(
          text: ' ${unit.toString()}',
          style: TextStyle(
            color: color,
            fontSize: Utils.mediaWidth(context) / (fontSize * 1),
          ),
        ),
      ],
    ),
    textScaleFactor: 0.5,
  );
}

Widget myListLoaderWidget(BuildContext context) {
  return ListView(
    children: [
      singleLoadingWidget(context),
      singleLoadingWidget(context),
      singleLoadingWidget(context),
      singleLoadingWidget(context),
      singleLoadingWidget(context),
    ],
  );
}

Widget myContainerLoaderWidget(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade50,
    highlightColor: Colors.grey.shade300,
    child: FxContainer(
      width: Utils.mediaWidth(context) / 4,
      height: Utils.mediaWidth(context) / 4,
      color: Colors.grey,
    ),
  );
}

Widget singleLoadingWidget(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
      left: 15,
      right: 10,
      top: 8,
      bottom: 8,
    ),
    child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade50,
          highlightColor: Colors.grey.shade300,
          child: FxContainer(
            width: Utils.mediaWidth(context) / 4,
            height: Utils.mediaWidth(context) / 4,
            color: Colors.grey,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: Shimmer.fromColors(
          baseColor: Colors.grey.shade50,
          highlightColor: Colors.grey.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxContainer(
                color: Colors.grey,
                height: Utils.mediaWidth(context) / 30,
                width: Utils.mediaWidth(context) / 3,
              ),
              SizedBox(
                height: 5,
              ),
              FxContainer(
                height: Utils.mediaWidth(context) / 14,
                color: Colors.grey,
              ),
              SizedBox(
                height: 5,
              ),
              FxContainer(
                height: Utils.mediaWidth(context) / 14,
                color: Colors.grey,
              ),
              SizedBox(
                height: 5,
              ),
              Flex(
                direction: Axis.horizontal,
                children: [
                  FxContainer(
                    color: Colors.grey,
                    height: Utils.mediaWidth(context) / 30,
                    width: Utils.mediaWidth(context) / 6,
                  ),
                  Spacer(),
                  FxContainer(
                    color: Colors.grey,
                    height: Utils.mediaWidth(context) / 30,
                    width: Utils.mediaWidth(context) / 6,
                  ),
                ],
              )
            ],
          ),
        ))
      ],
    ),
  );
}
