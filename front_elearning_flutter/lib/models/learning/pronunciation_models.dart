class PronunciationItemModel {
  const PronunciationItemModel({
    required this.pronunciationId,
    required this.word,
    required this.ipa,
    required this.audioUrl,
  });

  final String pronunciationId;
  final String word;
  final String ipa;
  final String audioUrl;

  factory PronunciationItemModel.fromJson(Map<String, dynamic> json) {
    return PronunciationItemModel(
      pronunciationId:
          (json['pronunciationId'] ?? json['PronunciationId'] ?? '').toString(),
      word: (json['word'] ?? json['Word'] ?? 'Word').toString(),
      ipa: (json['ipa'] ?? json['Ipa'] ?? '').toString(),
      audioUrl: (json['audioUrl'] ?? json['AudioUrl'] ?? '').toString(),
    );
  }
}

class PronunciationDetailModel {
  const PronunciationDetailModel({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.audioUrl,
    required this.exampleSentence,
    required this.imageUrl,
  });

  final String word;
  final String ipa;
  final String meaning;
  final String audioUrl;
  final String exampleSentence;
  final String imageUrl;

  factory PronunciationDetailModel.fromJson(Map<String, dynamic> json) {
    return PronunciationDetailModel(
      word: (json['word'] ?? json['Word'] ?? '').toString(),
      ipa: (json['ipa'] ?? json['Ipa'] ?? '').toString(),
      meaning: (json['meaning'] ?? json['Meaning'] ?? '').toString(),
      audioUrl: (json['audioUrl'] ?? json['AudioUrl'] ?? '').toString(),
      exampleSentence:
          (json['exampleSentence'] ?? json['ExampleSentence'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? '').toString(),
    );
  }
}
