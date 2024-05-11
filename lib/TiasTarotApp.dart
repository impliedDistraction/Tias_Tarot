import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tias_tarot/TiasTarotHomepage.dart';

class TiasTarotApp extends StatelessWidget {
  const TiasTarotApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tia's Tarot",
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          titleSmall: TextStyle(fontSize: 12.0, fontFamily: 'Hind', fontWeight: FontWeight.bold),
        ),
        primarySwatch: Colors.purple,
      ),
      home: TiasTarotHomepage(title: "Tia's Tarot"),
    );
  }
}