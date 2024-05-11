import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:tias_tarot/FullScreenModal.dart';
import 'package:tias_tarot/TiasTarotContainer.dart';
import 'package:tias_tarot/TiasTarotReading.dart';

import 'package:audioplayers/audioplayers.dart';

import 'FullScreenModalWidget.dart';
import 'TiasTarotReadingType.dart';
import 'main.dart';

class TiasTarotReadingLongView extends StatefulWidget {
  TiasTarotReading reading;

  TiasTarotReadingLongView({super.key, required this.reading});

  bool sameData(TiasTarotReadingLongView other) {
    return reading.id == other.reading.id;
  }

  @override
  State<StatefulWidget> createState() => TiasTarotReadingLongViewState();
}

class TiasTarotReadingLongViewState extends State<TiasTarotReadingLongView> {
  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    getReadingFromID(widget.reading.id).then((value) {
      if(value == null) return;

      if(value != widget.reading) {
        widget.reading = value;
        setState(() {

        });
      }
    });

    widget.reading.getSelectionData().forEach((element) {
      print(element["Card Name"]);
    });

    List<String> date =
    DateTime.fromMillisecondsSinceEpoch(widget.reading.timeFinished)
        .toString()
        .split(":");
    String dt = "${date[0]}:${date[1]}";

    String name = widget.reading.type.name;

    int columns = 4;
    if (widget.reading.type.deckSize == 6 || widget.reading.type.deckSize == 3) {
      columns = 3;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    //double cardWidth = screenWidth * 0.25;
    //double cardHeight = ((screenWidth * 0.25) * 0.5) * 3.0;

    int rows = (widget.reading.type.deckSize / columns).round();

    ReadingResult readingResult = ReadingResult(reading: widget.reading);

    return SingleChildScrollView(
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(
                left: screenWidth * 0.01, right: screenWidth * 0.01, bottom: 5),
            width: screenWidth * 0.90,
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: bannerUrl,
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
          Center(
            child: Text(widget.reading.type.name, style: const TextStyle(height: 1, fontSize: 24, color: Colors.purple)),
          ),
          Center(
            child: Text(dt, style: const TextStyle(height: 1, fontSize: 10, color: Colors.deepPurpleAccent)),
          ),
          const Padding(padding: EdgeInsets.only(top: 16)),
          const Center(
            child: Text("Deck", style: TextStyle(height: 1, fontSize: 24, color: Colors.yellowAccent)),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            crossAxisCount: columns,
            children: List.generate(widget.reading.type.deckSize, (index) {
              return CardView(
                reading: widget.reading,
                deckIndex: index,
                onSelected: () {
                  readingResult.update();
                },
              );
            }),
          ),
          readingResult
        ]));
  }

}

class ReadingResult extends StatefulWidget {
  TiasTarotReading reading;

  List<int> selected = <int>[];

  ReadingResultState? state;

  ReadingResult({super.key, required this.reading}) {
    selected = reading.getSelected();
  }

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    ReadingResultState result = ReadingResultState();
    state = result;
    return result;
  }

  void update() {
    selected = reading.getSelected();

    // ignore: invalid_use_of_protected_member
    state?.setState(() {});
  }
}

class ReadingResultState extends State<ReadingResult> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: getInstructions(context),
      ),
      const Padding(padding: EdgeInsets.only(top: 25)),
      Center(child: getReadingResult())
    ]);
  }

  getInstructions(BuildContext context) {
    int numberToSelect = widget.reading.type.cardCount;
    int numberOfSelected = widget.selected.length;

    int selectionsLeft = numberToSelect - numberOfSelected;

    String result = "";
    if (selectionsLeft == 1) {
      result = "Select 1 more card";
    } else if (selectionsLeft > 1) {
      result = "Select $selectionsLeft more cards";
    } else {
      if(widget.reading.claimed == false) {
        return
          Padding(padding: const EdgeInsets.only(top:20),
          child: Column( children:[
          const Text("You have a reward available!"),
          ElevatedButton(
            onPressed: onClaimTap(context),
            child: const Text("Claim Reward"))]));
      }
      result = "This reading is finished";
    }

    return Padding(
        padding: const EdgeInsets.only(top: 15), child: Text(result));
  }

  getReadingResult() {
    if(widget.reading.getNumberOfSelected() == 0) return;

    List<Widget> meanings = <Widget>[];

    widget.reading.getSelectionData().forEach((element) {
      MaterialColor color1 = Colors.green;
      MaterialColor color2 = Colors.lightGreen;

      if(element['sign'] == 'fire') {
        color1 = Colors.red;
        color2 = Colors.orange;
      } else if(element['sign'] == 'water') {
        color1 = Colors.blue;
        color2 = Colors.indigo;
      } else if(element['sign'] == 'air') {
        color1 = Colors.cyan;
        color2 = Colors.lightBlue;
      }

      Duration duration = const Duration(seconds: 3);

      meanings.add(
          Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
            Text(element["Card Name"],
              style: TextStyle(
                fontSize: 20,
                color: color2,
              ),
            ),
            Text(element["Meaning"], style: TextStyle(color: color1))
            ])
          )
      );
    });

    return Column(
      children:
      [
        const Padding( padding: EdgeInsets.only(bottom: 20) ,child:Center(child: Text("Reading Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orange),))),
        for (Widget meaning in meanings) meaning
      ],
    );
  }

  onClaimTap(BuildContext context) {
    return () {
      if(widget.reading.claimed == false) {
        playChestClaimedAudio();

        getRewardContainer().then((container) {
          widget.reading.claimed = true;
          widget.reading.rewardID = container.id ?? "";

          widget.reading.saveReading().then((value) {
            showContainerDescription(context, container);
            setState(() {

            });
          });
        });
      }
    };
  }

  void playChestClaimedAudio() {
    var ap = AudioPlayer();
    ap.setVolume(2);

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      ap.play(AssetSource("boxes.wav"), position: const Duration(seconds: 24));
      Future.delayed(const Duration(seconds: 1)).then((value) => ap.stop());
    });
  }

  Future<TiasTarotContainer> getRewardContainer() {
    ItemWeightedRandom<TiasTarotContainerType> containers = ItemWeightedRandom<TiasTarotContainerType>();

    switch(widget.reading.type.name) {
      case "Daily Reading":
        containers.addItem(TiasTarotContainerType.woodenCharmBox, 0.97).
        addItem(TiasTarotContainerType.legendaryCharmBox, 0.03);
        break;
      case "General Reading":
        containers.addItem(TiasTarotContainerType.woodenCharmBox, 0.60).
        addItem(TiasTarotContainerType.ironCharmBox, 0.20).
        addItem(TiasTarotContainerType.silverCharmBox, 0.20);
        break;
      case "Horseshoe Reading":
        containers.addItem(TiasTarotContainerType.woodenCharmBox, 0.60).
        addItem(TiasTarotContainerType.goldCharmBox, 0.20).
        addItem(TiasTarotContainerType.silverCharmBox, 0.20);
        break;
      case "Action Outcome Reading":
        containers.addItem(TiasTarotContainerType.silverCharmBox, 0.60).
        addItem(TiasTarotContainerType.ironCharmBox, 0.35).
        addItem(TiasTarotContainerType.legendaryCharmBox, 0.05);
        break;
    }

    TiasTarotContainerType result = containers.get() ?? TiasTarotContainerType.woodenCharmBox;
    return TiasTarotContainer(type: result).saveContainer();
  }
}

class ItemWeightedRandom<T> {
  Map<T?, double> entries = <T, double>{};
  double accumulatedWeight = 0.0;

  ItemWeightedRandom addItem(T t, double weight) {
    accumulatedWeight += weight;

    entries[t] = accumulatedWeight;

    return this;
  }

  T? get() {
    Random r = Random();
    double roll = r.nextDouble() * accumulatedWeight;

    print(roll);
    print(entries);
    for (var key in entries.keys) {
      if(entries[key]! >= roll) {
        return key;
      }
    }
    return null;
  }
}

class ItemTemplate {
  String name;
  String source;
  int amount;

  ItemTemplate({required this.name, required this.source, required this.amount});
}

class CardView extends StatefulWidget {
  TiasTarotReading reading;
  int deckIndex;

  int cardNumber = 0;

  int uncoverItem = 0;

  Function onSelected;

  bool _selected = false;

  bool get selected => _selected;

  set selected(bool value) {
    onSelected();
    _selected = value;
  }

  String pathRef = "";
  String coverPath = "";

  CardView(
      {super.key,
      required this.reading,
      required this.deckIndex,
      required this.onSelected}) {
    cardNumber = reading.deck[deckIndex]["Card Number"];
    _selected = reading.deck[deckIndex]["Selected"];
    uncoverItem = reading.deck[deckIndex]["Uncover Item"];
  }

  @override
  State<CardView> createState() => CardViewState();
}

class CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.pathRef.isNotEmpty) {
      getCardByNumber(widget.cardNumber, (card) async {
        final filename =
            "${card["Name"].toString().replaceAll("of", "Of").replaceAll(" ", "")} (Phone).png";

        widget.pathRef = await FirebaseStorage.instance
            .refFromURL(
                "gs://tias-tarot-mobile.appspot.com/Images/Cards/Rider Waite/Phone/$filename")
            .getDownloadURL();
        widget.coverPath = await FirebaseStorage.instance
            .refFromURL(
                "gs://tias-tarot-mobile.appspot.com/Images/Cards/Rider Waite/Phone/CoverofTarotCard (Phone).png")
            .getDownloadURL();

        setState(() {});
      });
    }

    return getCardCover();
  }

  Widget getCardCover() {
    if (widget.pathRef.isEmpty) {
      return GestureDetector(
        onTap: onTappedNotLoading,
        child: const Text("Loading"),
      );
    } else {
      if (widget.selected) {
        if (widget.uncoverItem == TiasTarotItemType.key.index) {
          return GestureDetector(
              onTap: onTapped,
              child: Stack(children: [
                Align(
                    child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: widget.pathRef,
                )),
                Align(
                    child: Container(
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl:
                        "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fkey.png?alt=media&token=70bdeaed-f385-4235-98a6-f77852f73467",
                  ),
                )),
              ]));
        } else {
          return GestureDetector(
            onTap: onTapped,
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: widget.pathRef,
            ),
          );
        }
      } else {
        return GestureDetector(
          onTap: onTapped,
          child: CachedNetworkImage(
            placeholder: (context, url) => const CircularProgressIndicator(),
            imageUrl: widget.coverPath,
          ),
        );
      }
    }
  }

  Future<void> onTapped() async {
    if(widget.selected == true) return;

    if(widget.reading.isFinished()) return;

    if(widget.reading.selectionPending == false) {
      widget.reading.selectionPending = true;
      setState(() {

      });
    } else {
      return;
    }

    widget.reading.selectByCardNumber(widget.cardNumber).then((result){
      if (result == true) {
        widget.selected = result;

        if (widget.selected &&
            widget.uncoverItem != TiasTarotItemType.none.index) {
          getCardByNumber(widget.cardNumber, (card) {
            final title = "${card["Name"].toString()} has appeared.";

            if (widget.uncoverItem == TiasTarotItemType.key.index) {
              giveItem("Key", widget.reading.type.name, 1);
              playKeyFoundAudio();
            }

            FullScreenModalWidget modal = FullScreenModalWidget(
                title: title,
                toDisplay: SafeArea( child: Center( child: Column(children: [
                  Text(
                      style: const TextStyle(fontSize: 24),
                      "${card["Name"].toString()} has a gift for you."
                  ),
                  if (widget.uncoverItem == TiasTarotItemType.key.index)
                    Align(
                        child: Container(
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                            imageUrl:
                            "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fkey.png?alt=media&token=70bdeaed-f385-4235-98a6-f77852f73467",
                          ),
                        )),
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child:
                    Center(
                      child:
                      Text(
                          style: TextStyle(fontSize: 24),
                          "The item has been placed in your inventory."
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child:
                    Center(
                      child:
                      Text(
                          style: TextStyle(fontSize: 24),
                          "Return to the main screen to view it."
                      ),
                    ),
                  ),
                ]))
                ));

            Navigator.of(context).push(modal);
          });
        }

        widget.reading.selectionPending = false;
        setState(() {});

        widget.onSelected();
      }
    });
  }

  void onTappedNotLoading() {
    getCardByNumber(widget.cardNumber, (card) {
      print(card);

      final filename =
          "${card["Name"].toString().replaceAll("of", "Of").replaceAll(" ", "")} (Phone).png";

      print(filename);
    });
  }
}
