import 'dart:ffi';

import 'package:flutter/cupertino.dart';

@immutable
class TiasTarotUserInfo {
  const TiasTarotUserInfo({
    required this.dateOfBirth,
    required this.displayName,
    required this.profilePictureURL,
    required this.email,
    required this.userID,
    required this.crystalCount,
    required this.crystalsPurchased,
    required this.logins,
    required this.longestLoginStreak,
    required this.readingCount,
    required this.generalReadingCount,
    required this.horseshoeReadingCount,
    required this.actionOutcomeReadingCount,
    required this.dailyReadingCount,
    required this.yesNoReadingCount,
    required this.tiktokFollow,
    required this.youtubeFollow,
    required this.intuition,
  });

  TiasTarotUserInfo.fromJson(Map<String, Object?> json)
      : this(
    dateOfBirth: json["Date of Birth"]! as int,
    displayName: json["Display Name"]! as String,
    email: json["Email"]! as String,
    profilePictureURL: json["Profile Picture URL"]! as String,
    userID: json["User ID"]! as String,
    crystalCount: json['Crystal Count']! as int,
    crystalsPurchased: json['Crystals Purchased']! as int,
    logins: json['Logins'] as List<dynamic>,
    longestLoginStreak: json['Longest Login Streak'] != null? json['Longest Login Streak'] as int : 0,
    readingCount: json['Reading Count'] != null? json['Reading Count'] as int : 0,
    generalReadingCount: json['General Reading Count'] != null? json['General Reading Count'] as int : 0,
    horseshoeReadingCount: json['Horseshoe Reading Count'] != null? json['Horseshoe Reading Count'] as int : 0,
    actionOutcomeReadingCount: json['Action Outcome Reading Count'] != null? json['Action Outcome Reading Count'] as int : 0,
    dailyReadingCount: json['Daily Reading Count'] != null? json['Daily Reading Count'] as int : 0,
    yesNoReadingCount: json['Yes or No Reading Count'] != null? json['Yes or No Reading Count'] as int : 0,
    tiktokFollow: json['TikTok Follower'] != null? json['TikTok Follower'] as bool : false,
    youtubeFollow: json['YouTube Follower'] != null? json['YouTube Follower'] as bool : false,
    intuition: json['Intuition'] != null? json['Intuition'] as int : 0,
  );

  Map<String, Object?> toJson() {
    return {
      'Date of Birth': dateOfBirth,
      'Display Name': displayName,
      'Profile Picture URL': profilePictureURL,
      'Email' : email,
      'User ID': userID,
      'Crystal Count': crystalCount,
      'Crystals Purchased': crystalsPurchased,
      'Logins': logins,
      'Longest Login Streak': longestLoginStreak,
      'Reading Count': readingCount,
      'General Reading Count': generalReadingCount,
      'Horseshoe Reading Count': horseshoeReadingCount,
      'Action Outcome Reading Count': actionOutcomeReadingCount,
      'Daily Reading Count': dailyReadingCount,
      'Yes or No Reading Count': yesNoReadingCount,
      'TikTok Follower': tiktokFollow,
      'YouTube Follower': youtubeFollow,
      'Intuition': intuition,
    };
  }

  DateTime getBirthdayAsDateTime() {
    return DateTime.fromMicrosecondsSinceEpoch(dateOfBirth);
  }

  final int dateOfBirth;
  final int crystalCount;
  final int crystalsPurchased;
  final String displayName;
  final String profilePictureURL;
  final String? email;
  final String userID;
  final List<dynamic> logins;
  final int longestLoginStreak;
  final int readingCount;
  final int generalReadingCount;
  final int horseshoeReadingCount;
  final int actionOutcomeReadingCount;
  final int dailyReadingCount;
  final int yesNoReadingCount;
  final bool tiktokFollow;
  final bool youtubeFollow;
  final int intuition;
}
