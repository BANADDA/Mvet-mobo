import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:marcci/utils/color_resources.dart';
import 'package:marcci/utils/dimensions.dart';
import 'package:marcci/utils/styles.dart';
import 'package:marcci/widgets/custom_snack.dart';

import '../../../controllers/MainController.dart';
import '../../../theme/custom_theme.dart';
import '../../../utils/AppConfig.dart';
import '../../../utils/Utils.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  late CustomTheme theme;

  @override
  void initState() {
    super.initState();
    theme = CustomTheme();
  }

  Widget _buildSingleRow(String name, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        FxSpacing.width(20),
        Expanded(
            child: FxText.bodyMedium(
          name,
          fontWeight: 600,
        )),
        FxSpacing.width(20),
        const Icon(
          FeatherIcons.chevronRight,
          size: 20,
        ),
      ],
    );
  }

  final MainController mainController = Get.put(MainController());
  Future<void> myInit() async {
    mainController.init();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: FxText.titleLarge(
          "Settings",
          color: Colors.white,
          maxLines: 2,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: myInit,
        backgroundColor: CustomTheme.primary,
        color: CustomTheme.primary,
        child: ListView(
          padding: FxSpacing.fromLTRB(20, 20, 20, 20),
          children: [
            FxText.bodySmall(
              'Group Account',
              fontWeight: 700,
              letterSpacing: 0.2,
              muted: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(
                  FeatherIcons.users,
                  size: 20,
                ),
                FxSpacing.width(20),
                FxContainer(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        insetPadding: const EdgeInsets.all(30),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: SizedBox(
                          width: 500,
                          child: Padding(
                            padding: const EdgeInsets.all(
                                Dimensions.PADDING_SIZE_LARGE),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.PADDING_SIZE_LARGE),
                                  child: Text(
                                    "LogOut",
                                    textAlign: TextAlign.start,
                                    style: urbanistExtraBold.copyWith(
                                        fontSize: 12,
                                        color: ColorResources.getBlackColor(
                                            context)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_LARGE),
                                  child: Text(
                                    "Are you sure you want to logout?",
                                    style:
                                        urbanistRegular.copyWith(fontSize: 12),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: ColorResources.getSuccessColor(
                                              context)
                                          .withOpacity(.05)),
                                  child: Row(children: [
                                    Icon(
                                      Icons.info,
                                      color: ColorResources.getSuccessColor(
                                          context),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "All unsynced data will be permenently lost",
                                        style: urbanistLight.copyWith(
                                            fontSize: 12,
                                            color: ColorResources.getBlackColor(
                                                context)),
                                      ),
                                    )
                                  ]),
                                ),
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_DEFAULT),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              ColorResources.getHintColor(
                                                      context)
                                                  .withOpacity(.2),
                                          minimumSize: const Size(
                                              Dimensions.WEB_MAX_WIDTH, 50),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL)),
                                        ),
                                        child: Text(
                                          "Cancel",
                                          textAlign: TextAlign.center,
                                          style: urbanistBold.copyWith(
                                              color:
                                                  ColorResources.getHintColor(
                                                      context)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () async {
                                          var connectivityResult =
                                              await (Connectivity()
                                                  .checkConnectivity());
                                          if (connectivityResult ==
                                              ConnectivityResult.none) {
                                            // ignore: use_build_context_synchronously
                                            showCustomSnackBar("No Internet",
                                                context: context);
                                          } else {
                                            do_logout();
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              ColorResources.getRedColor(
                                                  context),
                                          minimumSize: const Size(
                                              Dimensions.WEB_MAX_WIDTH, 50),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL)),
                                        ),
                                        child: Text(
                                          "Proceed",
                                          textAlign: TextAlign.center,
                                          style: urbanistBold.copyWith(
                                              color:
                                                  ColorResources.getWhiteColor(
                                                      context)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_DEFAULT),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  padding: FxSpacing.xy(20, 8),
                  borderRadiusAll: 4,
                  color: CustomTheme.primary,
                  child: FxText.bodySmall(
                    'Log Out',
                    fontWeight: 700,
                    letterSpacing: 0.3,
                    color: CustomTheme.bg_primary_light,
                  ),
                ),
              ],
            ),
            FxSpacing.height(20),
            FxSpacing.height(20),
            FxText.bodySmall(
              'SUPPORT',
              fontWeight: 700,
              letterSpacing: 0.2,
              muted: true,
            ),
            FxSpacing.height(20),
            _buildSingleRow('${AppConfig.APP_NAME} HOTLINE - Toll free',
                FeatherIcons.phone),
            FxSpacing.height(20),
            _buildSingleRow('Important contacts', FeatherIcons.list),
            FxSpacing.height(20),
            InkWell(
                onTap: () {
                  Utils.launchURL("${AppConfig.DASHBOARD_URL}/policy}");
                },
                child: _buildSingleRow('Privacy policy', FeatherIcons.shield)),
            FxSpacing.height(20),
            _buildSingleRow(
                'Report a technical problem', FeatherIcons.alertOctagon),
            FxSpacing.height(20),
            const Divider(
              thickness: 0.8,
            ),
            FxSpacing.height(8),
            FxContainer(
              color: CustomTheme.primary.withAlpha(28),
              borderRadiusAll: 4,
              child: FxText.bodyMedium(
                "© 2023 ${AppConfig.APP_NAME} - All rights reserved.",
                textAlign: TextAlign.center,
                fontWeight: 700,
                letterSpacing: 0.2,
                color: CustomTheme.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> do_logout() async {
    Utils.toast("Logging you out!");
    Utils.logout();
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushNamedAndRemoveUntil(
        context, "/OnBoardingScreen", (r) => false);
  }
}
