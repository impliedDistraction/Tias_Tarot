import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';

enum TiasTarotContainerType {
  unknown, woodenCharmBox, ironCharmBox, silverCharmBox, goldCharmBox, epicCharmBox, legendaryCharmBox
}

enum Rarity {
  normal, rare, epic, legendary
}

enum TiasTarotItemType {
  none,
  crystals,
  key,
  twoKeys,
  threeKeys,
  ingredient,
  twoIngredients,
  threeIngredients,
  spell,
  candle,
  doll,
  box,
}

class TiasTarorContainerTypeHelper {
  static List<dynamic> getRewardTypes(TiasTarotContainerType type) {
    switch(type) {
      case TiasTarotContainerType.ironCharmBox:
        return getIronRewardTypes();
      case TiasTarotContainerType.silverCharmBox:
        return getSilverRewardTypes();
      case TiasTarotContainerType.goldCharmBox:
        return getGoldRewardTypes();
      case TiasTarotContainerType.epicCharmBox:
        return getEpicRewardTypes();
      case TiasTarotContainerType.legendaryCharmBox:
        return getLegendaryRewardTypes();
      default:
        return getWoodenRewardTypes();
    }
  }

  static String getName(TiasTarotContainerType type) {
    switch(type) {
      case TiasTarotContainerType.woodenCharmBox:
        return "Wooden Charm Box";
      case TiasTarotContainerType.silverCharmBox:
        return "Silver Charm Box";
      case TiasTarotContainerType.ironCharmBox:
        return "Iron Charm Box";
      case TiasTarotContainerType.goldCharmBox:
        return "Gold Charm Box";
      case TiasTarotContainerType.epicCharmBox:
        return "Epic Charm Box";
      case TiasTarotContainerType.legendaryCharmBox:
        return "Legendary Charm Box";
      default:
        return "Unknown Charm Box";
    }
  }

  static TiasTarotContainerType getTypeFromName(String name) {
    if(name.contains(getName(TiasTarotContainerType.woodenCharmBox))) {
      return TiasTarotContainerType.woodenCharmBox;
    } else if(name.contains(getName(TiasTarotContainerType.silverCharmBox))) {
      return TiasTarotContainerType.silverCharmBox;
    } else if(name.contains(getName(TiasTarotContainerType.ironCharmBox))) {
      return TiasTarotContainerType.ironCharmBox;
    } else if(name.contains(getName(TiasTarotContainerType.goldCharmBox))) {
      return TiasTarotContainerType.goldCharmBox;
    } else if(name.contains(getName(TiasTarotContainerType.epicCharmBox))) {
      return TiasTarotContainerType.epicCharmBox;
    } else if(name.contains(getName(TiasTarotContainerType.legendaryCharmBox))) {
      return TiasTarotContainerType.legendaryCharmBox;
    }
    return TiasTarotContainerType.unknown;
  }

  static List getWoodenRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 35, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 45, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 55, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 200, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.rare);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.rare);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.rare);

    addReward(result, TiasTarotItemType.spell, 1, Rarity.legendary);

    return result;
  }

  static List getIronRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 10, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 35, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 45, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 55, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 200, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.legendary);

    return result;
  }

  static List getSilverRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 100, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 200, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 400, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.legendary);

    return result;
  }

  static List getGoldRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 700, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 1000, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.epic);

    return result;
  }

  static List getEpicRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 700, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 1000, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.epic);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.legendary);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.epic);

    return result;
  }

  static List getLegendaryRewardTypes() {
    List<dynamic> result = <dynamic>[];

    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 300, Rarity.normal);


    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 500, Rarity.normal);
    addReward(result, TiasTarotItemType.crystals, 700, Rarity.rare);

    addReward(result, TiasTarotItemType.crystals, 1000, Rarity.epic);

    addReward(result, TiasTarotItemType.key, 1, Rarity.rare);
    addReward(result, TiasTarotItemType.twoKeys, 1, Rarity.rare);
    addReward(result, TiasTarotItemType.candle, 1, Rarity.rare);

    addReward(result, TiasTarotItemType.spell, 1, Rarity.legendary);

    return result;
  }

  static void addReward(List result, TiasTarotItemType type, int i, Rarity r) {
    result.add({
      "Type" : type.name,
      "Amount" : i,
      "Rarity" : r.name
    });
  }
}

class TiasTarotContainer {
  String? id;
  TiasTarotContainerType type;

  String name = "unknown";

  bool listed = false;

  bool claimed = false;

  List<dynamic> rewards = <dynamic>[];

  TiasTarotContainer({required this.type}) {
    var generator = const Uuid();
    id = generator.v4();

    name = TiasTarorContainerTypeHelper.getName(type);
    rewards = TiasTarorContainerTypeHelper.getRewardTypes(type);
  }

  Future<TiasTarotContainer> saveContainer() async {
    var collection = FirebaseFirestore.instance.collection('containers');

    await collection.where("Container ID", isEqualTo: id).limit(1).get().then((value)  {
      var options = {
        "Container ID" : id,
        "Email": currentUser?.email,
        "Reward Claimed": claimed,
        "Listed" : listed,
        "Container Type" : TiasTarorContainerTypeHelper.getName(type),
        "Rewards" : rewards
      };

      try {
        value.docs.first.reference.set(options);
      } catch(e) {
        collection.add(options);
      }
    });

    return this;
  }
}