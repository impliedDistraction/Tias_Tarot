import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/FullScreenModalConfirmCrystalPurchase.dart';
import 'package:tias_tarot/TiasTarotReading.dart';
import 'package:tias_tarot/TiasTarotReadingSelection.dart';
import 'package:tias_tarot/TiasTarotSignUpPage.dart';
import 'package:tias_tarot/TiasTarotHomepage.dart';
import 'package:tias_tarot/main.dart';

import 'FullScreenModalTextRequest.dart';
import 'FullScreenModalWidget.dart';
import 'TiasTarotReadingLongView.dart';
import 'TiasTarotReadingType.dart';

class TiasTarotReadingDetailed extends StatefulWidget {
  TiasTarotReadingDetailed({super.key, required this.type});

  final TiasTarotReadingType type;

  @override
  State<TiasTarotReadingDetailed> createState() => _TiasTarotReadingDetailed();
}

class _TiasTarotReadingDetailed extends State<TiasTarotReadingDetailed> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: 15),
              width: screenWidth * 0.90,
              child: CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                imageUrl: widget.type.imageUrl,
              ),
            ),
            Text(
              widget.type.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(widget.type.shortDescription),
            ),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(widget.type.longDescription),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Cost:"),
                Padding(
                    padding: const EdgeInsets.only(left: 40, right: 6),
                    child: Text(widget.type.cost.toString())),
                SizedBox(
                  width: 32,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: crystalUrl,
                  ),
                )
              ],
            ),
            getRewards(),
            const Padding(
              padding: EdgeInsets.only(top: 24),
            ),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Buy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: 15),
              width: screenWidth * 0.90,
              child: CachedNetworkImage(
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                imageUrl: bannerUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  onPressed() {
    TiasTarotReading reading = TiasTarotReading(type: widget.type);
    getValue("Crystal Count").then((value) {
      int count = int.tryParse(value.toString()) ?? 0;

      FullScreenModalConfirmCrystalPurchase modal =
          FullScreenModalConfirmCrystalPurchase(
              title: "Confirm Purchase",
              crystalBalance: count,
              reading: reading);

      modal.setPressedAction((BuildContext context) {
        spendCrystalsOnReading(reading, (purchaseCompleted) {
          if (purchaseCompleted) {
            reading.buildDeck().then((TiasTarotReading value) {
              Navigator.of(context).pop();

              value.saveReading().then((reading) {
                openNewReading(reading);
              });
            });
          } else {
            print("couldn't complete purchase");
          }
        });
      });

      Navigator.of(context).push(modal);
    });
  }

  getRewards() {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(children: [
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Column contents vertically,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Reward(s)"),
            ],
          ),
          if (widget.type.name == "Daily Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: woodenBoxUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("97%")),
              ],
            ),
          if (widget.type.name == "Daily Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: legendaryChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("3%")),
              ],
            ),
          if (widget.type.name == "General Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: woodenBoxUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("60%")),
              ],
            ),
          if (widget.type.name == "General Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: ironChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("20%")),
              ],
            ),
          if (widget.type.name == "General Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: silverChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("20%")),
              ],
            ),
          if (widget.type.name == "Horseshoe Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: ironChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("60%")),
              ],
            ),
          if (widget.type.name == "Horseshoe Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: silverChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("20%")),
              ],
            ),
          if (widget.type.name == "Horseshoe Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: goldChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("20%")),
              ],
            ),
          if (widget.type.name == "Action Outcome Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: silverChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("60%")),
              ],
            ),
          if (widget.type.name == "Action Outcome Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: ironChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("35%")),
              ],
            ),
          if (widget.type.name == "Action Outcome Reading")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    imageUrl: epicChestUrl,
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 40, right: 6),
                    child: Text("5%")),
              ],
            ),
        ]));
  }

  void openNewReading(TiasTarotReading reading) {
    List<String> date =
    DateTime.fromMillisecondsSinceEpoch(reading.timeFinished)
        .toString()
        .split(":");
    String dt = "${date[0]}:${date[1]}";

    String name = reading.type.name;
    TiasTarotReadingLongView lw =
    TiasTarotReadingLongView(reading: reading);

    FullScreenModalWidget modal = FullScreenModalWidget(
        title: "${name}on $dt", toDisplay: lw);

    Navigator.of(context).push(modal);
  }
}
