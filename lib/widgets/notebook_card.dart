import 'package:flutter/material.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/screens/animal_officer/farms/farm_screen.dart';
import 'package:marcci/utils/color_resources.dart';
import 'package:marcci/utils/dimensions.dart';
import 'package:marcci/utils/styles.dart';
import 'package:marcci/widgets/app_constants.dart';
import 'package:marcci/widgets/fadepageroute.dart'; // Check for correct import path

class NotebookCard extends StatelessWidget {
  final FarmModel farm; // Changed to final as it should not be mutable
  final VoidCallback options; // Changed to final for the same reason

  NotebookCard({Key? key, required this.farm, required this.options})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          FadePageRoute(
            route: (context) => FarmDetailScreen(farm: farm),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
                color: ColorResources.getHintColor(context).withOpacity(.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(255, 0, 66, 3),
                  shape: BoxShape.rectangle),
              child: Icon(Icons.home_filled, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppConstants.capitalize(
                              farm.farmName), // Dynamic data
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: urbanistMedium.copyWith(
                              fontSize: 14,
                              color: ColorResources.getBlackColor(context)),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farm.farmID,
                            overflow: TextOverflow.ellipsis,
                            style: urbanistExtraBold.copyWith(
                              fontSize: 14,
                              color: ColorResources.getBlackColor(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                              onTap: options,
                              child: Container(
                                padding: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: const Color.fromARGB(255, 0, 57, 2),
                                ),
                                child: Icon(
                                  Icons.more_vert,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        farm.farmerName, // Dynamic data
                        overflow: TextOverflow.ellipsis,
                        style: urbanistLight.copyWith(
                          fontSize: 14,
                          color: ColorResources.getHintColor(context),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
