// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/TiasTarotReading.dart';

import 'InventoryView.dart';
import 'TiasTarotUserInfo.dart';
import 'main.dart';

class FullScreenModalConfirmKeyUse extends ModalRoute {
  // variables passed from the parent widget
  String title;
  String type;

  int keyBalance;

  // constructor
  FullScreenModalConfirmKeyUse({
    required this.title,
    required this.type,
    required this.keyBalance
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
                style: TextStyle(color: getItemColorByName(type), fontSize: 40.0),
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
                    imageUrl: getItemUrlFromName(type),
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
                    Text(keyBalance.toString())
                ),
                SizedBox(
                  width: 32,
                  child:
                  CachedNetworkImage(
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    imageUrl: getItemUrlFromName("key"),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Cost:"),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child:
                    Text("1")
                ),
                SizedBox(
                  width: 32,
                  child:
                  CachedNetworkImage(
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    imageUrl: getItemUrlFromName("key"),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: takeKeyFromPlayerThenOpenContainer(context),
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

    openInventory(context);
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

  openInventory(BuildContext context) {
    InventoryView iv = InventoryView();

    Navigator.of(context).push(iv);
  }

  takeKeyFromPlayerThenOpenContainer(BuildContext context) {
    return () {
      Navigator.of(context).pop();

      if(keyBalance >= 1) {
        removeKey().then((value) {

          removeContainer(type).then((value) {

            openInventory(context);
          });

        });
      }
    };
  }
}