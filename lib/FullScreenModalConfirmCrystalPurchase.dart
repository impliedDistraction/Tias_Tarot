// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/TiasTarotReading.dart';

import 'TiasTarotUserInfo.dart';
import 'main.dart';

class FullScreenModalConfirmCrystalPurchase extends ModalRoute {
  // variables passed from the parent widget
  String title;
  TiasTarotReading reading;

  int crystalBalance;

  Function? _pressedAction;

  // constructor
  FullScreenModalConfirmCrystalPurchase({
    required this.title,
    required this.crystalBalance,
    required this.reading,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.80);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child:
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 40.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child:
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child:
                CachedNetworkImage(
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  imageUrl: reading.type.imageUrl,
                ),
              )
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Balance:"),
                Padding(
                    padding: const EdgeInsets.only(left: 40, right: 6),
                    child:
                    Text(crystalBalance.toString())
                ),
                SizedBox(
                  width: 32,
                  child:
                  CachedNetworkImage(
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    imageUrl: crystalUrl,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Cost:"),
                Padding(
                    padding: const EdgeInsets.only(left: 40, right: 6),
                    child:
                    Text(reading.type.cost.toString())
                ),
                SizedBox(
                  width: 32,
                  child:
                  CachedNetworkImage(
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    imageUrl: crystalUrl,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: usePressedAction(context),
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                goBack(context);
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            )
          ],
        ),
      ),
    );
  }


  void goBack(BuildContext context) {
    Navigator.pop(context, []);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        // add scale animation
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }

  setPressedAction(Function fun) {
    _pressedAction = fun;
  }

  usePressedAction(BuildContext context) {
    return () {
      if (_pressedAction != null) {
        _pressedAction!(context);
      } else {
        // close the modal dialog and return some data if needed
        Navigator.pop(context, []);
      }
    };
  }
}