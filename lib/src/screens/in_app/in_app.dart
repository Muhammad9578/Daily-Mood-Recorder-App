import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:provider/provider.dart';

import '../../controllers/subscription_controller.dart';
import '../../widgets/widgets.dart';

class inApp extends StatefulWidget {
  const inApp({super.key});

  @override
  inAppState createState() => inAppState();
}

class inAppState extends State<inApp> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final String _adsproductID = AppConstants.purchasingProductId; // product id
  bool loading = false;
  User? user;
  bool _available = true;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool canGoBack = true;

  // late FirebaseAnalytics analytics;
  // late FirebaseAnalyticsObserver observer;
  @override
  void initState() {
    print("in initstate");
    user = FirebaseAuth.instance.currentUser;
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    // analytics = FirebaseAnalytics.instance;
    // observer = FirebaseAnalyticsObserver(analytics: analytics);
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print("purchaseDetailsList: $purchaseDetailsList");
      setState(() {
        _purchases.addAll(purchaseDetailsList);
        _listenToPurchaseUpdated(purchaseDetailsList, context);
      });
    }, onDone: () {
      print("purchaseDetailsList: onDone");

      _subscription!.cancel();
    }, onError: (error) {
      print("purchaseDetailsList: $error");

      _subscription!.cancel();
    });
    _initialize();
    super.initState();
  }

  @override
  dispose() async {
    _subscription!.cancel();
    super.dispose();
  }

  void _initialize() async {
    _available = await _inAppPurchase.isAvailable();
    print("purcahses available: $_available");
    List<ProductDetails> products = await _getProducts(
      productIds: <String>{_adsproductID},
    );

    setState(() {
      _products = products;
    });
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList, context) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      debugLog("PurchaseStatus.pending: ${purchaseDetails}");

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugLog("PurchaseStatus.pending");
          //  _showPendingUI();
          break;
        case PurchaseStatus.purchased:
          debugLog('purchased');
          // helper.purchased.value = true;
          // helper.isPurchased.value = true;
          // await helper.afterPurchase(context);
          canGoBack = true;
          loading = false;
          setState(() {});
          makeSubscription(context);

          debugLog('asd rchaseStatus.purch');
          break;
        case PurchaseStatus.restored:
          debugLog("enter aseStatus.restore");

          break;
        case PurchaseStatus.error:
          debugLog(purchaseDetails.error);
          log('rchaseStatus.err :${purchaseDetails.error!.message}');
          canGoBack = true;
          loading = false;
          setState(() {});
          Dialogs.showErrorDialog(
            title: "Failed",
            description:
                "There is some error in purchase. Please try again later",
            context: context,
          );
          if (purchaseDetails.error!.message ==
              'BillingResponse.itemAlreadyOwned') {
            // helper.afterPurchase(context);
          }
          // _handleError(purchaseDetails.error!);
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        loading = false;
        setState(() {});
      }
    });
  }

  makeSubscription(context) async {
    try {
      Dialogs.showLoadingDialog(title: "Please wait ...", context: context);
      SubscriptionController controller =
          Provider.of<SubscriptionController>(context, listen: false);
      bool makeSubscription = await controller.setIsSubscribed(
          true, DateTime.now().millisecondsSinceEpoch);
      if (makeSubscription) {
        // debugLog("Subscribed  now we will cache data from local db to firesto");
        // //   means subscribed, now we will cache data from local db to firestore
        // await trendController.saveBehaviourFromLocalToFirestore(context);
        Navigator.pop(context); // closing dialog
        Dialogs.showSaveDialog(
            title: "Successful",
            description:
                "Successfully subscribed, Now you can enjoy all premier features.",
            context: context,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Navigator.pushNamedAndRemoveUntil(
              //     context, Routes.homeScreen, (route) => false);
            });
        // Navigator.p(context, Routes.homeScreen);
      }
    } catch (e) {
      debugLog("error subscribing: $e");
      Navigator.pop(context);
    }
  }

  Future<List<ProductDetails>> _getProducts(
      {required Set<String> productIds}) async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);
    debugLog("_getProducts: ${response.productDetails}");
    debugLog("_getProducts error: ${response.error}");
    debugLog("_getProducts: notFoundIDs ${response.notFoundIDs}");

    return response.productDetails;
  }

  ListTile _buildPurchase({required PurchaseDetails purchase}) {
    // var pro = Provider.of<get_ads>(context, listen: false);
    print(purchase.status);
    var a;
    if (purchase.error != null) {
      print("urchase.error != nul");
    } else {}

    String? transactionDate;
    if (purchase.status == PurchaseStatus.purchased) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(purchase.transactionDate!),
      );
      transactionDate = ' @ ${DateFormat('yyyy-MM-dd HH:mm:ss').format(date)}';
    }
    return const ListTile(
      title: Text(''),
      subtitle: Text(''),
    );
  }

  Future<void> _subscribe({required ProductDetails product}) async {
    setState(() {
      loading = true;
      canGoBack = false;
    });
    late PurchaseParam purchaseParam;

    purchaseParam = PurchaseParam(productDetails: product);

    // show nuyConsumable after every 30 days to make purchases

    _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam, autoConsume: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canGoBack,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
            ),
          ),
          // title: const Text('Subscription'),
        ),
        body: _available
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      const Text(
                        'Subscriptions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          double h = 400;
                          while (_products.isEmpty) {
                            return const SizedBox(
                                height: 30,
                                width: double.infinity,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ));
                          }
                          if (_products.isEmpty) {
                            return const Text(
                              "An error occured, Please check your gmail account. This happens when you are either no or more than one gmail accounts logged in.",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${_products[index].title}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Text(
                                            _products[index].price,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),

                                      10.spaceY,
                                      Text(
                                        _products[index].description,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      20.spaceY,

                                      loading
                                          ? const SizedBox.shrink()
                                          : SecondaryButton(
                                              index: 2,
                                              icon: AppIcons.creditCard,
                                              text: "Purchase",
                                              onTap: () async {
                                                await _subscribe(
                                                    product: _products[index]);
                                              },
                                            )

                                      // InkWell(
                                      //   onTap: () async {
                                      //     _subscribe(
                                      //         product: _products[index]);
                                      //   },
                                      //   child:
                                      //
                                      //   Container(
                                      //     height: 400,
                                      //     width: 300,
                                      //     decoration: BoxDecoration(
                                      //         color: Colors.brown,
                                      //         borderRadius:
                                      //         BorderRadius.circular(20)),
                                      //     child: const Center(
                                      //       child: Text(
                                      //         'Purchase',
                                      //         style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontSize: 15,
                                      //             fontWeight: FontWeight.bold),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),

                                      // SizedBox(
                                      //   height: 100,
                                      //   width: double.infinity,
                                      //   child: ListTile(
                                      //     leading: const Icon(
                                      //       Icons.credit_card,
                                      //       color: Colors.white,
                                      //     ),
                                      //     title: Text(
                                      //       '${_products[index].title} -\n${_products[index].price}',
                                      //       style: const TextStyle(
                                      //           color: Colors.white),
                                      //     ),
                                      //     subtitle: Text(
                                      //         _products[index].description),
                                      //     trailing: InkWell(
                                      //       onTap: () async {
                                      //         _subscribe(
                                      //             product: _products[index]);
                                      //       },
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: loading,
                      child: const Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      )))
                ],
              )
            : const Center(
                child: Text(
                    'Subscription is currently not available, please try again later'),
              ),
      ),
    );
  }
}
