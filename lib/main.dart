import 'dart:ffi';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tias_tarot/TiasTarotApp.dart';
import 'package:tias_tarot/TiasTarotReading.dart';
import 'package:tias_tarot/TiasTarotUserInfo.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'package:audioplayers/audio_cache.dart';

import 'FullScreenModalWidget.dart';
import 'TiasTarotContainer.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:google_api_availability/google_api_availability.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

const String defaultProfileIconURL =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2FUserIcons%2FdefaultUserIcon.png?alt=media&token=ea44e896-cb66-4568-8d67-4551cdef97dd";
const String bannerUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fbanner.png?alt=media&token=297845a4-37a6-420f-978b-ff14cc27ade5&_gl=1*lrj6dm*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjYxOTk4NS4yMi4xLjE2ODY2MjAxMDAuMC4wLjA.";
const String banner2Url =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fbanner2.png?alt=media&token=f2302fc9-b59f-4077-8b59-3a6b4ecb8eac";
const String banner3Url =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fbanner3.png?alt=media&token=a5e8e973-5970-4d7d-86df-1ce3e3cad86d";

const String woodenBoxUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fwooden.png?alt=media&token=d6e10dff-71c2-4afd-a304-1d54dfdc5fba";
const String ironChestUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Firon.png?alt=media&token=adc4d0a2-28a4-4cb9-b776-fb0be502f18e";
const String silverChestUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fsilver.png?alt=media&token=ac8dd250-f927-4049-87e3-948c111e2cdc";
const String goldChestUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fgold.png?alt=media&token=4f7490c7-7900-4751-b3ca-14c7731347cc";
const String epicChestUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fepic.png?alt=media&token=ab177f1b-3aaf-441e-98e6-f592e62aa8d3";
const String legendaryChestUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Flegendary.png?alt=media&token=180cd5d7-b87f-48ab-b249-a86e905bf2eb";

void loginListener(Function(User?) loginListener) {
  FirebaseAuth.instance.authStateChanges().listen(loginListener);
}

void tokenChangeListener(Function(User?) tokenListener) {
  FirebaseAuth.instance.idTokenChanges().listen(tokenListener);
}

void userChangedListener(Function(User?) userChangeListener) {
  FirebaseAuth.instance.userChanges().listen(userChangeListener);
}

Future<UserCredential> signInUser(AuthCredential credential) async {
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

void userInfo(User? user) {
  if (user != null) {
    for (final providerProfile in user.providerData) {
      // ID of the provider (google.com, apple.com, etc.)
      final provider = providerProfile.providerId;

      // UID specific to the provider
      final uid = providerProfile.uid;

      // Name, email address, and profile photo URL
      final name = providerProfile.displayName;
      final emailAddress = providerProfile.email;
      final profilePhoto = providerProfile.photoURL;
    }
  }
}

Future<bool> giveItem(name, source, amount) async {
  if (currentUser?.email == null) return false;

  var collection = FirebaseFirestore.instance.collection('items');

  var options = {
    "Email": currentUser?.email,
    "Time Found": DateTime.now().millisecondsSinceEpoch,
    "Item Name": name,
    "Item Source": source,
    "Amount": amount,
  };

  await collection.add(options);
  return true;
}

buildGiveItemImageModal(String title, String header, String imageUrl) {
  FullScreenModalWidget modal = FullScreenModalWidget(
      title: title,
      toDisplay: SafeArea(child: Center(
        child: Stack(children: [
        Column(children: [
          Text(
            style: const TextStyle(fontSize: 24),
            header,
          ),
          Align(
              child: Flexible(
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: imageUrl,
            ),
          )),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                  style: TextStyle(fontSize: 24),
                  "The item has been placed in your inventory."),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                  style: TextStyle(fontSize: 24),
                  "Return to the main screen to view it."),
            ),
          ),
        ])
      ]))));

  return modal;
}

Future<bool> giveItemWithDescription(name, source, amount) async {
  if (await giveItem(name, source, amount)) {}

  String plural = "";
  if (amount > 1) plural = "s";

  String url = getItemUrlFromName(name);
  var modal = buildGiveItemImageModal(
      "Item Found", "You received $amount $name$plural", url);
  return false;
}

void showContainerDescription(
    BuildContext context, TiasTarotContainer container) {
  var modal = buildGiveItemImageModal("Container Found",
      "You received a ${container.name}", getContainerUrl(container));

  Navigator.of(context).push(modal);
}

String getContainerUrl(TiasTarotContainer container) {
  switch (container.type) {
    case TiasTarotContainerType.unknown:
      return "";
    case TiasTarotContainerType.woodenCharmBox:
      return woodenBoxUrl;
    case TiasTarotContainerType.ironCharmBox:
      return ironChestUrl;
    case TiasTarotContainerType.silverCharmBox:
      return silverChestUrl;
    case TiasTarotContainerType.goldCharmBox:
      return goldChestUrl;
    case TiasTarotContainerType.epicCharmBox:
      return epicChestUrl;
    case TiasTarotContainerType.legendaryCharmBox:
      return legendaryChestUrl;
  }
}

MaterialColor getItemColorByName(String name) {
  name = name.toLowerCase();
  if(name.contains("key")) return Colors.yellow;
  else if(name.contains("gold charm box")) return Colors.yellow;
  else if(name.contains("iron charm box")) return Colors.green;
  else if(name.contains("legendary charm box")) return Colors.orange;
  else if(name.contains("silver charm box")) return Colors.blue;

  return const MaterialColor(0xFFFFFFFF, {});
}

String getItemUrlFromName(String name) {
  if(name.toLowerCase() == "key") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fkey.png?alt=media&token=70bdeaed-f385-4235-98a6-f77852f73467";
  else if(name == "Wooden Charm Box") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fwooden.png?alt=media&token=d6e10dff-71c2-4afd-a304-1d54dfdc5fba";
  else if(name == "Gold Charm Box") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fgold.png?alt=media&token=4f7490c7-7900-4751-b3ca-14c7731347cc";
  else if(name == "Silver Charm Box") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fsilver.png?alt=media&token=ac8dd250-f927-4049-87e3-948c111e2cdc";
  else if(name == "Iron Charm Box") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Firon.png?alt=media&token=adc4d0a2-28a4-4cb9-b776-fb0be502f18e";
  else if(name == "Legendary Charm Box") return "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Flegendary.png?alt=media&token=180cd5d7-b87f-48ab-b249-a86e905bf2eb";
  return "";
}

Future<int> getKeyCount() async {
  var collection = FirebaseFirestore.instance.collection('items');
  var post = await collection.where("Email", isEqualTo: currentUser?.email).where("Item Name", isEqualTo: "Key").get();

  int count = 0;

  for (var itemData in post.docs) {
    int amount = itemData.data()["Amount"] ?? 1;
    count += amount;
  }

  return count;
}

Future<void> removeKey() async {
  var collection = FirebaseFirestore.instance.collection('items');
  var snapshot = await collection.where("Email", isEqualTo: currentUser?.email).get();

  for(var doc in snapshot.docs) {
    if(doc.data()["Item Name"] == "Key") {
      await doc.reference.delete();
      return;
    }
  }
}

Future<void> removeContainer(String type) async {
  var collection = FirebaseFirestore.instance.collection('items');
  var snapshot = await collection.where("Email", isEqualTo: currentUser?.email).where("Container Type", isEqualTo: type).get();

  var docs = snapshot.docs;
  if(docs.isNotEmpty) {
    docs[0].reference.delete();
  }
}

void getUserProfileImageURL(Function callback) {
  getCurrentUser((TiasTarotUserInfo info) {
    callback(info.profilePictureURL);
  }, ensureUserProfileOnFirestoreExists);
}

void getUserProfileDisplayName(Function callback) {
  getCurrentUser((TiasTarotUserInfo info) {
    callback(info.displayName);
  }, ensureUserProfileOnFirestoreExists);
}

Future<bool> spendCrystalsOnKey() async {
  int KEYCOST = 500;

  return getCurrentTiasTarotUserInfo().then((TiasTarotUserInfo info)  async {
    if (info.crystalCount >= KEYCOST) {
      // MOVE TO FUNCTION ONLINE
      int newCount = info.crystalCount - KEYCOST;

      bool success = false;

      await updateValue("Crystal Count", newCount).then((value) async {
        if (value == true) {
          var collection =
          FirebaseFirestore.instance.collection('crystalPurchases');

          var itemReceived = await giveItem("Key", "Crystal Purchase", 1);

          if(!itemReceived) {
            await updateValue("Crystal Count", info.crystalCount + KEYCOST);
            return;
          }

          var recordOfPurchase = await collection.add({
            "Email": info.email,
            "Crystals Spent": KEYCOST,
            "Item Purchased": "Key",
            "Reading ID": "NA",
            "Time Spent": DateTime
                .now()
                .millisecondsSinceEpoch
          });

          success = recordOfPurchase != null;
        }
      });

      return success;
    } else {
      return false;
    }
  });
}


Future<void> spendCrystalsOnReading(TiasTarotReading reading, Function? callback) async {
  getCurrentUser((TiasTarotUserInfo info) async {
    if (info.crystalCount >= reading.type.cost) {
      // MOVE TO FUNCTION ONLINE
      int newCount = info.crystalCount - reading.type.cost;

      var result = await updateValue("Crystal Count", newCount);

      if (result == true) {
        var collection =
            FirebaseFirestore.instance.collection('crystalPurchases');

        collection.add({
          "Email": info.email,
          "Crystals Spent": reading.type.cost,
          "Item Purchased": reading.type.name,
          "Reading ID": reading.id,
          "Time Spent": DateTime.now().millisecondsSinceEpoch
        });
      }

      callback!(result);
    } else {
      callback!(false);
    }
  }, () {
    callback!(false);
  });
}

Future<bool> updateValue(String key, dynamic value) async {
  try {
    var collection = FirebaseFirestore.instance.collection('userInfo');
    final post = await collection
        .where("Email", isEqualTo: currentUser?.email)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      //Here we get the document reference and return to the post variable.
      return snapshot.docs[0].reference;
    });

    var batch = FirebaseFirestore.instance.batch();
    //Updates the field value, using post as document reference
    batch.update(post, {key: value});
    await batch.commit();

    return true;
  } catch (e) {
    return false;
  }
}

Future<dynamic> getValue(String key) async {
  try {
    if (currentUser == null || currentUser?.email == null) return null;
    var collection = FirebaseFirestore.instance.collection('userInfo');
    final post = await collection
        .where("Email", isEqualTo: currentUser?.email)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      //Here we get the document reference and return to the post variable.
      return snapshot.docs[0].reference;
    });

    var result = await post.get().then((value) => value[key]);
    return result;
  } catch (e) {
    return null;
  }
}

Future<void> createAccount(
    String emailAddress, String password, Function callback) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      callback('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      callback('The account already exists for that email.');
    }
  } catch (e) {
    callback(e);
  }
}

Future<void> signIn(
    String emailAddress, String password, Function callback) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      callback('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      callback('Wrong password provided for that user.');
    }
  }
}

Future<void> signOut(Function callback) async {
  await FirebaseAuth.instance.signOut();
  currentUser = null;

  callback();
}

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

User? previousUser;
User? currentUser;

void ensureUserProfileOnFirestoreExists(
    [Function? callback, Function? callbackOnNoUserInfo]) {
  getCurrentUserInfoRef(callback, callbackOnNoUserInfo);
}

void getCurrentUserInfoRef(Function? callback, Function? callbackOnNoUserInfo) {
  final userInfoRef = FirebaseFirestore.instance
      .collection('userInfo')
      .withConverter<TiasTarotUserInfo>(
        fromFirestore: (snapshots, _) =>
            TiasTarotUserInfo.fromJson(snapshots.data()!),
        toFirestore: (data, _) => data.toJson(),
      );

  String uid = currentUser!.uid;
  String? email = currentUser?.email;

  getCurrentUserFromRef(userInfoRef, email, callback, callbackOnNoUserInfo);
}

Future<TiasTarotUserInfo> getCurrentTiasTarotUserInfo() async {
  final userInfoRef = FirebaseFirestore.instance
      .collection('userInfo')
      .withConverter<TiasTarotUserInfo>(
    fromFirestore: (snapshots, _) =>
        TiasTarotUserInfo.fromJson(snapshots.data()!),
    toFirestore: (data, _) => data.toJson(),
  );

  String uid = currentUser!.uid;
  String? email = currentUser?.email;

  var result = await userInfoRef
      .where("Email", isEqualTo: email)
      .get();

  return result.docs.first.data();

}

bool cardsLoaded = false;
Map<String, Map<String, dynamic>> TiasTarotCards =
    <String, Map<String, dynamic>>{};

void getCardsRef(Function? callback) {
  final cardRef = FirebaseFirestore.instance.collection('cards');

  final Stream<QuerySnapshot<Map<String, dynamic>>> cardSnapshot =
      cardRef.snapshots();

  Map<String, Map<String, dynamic>> cards = <String, Map<String, dynamic>>{};
  cardSnapshot.forEach((snap) {
    snap.docs.forEach((element) {
      cards.addAll({element.id: element.data()});

      if (!cardsLoaded) {
        TiasTarotCards.addAll({element.id: element.data()});
      }
    });

    cardsLoaded = true;
    callback!(cards);
  });
}

void playKeyFoundAudio() {
  var ap = AudioPlayer();
  ap.setVolume(2);

  Future.delayed(const Duration(milliseconds: 250)).then((value) {
    ap.play(AssetSource("keys.flac"));
    Future.delayed(const Duration(seconds: 1)).then((value) => ap.stop());
  });
}

int getRandomNumber() {
  return Random().nextInt(82);
}

bool reverseRoll() {
  return isCardReversed();
}

bool isCardReversed() {
  return Random().nextInt(100) < 10;
}

List<int> getRandomDraw(int count) {
  List<int> result = [];

  for (int i = 0; i < count; ++i) {
    int cardNumber = getRandomNumber();

    while (result.contains(cardNumber)) {
      cardNumber = getRandomNumber();
    }

    result.add(cardNumber);
  }

  return result;
}

bool isCardMinor(card) {
  return card['Major'] == false;
}

String getMinorMeaning(card, int number, bool reversed) {
  String target = 'Minors Upright';
  if (reversed) {
    target = 'Minors Reversed';
  }

  if (number == 6 && card["Name"] == "King of Swords") {
    return "Maybe";
  } else if (reversed && number == 6 && card['Name'] == "King of Wands") {
    return "Neither";
  }

  String result =
      card['Details'][target][card['Minor Index']][number].toString();
  return result;
}

String getMajorMeaning(card, int number, bool reversed) {
  String target = 'Upright';
  if (reversed) {
    target = 'Reversed';
  }

  if (number == 6) {
    if (card['Name'] == "The Hierophant ") return "Maybe";
    return card['Details']["Yes or No"] == "true" ? "Yes" : "No";
  }

  String result = card['Details'][target][number];
  return result;
}

String getCardMeaning(card, int number, bool reversed) {
  if (card['Major']) {
    return getMajorMeaning(card, number, reversed);
  } else {
    return getMinorMeaning(card, number, reversed);
  }
}

String getRandomCardMeaning(card, bool reversed) {
  return getCardMeaning(card, Random().nextInt(5), reversed);
}

List<String> getTwoRandomCardMeanings(card) {
  int one = Random().nextInt(5);
  int two = one;

  while (two == one) {
    two = Random().nextInt(5);
  }

  return [
    getCardMeaning(card, one, isCardReversed()),
    getCardMeaning(card, two, isCardReversed())
  ];
}

List<String> getThreeRandomCardMeanings(card, bool reversed) {
  int one = Random().nextInt(5);
  int two = one;
  int three = one;

  while (two == one) {
    two = Random().nextInt(5);
  }

  while (three == one || three == two) {
    three = Random().nextInt(5);
  }

  print("$one , $two , $three");

  return [
    getCardMeaning(card, one, reversed),
    getCardMeaning(card, two, reversed),
    getCardMeaning(card, three, reversed)
  ];
}

String isCardYesNoOrMaybe(card, bool reversed) {
  String result = 'Maybe';

  if (isCardMinor(card)) {
    if (getMinorMeaning(card, 6, reversed) == "true") {
      return "Yes";
    } else {
      return "No";
    }
  } else {
    return getMajorMeaning(card, 6, reversed);
  }
}

Future<Reference> getCardFrontRef(card) async {
  final storageRef = FirebaseStorage.instance.ref();
  String cardName = card['Name'].toString().replaceAll(' ', '');

  const deck = 'Rider Waite';
  final url = await storageRef
      .child("Images/Cards/$deck/$cardName.png")
      .getDownloadURL();
  return FirebaseStorage.instance.refFromURL(url);
}

List getRandomCardDraw(int count) {
  var result = [];

  var cardNumbers = getRandomDraw(count);
  for (var element in cardNumbers) {
    getCardByNumber(element, (card) {
      card['Is Reversed'] = isCardReversed();

      card['Yes, No, or Maybe'] = isCardYesNoOrMaybe(card, card['Is Reversed']);

      card['Meaning'] = getRandomCardMeaning(card, card['Is Reversed']);

      result.add(card);
    });
  }

  return result;
}

void getCardByNumber(int number, Function callback) {
  if (!cardsLoaded) {
    print("CALLED BEFORE CARDS LOADED");
    getCardsRef((card) => {});

    return;
  }

  var totalCards = 77;
  var majorCards = 22;
  var suitCards = 4;
  var cardsInSuit = 14;

  if (number >= majorCards) {
    var cups = majorCards;
    var swords = cups + cardsInSuit + 1;
    var wands = swords + cardsInSuit + 1;
    var pentacles = wands + cardsInSuit + 1;

    inSuit(suit) => (number - suit) >= 0 && (number - suit) <= cardsInSuit;

    int suitIndex = 0;
    int differance = 0;
    if (inSuit(cups)) {
      differance = number - cups;

      suitIndex = 22;
    } else if (inSuit(swords)) {
      differance = number - swords;
      suitIndex = 23;
    } else if (inSuit(wands)) {
      differance = number - wands;
      suitIndex = 24;
    } else {
      differance = number - pentacles;
      suitIndex = 25;
    }

    TiasTarotCards.forEach((key, value) {
      if (value['Number'] == suitIndex) {
        callback({
          'Name': '${indexToCardName(differance)} of ${value['Minor Name']}',
          'Details': value,
          'Major': false,
          'Minor Index': indexToCardName(differance),
          'sign' : value["sign"]
        });
      }
    });
  } else {
    TiasTarotCards.forEach((key, value) {
      if (value['Number'] == number) {
        callback({'Name': key, 'Details': value, 'Major': true,
          'sign' : value["sign"]});
      }
    });
  }
}

String indexToCardName(int i) {
  switch (i) {
    case 0:
      return "Ace";
    case 1:
      return "Two";
    case 2:
      return "Three";
    case 3:
      return "Four";
    case 4:
      return "Five";
    case 5:
      return "Six";
    case 6:
      return "Seven";
    case 7:
      return "Eight";
    case 8:
      return "Nine";
    case 9:
      return "Ten";
    case 10:
      return "Page";
    case 11:
      return "Knight";
    case 12:
      return "Queen";
    case 13:
    default:
      return "King";
  }
}

void getCurrentUserFromRef(CollectionReference<TiasTarotUserInfo> userInfoRef,
    String? email, Function? callback, Function? callbackOnNoUserInfo) {
  userInfoRef
      .where("Email", isEqualTo: email)
      .get()
      .then((QuerySnapshot<TiasTarotUserInfo> value) {
    int len = value.docs.length;

    if (len == 0) {
      if (callbackOnNoUserInfo != null)
        callbackOnNoUserInfo!(userInfoRef, currentUser);
    } else {
      callback!(value.docs.first.data());
    }
    //value.docs.forEach((element) {
    //print("element $element");
    //});\
  });
}

User? getCurrentUser([Function? getDocs, Function? noUserInfo]) {
  if (currentUser != null) {
    if (noUserInfo != null) {
      ensureUserProfileOnFirestoreExists(getDocs, noUserInfo);
    }
  }

  return currentUser;
}

Future<void> getUserFromStorage() async {
  currentUser = (await storage.read(key: 'User')) as User?;
}

Future<void> saveCurrentUser() async {
  await storage.write(key: 'User', value: currentUser.toString());
}

bool isUserNull() {
  return currentUser == null;
}

void updateCurrentUser(User? user) {
  if (user != null) {
    if (user != currentUser) {
      previousUser = currentUser;
      currentUser = user;

      print('user changed');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  final auth = FirebaseAuth.instanceFor(
      app: Firebase.app(), persistence: Persistence.NONE);

  GooglePlayServicesAvailability availability =
      GooglePlayServicesAvailability.unknown;
  try {
    availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability(true);
  } on PlatformException {
    availability = GooglePlayServicesAvailability.unknown;
  }

  print(availability.toString());

  getUserFromStorage();
  loginListener(updateCurrentUser);
  userChangedListener(updateCurrentUser);

  runApp(const TiasTarotApp());
}

String crystalUrl =
    "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fcrystal.png?alt=media&token=18247206-5988-45dd-aa11-25d489a4b372&_gl=1*1mgym6l*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjU5NjczMi4yMS4xLjE2ODY1OTY5NzAuMC4wLjA.";

int getTarotReadCount() {
  return 47;
}

void randomCardExample() {
  var cards = getRandomCardDraw(1);

  for (var element in cards) {
    if (element['Is Reversed']) {
      print('Reverse ${element['Name']}');
    } else {
      print(element['Name']);
    }

    print(element['Meaning']);
  }
}
