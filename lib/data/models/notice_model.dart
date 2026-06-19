class NoticeModel {
  final String noticeId;
  final String subject;
  final String audience;
  final String body;
  final String attachmentUrl;
  final bool urgent;

  NoticeModel({
    required this.noticeId,
    required this.subject,
    required this.audience,
    required this.body,
    required this.attachmentUrl,
    required this.urgent,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      noticeId: map['NoticeID'] ?? map['noticeId'] ?? '',
      subject: map['Subject'] ?? map['Title'] ?? map['subject'] ?? '',
      audience: map['Audience'] ?? map['TargetAudience'] ?? map['audience'] ?? '',
      body: map['NoticeBody'] ?? map['Content'] ?? map['body'] ?? '',
      attachmentUrl: map['attachmentUrl'] ?? '',
      urgent: (map['IsUrgent'] == 1 || map['IsUrgent'] == true || map['IsPinned'] == 1 || map['IsPinned'] == true) || (map['urgent'] ?? false),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noticeId': noticeId,
      'subject': subject,
      'audience': audience,
      'body': body,
      'attachmentUrl': attachmentUrl,
      'urgent': urgent,
    };
  }
}
