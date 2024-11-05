import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/subscription_controller.dart';
import 'package:mood_maker_kp/src/controllers/trends_controller.dart';
import 'package:mood_maker_kp/src/models/behaviour_history.dart';
import 'package:mood_maker_kp/src/models/behaviours.dart';
import 'package:mood_maker_kp/src/repository/firestore_repository.dart';
import 'package:mood_maker_kp/src/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../helpers/helpers.dart';
import 'components/display_mood_chart_build.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  bool isLoading = true;
  bool isError = false;
  List<BehaviourHistory>? behaviourHistory;
  late TrendController trendController;
  late SubscriptionController subscriptionController;
  Map<String, List<BehaviourHistory>>? finalList;
  ScreenshotController screenshotController = ScreenshotController();

  getData() async {
    try {
      behaviourHistory =
          await trendController.getBehaviourHistory(subscriptionController);
      if (behaviourHistory != null && behaviourHistory!.isNotEmpty) {
        finalList = getBehaviourHistoryGroupedByDate(behaviourHistory!);
      }

      isLoading = false;
      setState(() {});
    } catch (e) {
      isError = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    trendController = Provider.of<TrendController>(context, listen: false);
    subscriptionController =
        Provider.of<SubscriptionController>(context, listen: false);

    getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(color: AppColors.white),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              semanticLabel: "Back",
              color: AppColors.white,
            ),
          );
        }),
        actions: [
          IconButton(
              onPressed: () async {
                try {
                  Dialogs.showLoadingDialog(
                      title: "Uploading data to cloud...", context: context);

                  await getIt.get<FireStoreRepository>().deleteCollection();

                  await trendController
                      .saveBehaviourFromLocalToFirestore(context);
                  Navigator.pop(context); // closing dialog
                  Dialogs.showSaveDialog(
                      title: "Uploaded",
                      description:
                          "Data successfully uploaded to cloud. Now you can access it anywhere from anytime.",
                      context: context,
                      onTap: () {
                        Navigator.pop(context);
                      });
                } catch (e) {
                  Navigator.pop(context);
                  debugLog("Error is generating pdf: $e");
                  Toasty.error("Some error occurred. Try again later");
                }
                // Share.shareFiles([pth], text: 'Behaviour History Data');
              },
              icon: const Icon(
                Icons.cloud_upload_outlined,
                semanticLabel: "Upload data to cloud",
                color: AppColors.white,
              )),
          IconButton(
              onPressed: () async {
                try {
                  if (finalList != null && finalList!.isNotEmpty) {
                    Dialogs.showLoadingDialog(
                        title: "Generating file...", context: context);

                    Uint8List? capturedImage =
                        await screenshotController.capture();

                    File pth =
                        await createAndSharePdf(finalList!, capturedImage);

                    Navigator.pop(context);

                    Share.shareXFiles([XFile(pth.path)], text: 'Mood History');
                  } else {
                    Toasty.error("There is no history to share.");
                  }
                } catch (e) {
                  debugLog("Error is generating pdf: $e");
                  Toasty.error("Some error occurred. Try again later");
                }
                // Share.shareFiles([pth], text: 'Behaviour History Data');
              },
              icon: Icon(
                Icons.share,
                semanticLabel: "share",
                color: AppColors.white,
              )),
        ],
      ),
      // drawer: DrawerBuild(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(
                  child: Text("There is some problem in fetching data"))
              : trendBuild(behaviourHistory),
    );
  }

  Widget trendBuild(List<BehaviourHistory>? behaviourHistory) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Container(
      // alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: behaviourHistory == null || behaviourHistory!.isEmpty
          ? const Center(
              child: Text(
                "No history found",
                style: TextStyle(color: AppColors.white),
              ),
            )
          : Screenshot(
              controller: screenshotController,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    5.spaceY,
                    // capturedImage != null
                    //     ? Image.memory(
                    //   capturedImage!,
                    //   height: 200,
                    //   width: 200,
                    // )
                    //     : Text("no image"),
                    Text(
                      "Mood history of past 7 days",
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.white,
                          fontWeight: Fonts.medium),
                    ),
                    5.spaceY,
                    keyMapBuild(h, w),
                    20.spaceY,
                    SizedBox(
                        height: h * 0.5,
                        child:
                            DisplayMoodChartBuild(behaviourList: finalList!)),
                    20.spaceY,
                  ],
                ),
              ),
            ),
    );
  }

  keyMapBuild(h, w) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: w * 0.7,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            // color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.white)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (Behaviour bh in dummyMoods)
            keymapRowBuild(
                text: bh.text!, emoji: bh.emoji!, color: bh.moodGraphColor),
        ]),
      ),
    );
  }

  keymapRowBuild({
    required String text,
    required String emoji,
    required color,
  }) {
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$emoji",
            style: const TextStyle(color: AppColors.white, fontSize: 18),
          ),
          3.spaceX,
          Expanded(
              child: Text(
            "$text",
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          )),
          5.spaceX,
          Expanded(
            child: Container(
              width: 50,
              height: 3,
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
