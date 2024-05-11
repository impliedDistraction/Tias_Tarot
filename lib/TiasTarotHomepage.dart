import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/FullScreenModalDateRequest.dart';
import 'package:tias_tarot/FullScreenModalTextRequest.dart';
import 'package:tias_tarot/FullScreenModalWidget.dart';
import 'package:tias_tarot/InventoryView.dart';
import 'package:tias_tarot/TiasTarotLoginPage.dart';
import 'package:tias_tarot/TiasTarotReadingSelection.dart';
import 'package:tias_tarot/TiasTarotSendMessage.dart';
import 'package:tias_tarot/TiasTarotUserInfo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:age_calculator/age_calculator.dart';

import 'main.dart';

class TiasTarotHomepage extends StatefulWidget {
  TiasTarotHomepage({super.key, required this.title});

  final String title;

  String userProfileURL = defaultProfileIconURL;
  String userDisplayName = "No name set yet";

  int crystalCount = 0;

  @override
  State<TiasTarotHomepage> createState() => _TiasTarotHomepageState();
}

class _TiasTarotHomepageState extends State<TiasTarotHomepage> {
  final _description =
      """Tarot reading is a divination practice that uses a deck of 78 cards with symbolic images to gain insight into a person's life and future. The deck is divided into two parts: the Major Arcana, which consists of 22 cards that represent significant life events and archetypes, and the Minor Arcana, which is divided into four suits (Cups, Swords, Wands, and Pentacles) and represents everyday situations and events.\n\nIn a tarot reading, the reader shuffles the cards and lays them out in a specific pattern, or spread, and interprets the cards' meanings based on their position in the spread and their relationship to each other. The reader may ask the person being read for guidance or clarification on certain aspects of their life to help guide the interpretation. \n\nTarot readings are often used to gain insight into relationships, career paths, personal growth, and spiritual matters. While some people believe that the cards have inherent mystical properties, others view them as a tool for self-reflection and exploration.""";

  void getUserProfileInfo() {
    getUserProfileImageURL((String result) {
      if (result != widget.userProfileURL) {
        widget.userProfileURL = result;
        setState(() {});
      }
    });
    getUserProfileDisplayName((String result) {
      if (result != widget.userDisplayName) {
        widget.userDisplayName = result;
        setState(() {});
      }
    });
  }

  Function() onSendMessageButtonPressed(BuildContext context) {
    return () {
      if (isUserNull()) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TiasTarotLoginPage(title: "Login")),
        );
        return;
      }

      onFinished(result) async {
        var collection = FirebaseFirestore.instance.collection('messages');

        var options = {
          "Email": currentUser?.email,
          "Time Sent": DateTime.now().millisecondsSinceEpoch,
          "Message": result,
          "Reply ID": "None",
        };

        await collection.add(options);
      }

      TiasTarotSendMessage modal = TiasTarotSendMessage(
          title: "Send Message",
          description: "We will get back to you as soon as possible.",
          showButton: true,
          validate: (result) => true,
          errorMessage: "The message could not be sent as typed.",
          onFinished: onFinished);

      Navigator.of(context).push(modal);
    };
  }

  void onGetReadingPressed() {
    if (isUserNull()) {
      print('request login');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TiasTarotLoginPage(title: "Login")),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TiasTarotReadingSelection(title: "Tarot Readings")),
      );
    }
  }

  void onReviewButtonPressed() {
    """
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? 'YOUR_ANDROID_PACKAGE_ID' : 'YOUR_IOS_APP_ID';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=\$appId"
            : "https://apps.apple.com/app/id\$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
    """;
  }

  Future<void> onSeeWebsiteButtonPressed() async {
    const url = 'https://tiastarot.com';
    final uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  void onShareButtonPressed() {
    Share.share('check out the new mobile app from https://tiastarot.com',
        subject: 'Exciting new tarot app!');
  }

  onInventoryButtonPressed(BuildContext context) {
    return () {
      if (isUserNull()) {
        print('request login');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TiasTarotLoginPage(title: "Login")),
        );
      } else {
        InventoryView iv = InventoryView();

        Navigator.of(context).push(iv);
      }
    };
  }

  @override
  void initState() {
    super.initState();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => onWidgetBuild());
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserProfileInfo();
    getCardsRef((result) {});

    getValue("Crystal Count").then((value) {
      int count = int.tryParse(value.toString()) ?? 0;

      if (widget.crystalCount != count) {
        widget.crystalCount = count;
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FocusDetector(
          onFocusLost: () {},
          onFocusGained: () {},
          onVisibilityLost: () {},
          onVisibilityGained: () {
            getValue("Crystal Count").then((value) {
              if (value != null) {
                int? count = int.tryParse(value.toString());
                if (count != null) {
                  if (widget.crystalCount != count) {
                    widget.crystalCount = count;
                    setState(() {});
                  }
                }
              }
            });
          },
          onForegroundLost: () {},
          onForegroundGained: () {},
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: (16)),
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl:
                        "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Ftia.jpeg?alt=media&token=986664f0-5bdd-43e0-a594-7c94f5cbce0d",
                  ),
                ),
                if (!isUserNull())
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Image(
                              image: NetworkImage(widget.userProfileURL),
                              width: 32,
                              height: 32,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              widget.userDisplayName,
                            ),
                          ),
                          const Expanded(child: Spacer()),
                          IconButton(
                            onPressed: () {
                              signOut(() {
                                setState(() {});
                              });
                            },
                            icon: const Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () {
                              signOut(() {
                                setState(() {});
                              });
                            },
                            icon: const Icon(Icons.logout),
                          ),
                        ],
                      )),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        flex: 70,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tarot Reading for Guidance",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Spiritual Guidance and Affirmation",
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 30,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: (0), right: 8),
                              child: SizedBox(
                                  width: 32,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    imageUrl: crystalUrl,
                                  )),
                            ),
                            Text(
                              widget.crystalCount.toString(),
                              textAlign: TextAlign.end,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // buttons and CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: onGetReadingPressed,
                                        iconSize: 32.0,
                                        icon: const Icon(Icons.note_add),
                                        color: Theme.of(context).primaryColor,
                                        tooltip:
                                            'Get a personal tarot reading.',
                                      ),
                                      Text(
                                        'Tarot Reading',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: onSeeWebsiteButtonPressed,
                                        iconSize: 32.0,
                                        icon: const Icon(Icons.open_in_browser),
                                        color: Theme.of(context).primaryColor,
                                        tooltip:
                                            'Visit TiasTarot.com to learn more',
                                      ),
                                      Text(
                                        'Website',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: onShareButtonPressed,
                                        iconSize: 32.0,
                                        icon: const Icon(Icons.share),
                                        color: Theme.of(context).primaryColor,
                                        tooltip: 'Tell others.',
                                      ),
                                      Text(
                                        'Share',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        child:
                                        SizedBox(
                                          width: 32,
                                          child:
                                          CachedNetworkImage(
                                              placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                              imageUrl:
                                              "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fmagic.png?alt=media&token=fb0fdfce-bfc3-4330-865f-d96d04f10f1f"
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Magic',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        child:
                                        SizedBox(
                                          width: 32,
                                          child:
                                          CachedNetworkImage(
                                              placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                              imageUrl:
                                              "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fvoodoo.png?alt=media&token=327a631e-a5b2-41fb-b035-74dc4af3bfef"
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Voodoo',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: onInventoryButtonPressed(context),
                                        child:
                                          SizedBox(
                                            width: 32,
                                            child:
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                              imageUrl:
                                              "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Finventory.png?alt=media&token=76c0c0cd-c6b8-44ad-a0f6-8612bf508dce"
                                            ),
                                          ),
                                      ),
                                      Text(
                                        'Inventory',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _description,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onSendMessageButtonPressed(context),
        tooltip: 'Increment',
        child: const Icon(Icons.mail),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  addToDatabaseIfNotFound(
      CollectionReference<TiasTarotUserInfo> ref, User? currentUser) {
    print("add");

    FullScreenModalTextRequest modal = FullScreenModalTextRequest(
      title: "Display Name",
      description: "What name should other's see?",
      showButton: true,
      validate: (String text) {
        if (text.length < 3) return false;
        return true;
      },
      errorMessage: "That name is too short.",
      onFinished: (String displayName) {
        FullScreenModalDateRequest modal = FullScreenModalDateRequest(
          title: "Date of Birth",
          description: "Enter your date of birth",
          showButton: true,
          validate: (DateTime birthday) {
            DateDuration duration = AgeCalculator.age(birthday);

            if (duration.years < 13) return false;

            return true;
          },
          errorMessage: "That birthday is invalid! This app is for 13+",
          onFinished: (DateTime value) {
            getCurrentUser((docs) {
              print(docs);
            }, (CollectionReference<TiasTarotUserInfo> ref, User? user) {
              ref
                  .add(TiasTarotUserInfo(
                    dateOfBirth: value.millisecondsSinceEpoch,
                    displayName: displayName,
                    profilePictureURL: defaultProfileIconURL,
                    email: user!.email,
                    userID: user.uid,
                    crystalCount: 0,
                    crystalsPurchased: 0,
                    logins: <dynamic>[DateTime.now().millisecondsSinceEpoch],
                    longestLoginStreak: 0,
                    readingCount: 0,
                    generalReadingCount: 0,
                    horseshoeReadingCount: 0,
                    actionOutcomeReadingCount: 0,
                    dailyReadingCount: 0,
                    yesNoReadingCount: 0,
                    tiktokFollow: false,
                    youtubeFollow: false,
                    intuition: 0,
                  ))
                  .then((value) => print("user added"))
                  .catchError(
                      (error) => print("Failed to add user info: $error"));
            });
          },
        );

        Navigator.of(context).push(modal);
      },
    );

    Navigator.of(context).push(modal);
  }

  onWidgetBuild() {
    print("here");
  }

  onMagicPressed(BuildContext context) {
    return () {
      //FullScreenModalWidget modal = FullScreenModalWidget(title: "Open Crate", toDisplay: toDisplay)
    };    
  }
}
