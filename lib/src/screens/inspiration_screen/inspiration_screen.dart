import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/inspiration_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../helpers/helpers.dart';
import '../../models/models.dart';

class InspirationScreen extends StatelessWidget {
  const InspirationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late InspirationController inspirationController =
        Provider.of<InspirationController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (inspirationController.quotesList == null ||
          inspirationController.quotesList!.isEmpty) {
        inspirationController.getQuotes(context);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (val) {
        debugLog("pop value: $val");
        Navigator.pushReplacementNamed(context, Routes.homeScreen);
      },
      child: Scaffold(
        backgroundColor: Colors.purple,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage(MyImage.einstein),
                //   fit: BoxFit.cover,
                //   opacity: 0.05,
                // ),
                ),
            child: Column(
              children: [
                topBarBuild(),
                quoteBuild(inspirationController),
                pageNavIconsBuild(inspirationController),
                30.spaceY
              ],
            ),
          ),
        ),
      ),
    );
  }

  topBarBuild() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<InspirationController>(
          builder: (context, controller, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // appBarIconBuild(
            //     icon: Icons.favorite_border,
            //     onTap: controller.quotesList == null ||
            //             controller.quotesList!.isEmpty
            //         ? null
            //         : () {
            //             print(
            //                 "controller.pageController.page: ${controller.pageController.page}");
            //             print(
            //                 "Quote: ${controller.quotesList![controller.pageController.page!.toInt()]}");
            //           }),
            const SizedBox.shrink(),

            Consumer<SubscriptionController>(
                builder: (context, subscriptionController, child) {
              return Semantics(
                  child: appBarIconBuild(
                      icon: Icons.share_outlined,
                      onTap: controller.quotesList == null ||
                              controller.quotesList!.isEmpty
                          ? null
                          : () async {
                              if (subscriptionController.isSubscribed) {
                                await Share.share(
                                    "${controller.quotesList![controller.pageController.page!.toInt()].quote}");
                              } else {
                                Dialogs.showSubscriptionDialog(
                                    description:
                                        "You need to buy subscription to share quotes. Also, you can save your data on cloud and access it from any where at any time after purchasing monthly subscription",
                                    context: context);
                              }
                            }));
            }),
          ],
        );
      }),
    );
  }

  appBarIconBuild({IconData? icon, Function()? onTap}) {
    return Semantics(
      label: "Share button",
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  quoteBuild(inspirationController) {
    return Expanded(
      child: Consumer<InspirationController>(
          builder: (context, controller, child) {
        return controller.quotesList == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.quotesList!.isEmpty
                ? const Center(
                    child: Text(
                      "Quotes are not available",
                      style: TextStyle(fontSize: 24, color: AppColors.white),
                    ),
                  )
                : FadeInRight(
                    from: 40 * 2,
                    child: PageView.builder(
                      controller: inspirationController.pageController,
                      itemCount: controller.quotesList!.length,
                      itemBuilder: (context, index) {
                        Quote quote = controller.quotesList![index];
                        // return quotePageBuild(quote);
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Stack(
                              children: [
                                Positioned(
                                    top: -2,
                                    child: Image.asset(
                                      AppIcons.startComma,
                                      height: 20,
                                      width: 20,
                                    )),
                                Text(
                                  "  ${quote.quote}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: FontFamily.courgette,
                                    fontWeight: Fonts.medium,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
      }),
    );
  }

  pageNavIconsBuild(inspirationController) {
    Duration duration = const Duration(milliseconds: 900);
    Curve curve = Curves.easeOut;

    return Consumer<InspirationController>(
        builder: (context, controller, child) {
      return controller.quotesList == null || controller.quotesList!.isEmpty
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: "previous quote button",
                  child: moveIconBuild(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () {
                        inspirationController.pageController
                            .previousPage(duration: duration, curve: curve);
                      }),
                ),
                20.spaceX,
                Consumer<SubscriptionController>(
                    builder: (context, subscriptionController, child) {
                  return Semantics(
                    label: "next quote button",
                    child: moveIconBuild(
                        icon: Icons.arrow_forward_ios,
                        onTap: () {
                          if (controller.pageController.page?.toInt() == 2 &&
                              subscriptionController.isSubscribed == false) {
                            Dialogs.showSubscriptionDialog(
                                description:
                                    "You need to buy subscription to view more quotes. Also, you can save your data on cloud and access it from any where at any time after purchasing monthly subscription",
                                context: context);
                          }
                          inspirationController.pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        }),
                  );
                })
              ],
            );
    });
  }

  Widget moveIconBuild({IconData? icon, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.white30)),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
