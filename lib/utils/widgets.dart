import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:marcci/models/UserModel.dart';
import 'package:marcci/theme/app_theme.dart';
import 'package:marcci/utils/AppConfig.dart';
import 'package:marcci/utils/Utils.dart';
import 'package:shimmer/shimmer.dart';

import '../models/SaccoMemberModel.dart';
import '../theme/custom_theme.dart';

Widget myImg(String url, double w, double h,
    {String no_image = AppConfig.NO_IMAGE, double radius = 10}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: url,
      width: w,
      height: h,
      placeholder: (context, url) => ShimmerLoadingWidget(
        height: h,
      ),
      errorWidget: (context, url, error) => Image(
        image: AssetImage(no_image),
        fit: BoxFit.cover,
        width: (h),
        height: (w),
      ),
    ),
  );
}

Widget roundedImage(String url, double w, double h,
    {String no_image = AppConfig.NO_IMAGE, double radius = 10}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: url,
      width: (Get.width / w),
      height: (Get.width / h),
      placeholder: (context, url) => ShimmerLoadingWidget(
        height: double.infinity,
      ),
      errorWidget: (context, url, error) => Image(
        image: AssetImage(no_image),
        fit: BoxFit.cover,
        width: (Get.width / w),
        height: (Get.width / h),
      ),
    ),
  );
}

Widget circularImage(String url, double size,
    {String no_image = AppConfig.USER_IMAGE}) {
  return ClipOval(
    child: Container(
      color: CustomTheme.primary,
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: url,
        width: (Get.width / size),
        height: (Get.width / size),
        placeholder: (context, url) => ShimmerLoadingWidget(
          height: double.infinity,
        ),
        errorWidget: (context, url, error) => Image(
          image: AssetImage(no_image),
          fit: BoxFit.cover,
          width: (Get.width / size),
          height: (Get.width / size),
        ),
      ),
    ),
  );
}

Widget titleValueWidget(String title, String subTitle) {
  return Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(bottom: 7),
    child: Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.bodyMedium(
              '$title : '.toUpperCase(),
              maxLines: 10,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: 700,
              letterSpacing: .5,
              height: .8,
              fontSize: 20,
            ),
            FxText.bodyLarge(
              subTitle.isEmpty ? "-" : subTitle,
              textAlign: TextAlign.left,
              color: const Color.fromARGB(255, 50, 50, 50),
              maxLines: 1,
              fontWeight: 700,
              fontSize: 18,
            ),
          ],
        ),
        SizedBox(
          height: 3,
        ),
      ],
    ),
  );
}

Widget titleValueWidget2(String title, String subTitle,
    {double vertical = 0, double horizontal = 0}) {
  return Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
    child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: FxText.bodyLarge(
            '$title : '.toUpperCase(),
            textAlign: TextAlign.left,
            color: Colors.black,
            fontWeight: 700,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: FxText.bodyLarge(
            subTitle.isEmpty ? "-" : '$subTitle',
            textAlign: TextAlign.right,
            fontWeight: 500,
          ),
        ),
      ],
    ),
  );
}

Widget singleWidget(String title, String subTitle) {
  /*   return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: valueUnitWidget(
        context,
        '${title} :',
        subTitle,
        fontSize: 10,
        titleColor: CustomTheme.primary,
        color: Colors.grey.shade600,
      ),
    );*/
  return Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(top: 4, bottom: 4),
    child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: FxText.bodyLarge(
            '$title :'.toUpperCase(),
            textAlign: TextAlign.right,
            color: CustomTheme.primary,
            fontWeight: 700,
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
            child: FxText.bodyLarge(
          subTitle,
          maxLines: 10,
        )),
      ],
    ),
  );
}

Widget ShimmerLoadingWidget(
    {double width = double.infinity,
    double height = 200,
    bool is_circle = false,
    double padding = 0.0}) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: SizedBox(
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade50,
        highlightColor: Colors.grey.shade300,
        child: FxContainer(),
      ),
    ),
  );
}

Widget userWidget1(UserModel item) {
  return InkWell(
    onTap: () {},
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: circularImage(item.avatar.toString(), 5.5),
        ),
        Center(
          child: FxText.titleSmall(
            item.name,
            maxLines: 1,
            height: 1.2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

Widget userSaccoMemberModel(SaccoMemberModel u) {
  return Container(
    padding: EdgeInsets.only(top: 10, left: 15, right: 15),
    child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        roundedImage(u.avatar.toString(), 5.0, 5.0),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.titleMedium(
                u.name,
                maxLines: 1,
                fontWeight: 800,
                overflow: TextOverflow.ellipsis,
              ),
              FxText.bodyMedium(
                u.phone_number.isEmpty
                    ? "-"
                    : u.phone_number.toString().toUpperCase(),
                color: Colors.grey.shade600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 3,
              ),
              u.sacco_join_status == 'Approved'
                  ? Row(
                      children: [
                        Expanded(
                          child: FxContainer(
                            paddingAll: 0,
                            borderRadiusAll: 0,
                            color: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FxText.bodySmall(
                                  "BALANCE",
                                  fontWeight: 800,
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Divider(
                                  height: .5,
                                  color: Colors.white,
                                ),
                                FxText.bodySmall(
                                  "UGX ${Utils.moneyFormat(u.balance)}",
                                  fontWeight: 800,
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: FxContainer(
                            paddingAll: 0,
                            borderRadiusAll: 0,
                            color: u.hasLoan
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FxText.bodySmall(
                                  "LOAN BALANCE",
                                  fontWeight: 900,
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Divider(
                                  height: .5,
                                  color: Colors.white,
                                ),
                                FxText.bodySmall(
                                  "UGX ${Utils.moneyFormat(u.LOAN_BALANCE)}",
                                  fontWeight: 800,
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : FxContainer(
                      color: u.sacco_join_status == 'Approved'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: FxText.bodySmall(
                        u.sacco_join_status,
                        fontWeight: 800,
                        color: Colors.white,
                      ),
                    )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget userWidget(UserModel u) {
  return InkWell(
    onTap: () {
      //Get.toNamed('/user/${u.id}');
    },
    child: Container(
      padding: EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          roundedImage(u.avatar.toString(), 4.5, 4.5),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.titleMedium(
                  u.name.toUpperCase(),
                  maxLines: 1,
                  fontWeight: 800,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    FxText.bodyMedium(
                      'CLASS: ',
                    ),
                  ],
                ),
                Row(
                  children: [
                    FxText.bodyMedium(
                      'STUDENT ID: ',
                    ),
                    FxText.bodyMedium(
                      u.id.toString().toUpperCase(),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    Icon(
                      FeatherIcons.user,
                      size: 12,
                      color: CustomTheme.primaryDark,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    FxText.bodySmall('By John Doe', color: Colors.grey),
                    Spacer(),
                    Icon(
                      FeatherIcons.clock,
                      size: 12,
                      color: CustomTheme.primaryDark,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    FxText.bodySmall(
                      Utils.to_date_1(u.created_at),
                      color: Colors.grey,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget alertWidget(String msg, String type) {
  if (msg.isEmpty) {
    return const SizedBox();
  }
  Color borderColor = CustomTheme.primary;
  Color bgColor = CustomTheme.primary.withAlpha(10);
  if (type == 'success') {
    borderColor = Colors.green.shade700;
    bgColor = Colors.green.shade700.withAlpha(10);
  } else if (type == 'danger') {
    borderColor = Colors.red.shade700;
    bgColor = Colors.red.shade700.withAlpha(10);
  }

  return FxContainer(
    margin: const EdgeInsets.only(bottom: 15),
    width: double.infinity,
    color: bgColor,
    bordered: true,
    borderColor: borderColor,
    child: FxText(msg),
  );
}

Widget noItemWidget(String title, String actionText, Function onTap) {
  if (title.isEmpty) {
    title = "😇 No item found.";
  }
  return Container(
    padding: EdgeInsets.all(35),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FxText(
            title,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          FxButton.outlined(
              borderColor: CustomTheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadiusAll: 100,
              onPressed: () {
                onTap();
              },
              child: FxText.bodySmall(
                actionText,
                color: CustomTheme.primary,
                fontWeight: 700,
              ))
        ],
      ),
    ),
  );
}

Widget titleWidget(String title, Function onTap) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: Container(
      padding: EdgeInsets.only(left: 5, top: 20, right: 5, bottom: 10),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          FxText.titleMedium(
            title.toUpperCase(),
            fontWeight: 700,
            color: Colors.black,
          ),
          Spacer(),
          Row(
            children: [
              FxText.bodyLarge(
                'View All'.toUpperCase(),
                fontWeight: 300,
                letterSpacing: .1,
              ),
              Icon(FeatherIcons.chevronRight),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget textInput2(
  context, {
  required String label,
  required String name,
  required String value,
  bool required = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10, top: 10),
    child: FormBuilderTextField(
      name: name,
      initialValue: value,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onChanged: (x) {},
      keyboardType: TextInputType.name,
      decoration: AppTheme.InputDecorationTheme1(
        label: label,
      ),
      validator: (!required)
          ? FormBuilderValidators.compose([])
          : MyWidgets.my_validator_field_required(
              context, '$label is required'),
    ),
  );
  return FormBuilderTextField(
    decoration: CustomTheme.in_3(
      label: label,
    ),
    initialValue: value,
    textCapitalization: TextCapitalization.sentences,
    name: name,
    validator: (!required)
        ? FormBuilderValidators.compose([])
        : MyWidgets.my_validator_field_required(context, 'Title is required'),
    textInputAction: TextInputAction.next,
  );
}

Widget textInput(
  context, {
  required String label,
  required String name,
  required String value,
  bool required = false,
}) {
  return FormBuilderTextField(
    decoration: CustomTheme.in_3(
      label: label,
    ),
    initialValue: value,
    textCapitalization: TextCapitalization.sentences,
    name: name,
    validator: (!required)
        ? FormBuilderValidators.compose([])
        : MyWidgets.my_validator_field_required(context, 'Title is required'),
    textInputAction: TextInputAction.next,
  );
}

// ignore: non_constant_identifier_names
Widget title_widget_2(String title) {
  return FxContainer(
    alignment: Alignment.center,
    color: CustomTheme.primaryDark,
    borderRadiusAll: 0,
    paddingAll: 5,
    child: FxText.bodyLarge(
      title.toUpperCase(),
      color: Colors.white,
    ),
  );
}

// ignore: non_constant_identifier_names
Widget title_widget(String title) {
  return Container(
    padding: EdgeInsets.only(top: 3, bottom: 3),
    color: CustomTheme.primary,
    child: Center(
      child: FxText.titleMedium(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        fontWeight: 700,
        fontSize: 18,
        color: Colors.white,
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget IconTextWidget(
  String t,
  String s,
  bool isDone,
  Function f, {
  bool show_acation_button = true,
  String action_text = "Edit",
}) {
  return ListTile(
    leading: isDone
        ? Icon(
            Icons.check,
            color: Colors.green,
            size: 28,
          )
        : Icon(
            Icons.label_outline_sharp,
            color: Colors.red.shade600,
            size: 28,
          ),
    contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
    minLeadingWidth: 0,
    trailing: (!show_acation_button)
        ? null
        : FxButton.outlined(
            onPressed: () {
              f();
            },
            child: FxText(
              action_text,
              color: CustomTheme.primary,
              fontSize: 18,
            ),
            padding: EdgeInsets.zero,
            borderRadiusAll: 30,
            borderColor: CustomTheme.primary,
          ),
    title: FxText.titleMedium(
      t,
      fontWeight: 700,
      color: Colors.black,
    ),
    subtitle: FxText.bodyMedium(s,
        fontWeight: 600,
        maxLines: 2,
        color: Colors.grey.shade700,
        height: 1.1,
        overflow: TextOverflow.ellipsis),
  );
}

class MyWidgets {
  static FormFieldValidator my_validator_field_required(
      BuildContext context, String field) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: "$field is required.",
      ),
    ]);
  }
}
