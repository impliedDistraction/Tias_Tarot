import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/FullScreenModalDateRequest.dart';
import 'package:tias_tarot/FullScreenModalTextRequest.dart';
import 'package:tias_tarot/TiasTarotLoginPage.dart';
import 'package:tias_tarot/TiasTarotReading.dart';
import 'package:tias_tarot/TiasTarotReadingType.dart';
import 'package:tias_tarot/TiasTarotReadingShortView.dart';
import 'package:tias_tarot/TiasTarotUserInfo.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:age_calculator/age_calculator.dart';

import 'TiasTarotReadingDetailed.dart';
import 'main.dart';

class TiasTarotReadingSelection extends StatefulWidget {
  TiasTarotReadingSelection({super.key, required this.title});

  final String title;

  List<TiasTarotReadingShortView> readings = <TiasTarotReadingShortView>[];

  @override
  State<TiasTarotReadingSelection> createState() =>
      _TiasTarotReadingSelectionState();
}

class _TiasTarotReadingSelectionState extends State<TiasTarotReadingSelection> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> post;

  CachedNetworkImage oneCard = CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2FTias%20Tarot%20Reading%20Select-1.png?alt=media&token=105ceb95-e642-4995-b393-89239130e9d3");
  CachedNetworkImage threeCards = CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2FTias%20Tarot%20Reading%20Select%20General-1.png?alt=media&token=552315b3-6840-4a0b-a187-73db098da8c5");
  CachedNetworkImage horseshoeCards = CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2FTias%20Tarot%20Reading%20Select%20Horseshoe-1.png?alt=media&token=dc0bdf0d-56a1-45c6-bb42-33f2c8b77a57");
  CachedNetworkImage actionCards = CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2FTias%20Tarot%20Reading%20Select%20Action%20Outcome-1.png?alt=media&token=05ab4ebb-1196-41d1-9341-adff5c0b9c33");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: FocusDetector(
        onFocusLost: () {},
        onFocusGained: () {
          updateReadings();
        },
        onVisibilityLost: () {},
        onVisibilityGained: () {
          updateReadings();
        },
        onForegroundLost: () {},
        onForegroundGained: () {
          updateReadings();
        },
        child: PageView(scrollDirection: Axis.vertical, children: [
          PageView(
            scrollDirection: Axis.horizontal,
            children: [
              TiasTarotReadingSelect(
                  title: "Daily Reading",
                  image: oneCard,
                  about:
                      "A one card reading like a horoscope that gives you guidance for the day ahead."),
              TiasTarotReadingSelect(
                  title: "General Reading",
                  image: threeCards,
                  about:
                      "A three card tarot reading involves drawing three cards from the tarot deck and interpreting their meanings in relation to a specific question or situation. \n\nThe first card represents the past and provides insight into past influences that may be affecting the present. The second card represents the present and offers insight into current energies and influences that are at play. \n\nThe third and final card represents the future and offers guidance and potential outcomes based on current trends and energies. Together, these three cards offer a holistic view of the situation and can provide valuable insights and guidance for decision-making and personal growth."),
              TiasTarotReadingSelect(
                  title: "Horseshoe Reading",
                  image: horseshoeCards,
                  about:
                      "A five card tarot reading is a versatile spread that provides a detailed and nuanced analysis of a situation or question. The first card represents the current situation or the question at hand. The second card represents the challenges or obstacles that may be present. The third card represents the subconscious or underlying influences at play. \n\nThe fourth card represents the advice or guidance of the tarot, providing potential solutions or a path forward. The fifth and final card represents the potential outcome based on current trends and energies. \n\nTogether, these five cards offer a comprehensive and detailed analysis of the situation and can provide valuable insights and guidance for decision-making and personal growth."),
              TiasTarotReadingSelect(
                  title: "Action -- Outcome Reading",
                  image: actionCards,
                  about:
                      "An action outcome tarot reading is a two-card spread that provides insight into a specific action or decision and its potential outcome. The first card represents the action or decision being considered, while the second card represents the likely outcome based on that action or decision. Together, these two cards offer guidance and insight into the potential consequences of the chosen course of action. \n\nThis type of reading can be helpful in making important decisions or weighing the pros and cons of different options.")
            ],
          ),
          SafeArea(
            child: Stack(children: [
              PageView(
                  scrollDirection: Axis.horizontal,
                  children: [for (var view in widget.readings) view]),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text('Scroll left / right for more or down to go back'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void updateReadings() {
    var collection = FirebaseFirestore.instance.collection('cardReadings');
    post = collection.where("Email", isEqualTo: currentUser?.email).snapshots();

    bool foundNew = false;
    post.listen((event) {
      for (var readingData in event.docs) {
        TiasTarotReading reading = getReadingFromData(readingData.data());
        TiasTarotReadingShortView view =
            TiasTarotReadingShortView(reading: reading);

        bool found = false;
        for (var element in widget.readings) {
          if (element.sameData(view)) found = true;
        }

        if (!found) {
          widget.readings.add(view);
          foundNew = true;
        }
      }

      if (foundNew && mounted) {
        sortReadings();
        setState(() {});
      }
    });
  }

  sortReadings() {
    widget.readings.sort((e1, e2) => e2.reading.timeFinished.compareTo(e1.reading.timeFinished));
  }
}

class TiasTarotReadingSelect extends StatelessWidget {
  final String title;
  final String about;
  final CachedNetworkImage image;

  const TiasTarotReadingSelect({
    super.key,
    required this.title,
    required this.image,
    required this.about,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1000),
        builder: buildAnimation,
        curve: Curves.bounceInOut,
        child: SafeArea(
          child: Stack(children: [
            Column(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: banner2Url,
                ),
                image,
                ElevatedButton(
                    onPressed: onTap(context),
                    child: const Text("Learn more")),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Text('Scroll left, right, or up for more options'),
            )
          ]),
        ));
  }

  void getReadingSelectInfo() {}

  Widget buildAnimation(BuildContext context, double value, Widget? child) {
    return Opacity(
      opacity: value,
      child: Padding(
        padding: EdgeInsets.only(top: value * 20),
        child: child,
      ),
    );
  }

  onAboutPressedFunction(BuildContext context) {
    return () {
      FullScreenModal dialog = FullScreenModal(
          title: "About $title", description: about, showButton: true);

      Navigator.of(context).push(dialog);
    };
  }

  Null Function() onTap(BuildContext context) {
    return () {
      TiasTarotReadingType type =
          TiasTarotReadingTypeHelpers().getByName(title);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TiasTarotReadingDetailed(type: type)),
      );
    };
  }
}
