// this class defines the full-screen semi-transparent modal dialog
// by extending the ModalRoute class
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:tias_tarot/BuyKeys.dart';
import 'package:tias_tarot/FullScreenModalConfirmKeyUse.dart';
import 'package:tias_tarot/TiasTarotContainer.dart';

import 'FullScreenModal.dart';
import 'main.dart';

class ShortItemView {
  String id;

  int amount;
  String name;

  ShortItemView({required this.id, required this.amount, required this.name});
}

class NamedAmounts extends StatefulWidget {
  String name;
  int amount;

  List<ShortItemView> views = <ShortItemView>[];

  NamedAmounts({super.key, required this.name, required this.amount});

  @override
  State<StatefulWidget> createState() => NamedAmountsState();

  addAmount(ShortItemView view) {
    for (var v in views) {
      if (v.id == view.id) return;
    }

    amount += view.amount;
    views.add(view);
  }
}

class NamedAmountsState extends State<NamedAmounts> {
  bool showContextMenu = false;

  double lastHeight = 0;

  GlobalKey stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> amountNotifier = ValueNotifier(widget.amount);
    amountNotifier.addListener(() {
      setState(() {});
    });

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String name = widget.name;
    if (widget.amount > 1) name += "s";

    return
      GestureDetector(
      onTap: showItemContextMenu(context),
      child:
      FocusDetector(
        onFocusLost: () {},
        onFocusGained: () {
      },
        onVisibilityLost: () {},
        onVisibilityGained: () {
      },
        onForegroundLost: () {},
        onForegroundGained: () {
      },
      child:
      Stack(
      key: stackKey,
      children: [
          Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.centerLeft,
            height: showContextMenu ? getHeight(context) : 64,
            width: (screenWidth +64 ) * 0.90,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent)
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
        children: [
        Row(
        children: [
          Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.centerLeft,
              height: 64,
              width: 64,
              child: CachedNetworkImage(
                imageUrl: getItemUrlFromName(widget.name),
          )),
          Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.centerLeft,
            height: 64,
            width: (screenWidth - 64) * 0.65,
            child: FittedBox(
                fit: BoxFit.cover,
                child: Text(name,
                  style: TextStyle(color: getItemColorByName(name))
                )
            ),
          ),
          Container(
              margin: const EdgeInsets.all(4),
              alignment: Alignment.centerRight,
              height: 64,
              width: (screenWidth - 64) * 0.25,
              child:
                  Text("${widget.amount}", style: const TextStyle(fontSize: 25)))
        ],
      ),
      if(showContextMenu) getContextMenuItems(screenWidth),
    ]),
    ])));
  }

  showItemContextMenu(BuildContext context) {
    return () {
      showContextMenu = !showContextMenu;

      setState(() {

      });
    };
  }

  getContextMenuItems(double screenWidth) {
    if(widget.name.contains("Box")) {
      TiasTarotContainerType type = TiasTarorContainerTypeHelper.getTypeFromName(widget.name);
      List<dynamic> rewards = TiasTarorContainerTypeHelper.getRewardTypes(type);

      return
      Container(
      child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: screenWidth * 0.95,
                  child:
                  FittedBox(
                      child:Text("${TiasTarorContainerTypeHelper.getName(type)}(s) are given as rewards for those seeking spiritual guidance.")
                  )
              ),const FittedBox(
                  child: Text("A gift from the spirits! Use a key to open it.")
              ),
              const SizedBox(height: 8,),
              FittedBox(
                  child:
                  ElevatedButton(
                    child: const Text("Get Keys"), onPressed: onGetKeysPressed,
                  )
              ),
              const SizedBox(height: 32,),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (var view in getRewards(rewards)) view]
              ),

              const SizedBox(height: 8,),
              FittedBox(
                  child:
                  ElevatedButton(
                    onPressed: openBox(context),

                    child: const Text("Open",
                      style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    )),
                  )
              ),

              const SizedBox(height: 8,),
              Container(
                  width: screenWidth * 0.95,
                  child:
                  const FittedBox(
                      child:Text("Not all boxes drop all reward types!")
                  )
              ),

        ],
      ));
    } else if(widget.name.contains("Key")) {
      return
        Container(
            width: screenWidth * 0.95,
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:[
                    Container(
                      width: screenWidth * 0.65,
                      child:
                      const FittedBox(
                          child:Text("A key to open a locked door, chest, or box.")
                      )
                    ),
                    Container(
                        width: screenWidth * 0.65,
                        child:
                        const FittedBox(
                            child:Text("Turn over more cards during a tarot reading to find more!")
                        )
                    ),
                  ]
                ),
                Container(
                  width: screenWidth * .2,
                child:
                FittedBox(
                    alignment: Alignment.centerRight,
                    child:
                    ElevatedButton(
                      child: const Text("Tarot Readings"), onPressed: () {  },
                    )
                )),
              ],
            ));
      }
    }

  getRewards(List rewards) {
    List<Widget> result = <Widget>[];

    result.add(
        FittedBox(
        child:

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.yellow, Colors.deepOrange],
          ).createShader(bounds),
          child: const Text("Chance to collect the following:",
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
        )

    ));

    List<String> allreadyAdded = <String>[];

    for(var reward in rewards) {
      int amount = reward["Amount"];
      String type = reward["Type"];
      String rarity = reward["Rarity"];

      if(type == "twoKeys") {
        amount = amount * 2;
        type = "keys";
      }

      type = type[0].toUpperCase() + type.substring(1);

      var desc = "$amount $type";
      if(amount == 1) {
        desc = "A $type";
      }

      MaterialColor color1 = Colors.grey;
      MaterialColor color2 = Colors.green;

      Duration duration = const Duration(seconds: 3);

      print("$desc $rarity");

      if(rarity == "rare") {
        color1 = Colors.blue;
        color2 = Colors.cyan;
      } else if(rarity == "epic") {
        color1 = Colors.yellow;
        color2 = Colors.amber;

        duration = const Duration(seconds: 2);
      } else if(rarity == "legendary") {
        color1 = Colors.red;
        color2 = Colors.deepOrange;

        duration = const Duration(seconds: 1);
      }

      if(allreadyAdded.contains(desc + rarity)) continue;

      result.add(FittedBox(
        child:
        GradientAnimationText(
          text: Text(desc,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          colors: [
            color2,
            color2,
            color2,
            color1,
            color1,
            color1,
          ],
          duration: duration,
        ),
      ));

      allreadyAdded.add(desc + rarity);
    }

    return result;
  }

  openBox(BuildContext context) {
    return () {
      Navigator.of(context).pop();

      getKeyCount().then((value){
        if(value < 1) {
          FullScreenModal modal = FullScreenModal(
              title: "You don't have any keys!",
              description: "Turn over cards in a reading to find more!",
              showButton: true
          );

          Navigator.of(context).push(modal);
        } else {
          FullScreenModalConfirmKeyUse modal = FullScreenModalConfirmKeyUse(title: "Use a key to open a ${widget.name}", type: widget.name, keyBalance: value);
          Navigator.of(context).push(modal);
        }
      });
    };
  }

  getHeight(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      BuildContext? context = stackKey.currentContext;
      if(context != null) {
        RenderBox box = context.findRenderObject() as RenderBox;
        double height = box.size.height;

        if(lastHeight - height !=-8) {
          print("$height $lastHeight ${lastHeight - height}");
          lastHeight = height;
          setState(() {

          });
        }
      }
    });

    return lastHeight;
  }

  void onGetKeysPressed() {
    getValue("Crystal Count").then((value) async {
      int count = int.tryParse(value.toString()) ?? 0;

      Navigator.of(context).pop();

      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BuyKeysWidget(crystalBalance: count, fromInventory: true,)),
      );
    });
  }
}


class InventoryView extends ModalRoute {
  static InventoryView? instance;

  List<ShortItemView> items = <ShortItemView>[];
  List<NamedAmounts> amounts = <NamedAmounts>[];

  // constructor
  InventoryView() {
    getItems();
    getContainers();

    instance = this;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.86);

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: SingleChildScrollView(
          child:Column(

              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Inventory", style: TextStyle(fontSize: 25)),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (var view in noEmpty(amounts)) view]
                ),
                ElevatedButton(onPressed: goBack(context), child: const Text("Back")),
              ])
        )),
    );
  }

  goBack(BuildContext context) {
    return () {
      Navigator.pop(context, []);
    };
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

  getItems() {
    var collection = FirebaseFirestore.instance.collection('items');
    Stream<QuerySnapshot<Map<String, dynamic>>> post =
        collection.where("Email", isEqualTo: currentUser?.email).snapshots();

    bool foundNew = false;
    post.listen((event) {
      for (var itemData in event.docs) {
        if (!contains(itemData.id)) {
          String id = itemData.id;
          String name = itemData.data()["Item Name"];
          int amount = itemData.data()["Amount"] ?? 1;

          addItem(id, name, amount);
        }
      }
    });
  }

  getContainers() {
    var collection = FirebaseFirestore.instance.collection('containers');
    Stream<QuerySnapshot<Map<String, dynamic>>> post =
        collection.where("Email", isEqualTo: currentUser?.email).snapshots();

    bool foundNew = false;
    post.listen((event) {
      for (var itemData in event.docs) {
        if (!contains(itemData.id)) {
          String id = itemData.id;
          String name = itemData.data()["Container Type"];
          int amount = 1;

          addItem(id, name, amount);
        }
      }
    });
  }

  addItem(String id, String name, int amount) {
    var toAdd = ShortItemView(id: id, amount: amount, name: name);

    items.add(toAdd);

    bool notFound = true;
    for (var namedView in amounts) {
      if (namedView.name == name) {
        namedView.addAmount(toAdd);
        notFound = false;
        break;
      }
    }

    if (notFound) {
      NamedAmounts nas = NamedAmounts(name: name, amount: 0);

      nas.addAmount(toAdd);

      amounts.add(nas);
    }

    setState(() {});
    changedExternalState();
  }

  bool contains(String id) {
    for (ShortItemView item in items) {
      if (item.id == id) return true;
    }

    return false;
  }

  noEmpty(List<NamedAmounts> amounts) {
    List<NamedAmounts> result = <NamedAmounts>[];

    for (var i in amounts) {
      if (i.amount > 0) result.add(i);
    }

    return result;
  }
}
