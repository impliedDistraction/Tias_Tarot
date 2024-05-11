import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tias_tarot/TiasTarotReadingType.dart';
import 'package:uuid/uuid.dart';

import 'TiasTarotContainer.dart';
import 'TiasTarotReadingType.dart';
import 'main.dart';

TiasTarotReading getReadingFromData(data) {
  TiasTarotReadingType type = TiasTarotReadingTypeHelpers().getByName(data["Item Purchased"]);

  TiasTarotReading result = TiasTarotReading(type: type);
  result.id = data["Reading ID"];
  result.question = data['Question'] ?? "";
  result.timeFinished = data["Time Spent"] ?? 0;
  result.deck = data["Deck"];
  result.insightsUnlocked = data["Insights Unlocked"];
  result.claimed = data["Reward Claimed"] ?? false;
  result.rewardID = data["Reward ID"] ?? "";
  result.sign = data['sign'] ?? "unknown";
  return result;
}

Future<TiasTarotReading?> getReadingFromID(String? id) async {
  var collection = FirebaseFirestore.instance.collection('cardReadings');

  return await collection.where("Reading ID", isEqualTo: id).limit(1).get().then((value)
  {
    if(value.docs.length == 1) {
      var result = getReadingFromData(value.docs[0].data());

      return result;
    }
  });
}
 
class TiasTarotReading {
  String? id;
  TiasTarotReadingType type;

  String question="";
  int timeFinished = 0;
  int insightsUnlocked = 0;
  bool claimed = false;
  String rewardID = "";
  String sign = "";

  bool selectionPending = false;

  List<dynamic> deck = <dynamic>[];

  @override
  bool operator ==(Object other) =>
      other is TiasTarotReading &&
          other.id == id &&
          other.getNumberOfSelected() == getNumberOfSelected();

  @override
  int get hashCode => id.hashCode + getNumberOfSelected().hashCode;

  TiasTarotReading({required this.type}) {
    var generator = Uuid();
    id = generator.v4();
  }

  Future<TiasTarotReading> buildDeck() async {
    var cardNumbers = getRandomDraw(type.deckSize);

    Random r = Random();

    for (var element in cardNumbers) {
      getCardByNumber(element, (card)
      {
        bool reversed = isCardReversed();

        List<String> meanings = getThreeRandomCardMeanings(card, reversed);

        TiasTarotItemType uncoverItem = TiasTarotItemType.none;
        if(r.nextInt(100) < 15) {
          uncoverItem = TiasTarotItemType.key;
        }
        print(card["sign"]);

        deck.add({
          "Card Name": card["Name"],
          "sign" : card["sign"],
          "Card Number": element,
          "Selected": false,
          'Is Reversed': reversed,
          'Yes, No, or Maybe': isCardYesNoOrMaybe(card, reversed),
          'Meaning': meanings[0],
          'Meaning 2': meanings[1],
          'Meaning 3': meanings[2],
          "Uncover Item" : uncoverItem.index,
        });
      });
    }


    return this;
  }

  bool isFinished() {
    return type.cardCount == getNumberOfSelected();
  }

  int getNumberOfSelected() {
    int count = 0;

    for (var element in deck) {
      if(element["Selected"]) count++;
    }

    return count;
  }

  Future<bool> selectByCardNumber(int number) async {
    if(isFinished()) return false;

    for(var value in deck) {
      if(value["Card Number"] == number) {
        value["Selected"] = true;
        await saveReading();
        return true;
      }
    }

    return false;
  }

  List<int> getSelected() {
    List<int> result = <int>[];

    for (var value in deck) {
      if(value["Selected"]) {
        result.add(value["Card Number"]);
      }
    }

    return result;
  }

  List<dynamic> getSelectionData() {
    List<dynamic> result = <dynamic>[];
    for(var value in deck) {
      if(value["Selected"]) {
        result.add(value);
      }
    }
    return result;
  }

  Future<TiasTarotReading> saveReading() async {
    var collection = FirebaseFirestore.instance.collection('cardReadings');

    await collection.where("Reading ID", isEqualTo: id).limit(1).get().then((value)  async {
      var options = {
        "Email": currentUser?.email,
        "Crystals Spent": type.cost,
        "Item Purchased": type.name,
        "Reading ID": id,
        "Time Spent": DateTime.now().millisecondsSinceEpoch,
        "Deck" : deck,
        "Is Finished": isFinished(),
        "Question": question,
        "Insights Unlocked": insightsUnlocked,
        "Reward Claimed" : claimed,
        "Reward ID": rewardID,
      };

      try {
        await value.docs.first.reference.set(options);
      } catch(e) {
        await collection.add(options);
      }
    });

    return this;
  }

  Future<bool> confirmSaveReading() async {
    var result = await saveReading();

    var collection = FirebaseFirestore.instance.collection('cardReadings');
    var data = await collection.where("Reading ID", isEqualTo: id).limit(1).get();

    print(data);

    return true;
  }

}