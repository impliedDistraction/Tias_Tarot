import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/FullScreenModalWidget.dart';
import 'package:tias_tarot/TiasTarotReading.dart';

import 'TiasTarotReadingLongView.dart';
import 'main.dart';

class TiasTarotReadingShortView extends StatelessWidget {
  TiasTarotReading reading;

  TiasTarotReadingShortView({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    List<String> date =
        DateTime.fromMillisecondsSinceEpoch(reading.timeFinished)
            .toString()
            .split(":");
    String dt = "${date[0]}:${date[1]}";

    String name = reading.type.name;

    return Column(children: [
      CachedNetworkImage(
        placeholder: (context, url) =>
        const CircularProgressIndicator(),
        imageUrl: banner3Url,
      ),
      CachedNetworkImage(
        placeholder: (context, url) => const CircularProgressIndicator(),
        imageUrl: reading.type.imageUrl,
      ),
      Text(
        "$name from $dt",
        style: const TextStyle(backgroundColor: Colors.blue),
      ),
      if (!reading.isFinished())
        ElevatedButton(
          onPressed: onButtonPressed(context),
          child: const Text("Finish Reading"),
        ),
      if (reading.isFinished())
        ElevatedButton(
          onPressed: onButtonPressed(context),
          child: const Text("View Reading"),
        ),
    ]);
  }

  bool sameData(TiasTarotReadingShortView other) {
    return reading.id == other.reading.id;
  }

  Null Function() onButtonPressed(BuildContext context) {
    return () {
      List<String> date =
          DateTime.fromMillisecondsSinceEpoch(reading.timeFinished)
              .toString()
              .split(":");
      String dt = "${date[0]}:${date[1]}";

      String name = reading.type.name;
      TiasTarotReadingLongView lw = TiasTarotReadingLongView(reading: reading);
      FullScreenModalWidget modal = FullScreenModalWidget(
          title: "${name}on $dt", toDisplay: lw);

      Navigator.of(context).push(modal);
    };
  }
}
