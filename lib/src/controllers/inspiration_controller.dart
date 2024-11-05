import 'package:flutter/cupertino.dart';
import 'package:mood_maker_kp/src/controllers/subscription_controller.dart';
import 'package:provider/provider.dart';

import '../helpers/helpers.dart';
import '../models/models.dart';

class InspirationController extends ChangeNotifier {
  int selectedIndex = 0;
  List<Quote>? quotesList;

  final PageController pageController = PageController(
    initialPage: 0,
  );

  getQuotes(context) {
    List<Quote> shuffledQuotes = List.from(dummyQuotes)..shuffle();
    final SubscriptionController subscriptionController =
        Provider.of<SubscriptionController>(context, listen: false);
    quotesList = [];
    if (shuffledQuotes.length > 3) {
      if (subscriptionController.isSubscribed == false) {
        for (int i = 0; i < 3; i++) {
          quotesList!.add(shuffledQuotes[i]);
        }
      } else {
        quotesList = shuffledQuotes;
      }
    } else {
      quotesList = shuffledQuotes;
    }
    notifyListeners();
  }
}
