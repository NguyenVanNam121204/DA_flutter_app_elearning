class FlashcardModel {
  const FlashcardModel({
    required this.flashCardId,
    required this.term,
    required this.definition,
    required this.pronunciation,
    required this.exampleSentence,
    required this.audioUrl,
    required this.imageUrl,
  });

  final String flashCardId;
  final String term;
  final String definition;
  final String pronunciation;
  final String exampleSentence;
  final String audioUrl;
  final String imageUrl;

  String get reviewFront => term;
  String get reviewBack => definition;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      flashCardId:
          (json['flashCardId'] ?? json['FlashCardId'] ?? json['id'] ?? '')
              .toString(),
      term:
          (json['term'] ??
                  json['Term'] ??
                  json['frontText'] ??
                  json['word'] ??
                  json['Word'] ??
                  '')
              .toString(),
      definition:
          (json['definition'] ??
                  json['Definition'] ??
                  json['backText'] ??
                  json['meaning'] ??
                  json['Meaning'] ??
                  '')
              .toString(),
      pronunciation: (json['pronunciation'] ?? json['Pronunciation'] ?? '')
          .toString(),
      exampleSentence:
          (json['exampleSentence'] ?? json['ExampleSentence'] ?? '').toString(),
      audioUrl: (json['audioUrl'] ?? json['AudioUrl'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? '').toString(),
    );
  }
}
