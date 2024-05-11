

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/InventoryView.dart';

import 'FullScreenModal.dart';
import 'main.dart';

class BuyKeysWidget extends StatefulWidget{
  int crystalBalance;

  String buttonText = "Confirm";
  bool pressed = false;

  bool fromInventory;

  BuyKeysWidget({super.key, required this.crystalBalance, required this.fromInventory});

  @override
  State<StatefulWidget> createState() => BuyKeysState();
  
}

class BuyKeysState extends State<BuyKeysWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child:
                Text(
                  "Buy a Key",
                  style: TextStyle(color: Colors.white, fontSize: 40.0),
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
                      imageUrl: getItemUrlFromName("Key"),
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
                      Text(widget.crystalBalance.toString())
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
                  const Padding(
                      padding: EdgeInsets.only(left: 40, right: 6),
                      child:
                      Text("500")
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
              if(!widget.pressed)
                ElevatedButton.icon(
                  onPressed: onKeyPurchased,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm'),
                ),
              ElevatedButton.icon(
                onPressed: widget.pressed ? null : goBack,
                icon: const Icon(Icons.close),
                label: Text(widget.buttonText),
              )
            ],
          ),
        ),
      )
    );
  }

  void goBack() {
    Navigator.pop(context, []);
  }
  

  void onKeyPurchased() {
    widget.pressed = true;
    widget.buttonText = "Please Wait...";
    setState(() {

    });
    spendCrystalsOnKey().then((value) => value ? onSuccessfulPurchase() : onFailedPurchase());
  }

  onSuccessfulPurchase() async {
    print("Success");
    playKeyPurchasedAudio();
    goBack();

    if(widget.fromInventory) {
      InventoryView iv = InventoryView();
      await Navigator.of(context).push(iv);
    }

    FullScreenModal modal = FullScreenModal(
        title: "Purchase Success",
        description: "You purchased a key for 500 crystals!",
        showButton: true
    );

    await Navigator.of(context).push(modal);
  }

  onFailedPurchase() async {
    print("Failure -- BUYKEYS");
    goBack();

    FullScreenModal modal = FullScreenModal(
        title: "Purchase Failed",
        description: "Something went wrong with the purchase. Did you have enough crystals?",
        showButton: true
    );

    await Navigator.of(context).push(modal);
  }

  void playKeyPurchasedAudio() {
    var ap = AudioPlayer();
    ap.setVolume(2);

    Future.delayed(const Duration(milliseconds: 250)).then((value) {
      ap.play(AssetSource("keys.flac"));
      Future.delayed(const Duration(seconds: 1)).then((value) => ap.stop());
    });
  }
}