class GuideBookModel {
  final int bookId;
  final String title;
  final String subtitle;
  final String iconName;
  final String colorHex;
  final String fileUrl;
  final String category;

  GuideBookModel({
    required this.bookId,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorHex,
    required this.fileUrl,
    required this.category,
  });

  factory GuideBookModel.fromMap(Map<String, dynamic> map) => GuideBookModel(
    bookId: map['BookID'] ?? 0,
    title: map['Title'] ?? '',
    subtitle: map['Subtitle'] ?? '',
    iconName: map['IconName'] ?? '',
    colorHex: map['ColorHex'] ?? '',
    fileUrl: map['FileUrl'] ?? '',
    category: map['Category'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'BookID': bookId,
    'Title': title,
    'Subtitle': subtitle,
    'IconName': iconName,
    'ColorHex': colorHex,
    'FileUrl': fileUrl,
    'Category': category,
  };
}
