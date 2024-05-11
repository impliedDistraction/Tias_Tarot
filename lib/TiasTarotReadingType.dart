import 'package:cloud_firestore/cloud_firestore.dart';

import 'TiasTarotReading.dart';

enum TiasTarotReadingType {
  dailyReading('Daily Reading',
      'A single card draw in Tarot is a simple and concise way to gain insights and guidance on a specific question or situation.',
      """
      You will be shown a number of cards and be asked to use your intuition to select the card that you feel is going to offer your the most guidance.Before selecting a card, it's essential to focus your energy and set a clear intention for the reading. Ask a specific question or seek guidance on a particular area of your life. 
      
      The card you select represents the energies, themes, and messages relevant to your question or situation. Each Tarot card has its own symbolism, meanings, and interpretations. Pay attention to the imagery, symbolism, and emotions evoked by the card.
      
      Remember that Tarot readings are a form of guidance and should be used as a tool for self-reflection and personal growth. The cards offer insights, but ultimately, you have the power to shape your own path and make choices based on your own intuition and wisdom.
      
      Take the insights and guidance from the card into consideration as you make decisions or take actions in your life. The card serves as a tool to gain perspective, broaden your understanding, and provide clarity or direction.""",
      "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fdaily.png?alt=media&token=7ec3294c-8477-4224-b0c9-3b3311b31969&_gl=1*9j3uou*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjU4MDk3Ni4xOS4xLjE2ODY1ODQ2MTMuMC4wLjA.",
      1, 4,
      100),
  generalReading('General Reading',
      'A three-card tarot reading is a simple yet insightful method that can provide guidance and clarity on a specific situation or question. Each card represents a different aspect or perspective related to your situation.',
      """
      The first card reflects the energies and influences of the past that have led to the current situation. It helps you understand the background, events, or experiences that have shaped your circumstances. It may reveal patterns, lessons learned, or unresolved issues that need to be addressed.
      
      The second card represents the current state of affairs. It sheds light on the key elements, challenges, or opportunities that are directly affecting your situation at the present moment. This card can offer insights into your feelings, thoughts, or external factors influencing the matter.
      
      The third card provides a glimpse into the possible outcome or direction of the situation. It offers guidance on potential paths, opportunities, or challenges that may arise as you move forward. While the future is not set in stone, this card can help you understand the potential consequences of your actions or decisions.
      """,
      "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fgeneral.png?alt=media&token=89e4e435-e38c-45d2-b094-f9473d366951&_gl=1*1yfgset*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjU4MDk3Ni4xOS4xLjE2ODY1ODU1ODMuMC4wLjA.",
      3, 8,
      300),
  horseshoeReading(
      'Horseshoe Reading',
      'A horseshoe tarot reading is a more complex spread that involves seven cards, arranged in the shape of a horseshoe. This spread provides a deeper understanding of a situation by examining various aspects and influences.',
      """
      The Present Situation: This card represents the current circumstances and the energies surrounding the situation. It offers insights into what you are currently experiencing and serves as a foundation for the rest of the reading.
      
      Obstacles and Challenges: This card highlights the obstacles or challenges you may be facing in relation to your question or situation. It helps you identify potential hurdles and offers guidance on how to overcome them.
      
      Influences from the Past: This card reflects the influences from the past that are still affecting your current situation. It helps you understand how past experiences, choices, or people have contributed to your present circumstances.
      
      Future Events: This card provides a glimpse into the future and offers insights into the potential outcomes or events that may occur. It can help you make informed decisions or prepare for what lies ahead.
      
      External Influences: This card represents external factors that are impacting your situation. It could be people, circumstances, or energies that are affecting the outcome. It offers a broader perspective on the forces at play beyond your control.
      
      Advice or Guidance: This card provides guidance and advice on how to navigate the situation effectively. It offers suggestions on actions, attitudes, or mindsets that can help you overcome challenges or make the most of opportunities.
      
      Outcome: The final card reveals the potential outcome or resolution of the situation. It offers insights into where things may be heading and helps you understand the overall trajectory or direction.
      """,
      "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Fhorseshoe.png?alt=media&token=ba520dcc-a48b-4afa-b8dc-9fa202654396&_gl=1*1ozimwa*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjU4MDk3Ni4xOS4xLjE2ODY1ODU2MDYuMC4wLjA.",
      7, 20,
      700),
  actionOutcomeReading('Action Outcome Reading',
      'An action outcome tarot reading is a type of tarot spread that focuses on a specific action you can take and the potential outcome of that action. It helps you gain clarity on a decision or course of action and provides insights into the possible consequences.',
      """
      The Action: This card represents the specific action or decision you are contemplating or considering. It reflects the choice or step you are about to take.
      
      The Potential Outcome: This card reveals the potential outcome of the action you're considering. It offers insights into what may result from taking that particular course of action. It's important to remember that outcomes are not set in stone, and your actions and choices can influence the final result.
      
      The Advantages: This card highlights the positive aspects or benefits that may arise from taking the action. It sheds light on the strengths, opportunities, or advantages that can be gained.
      
      The Challenges: This card reveals the potential challenges or obstacles that may arise as a result of taking the action. It helps you anticipate and prepare for any difficulties or setbacks that you may encounter.
      
      Guidance or Advice: This card provides guidance or advice on how to approach the action and navigate the potential outcome. It may offer suggestions on the mindset, actions, or strategies that can help you achieve a favorable outcome.
      
      Additional Factors to Consider: This card represents any additional factors, influences, or considerations that may impact the action and outcome. It offers a broader perspective and helps you make a more informed decision.
      """,
      "https://firebasestorage.googleapis.com/v0/b/tias-tarot-mobile.appspot.com/o/Images%2Faction.png?alt=media&token=867657c2-d75a-4446-9579-829259d46848&_gl=1*u57m0n*_ga*MjMyNTA2NjIxLjE2ODI2NDcwOTI.*_ga_CW55HF8NVT*MTY4NjU4MDk3Ni4xOS4xLjE2ODY1ODQ1NzUuMC4wLjA.",
      6, 20,
      600);

  const TiasTarotReadingType(this.name, this.shortDescription,
      this.longDescription, this.imageUrl, this.cardCount, this.deckSize, this.cost);

  final String name;
  final int cost;
  final int cardCount;
  final int deckSize;
  final String shortDescription;
  final String imageUrl;
  final String longDescription;

}

class TiasTarotReadingTypeHelpers {
  TiasTarotReadingType getByName(name) {
    if(name == TiasTarotReadingType.generalReading.name) {
      return TiasTarotReadingType.generalReading;
    } else if(name == TiasTarotReadingType.dailyReading.name) {
      return TiasTarotReadingType.dailyReading;
    } else if(name == TiasTarotReadingType.horseshoeReading.name) {
      return TiasTarotReadingType.horseshoeReading;
    } else {
      return TiasTarotReadingType.actionOutcomeReading;
    }
  }


}