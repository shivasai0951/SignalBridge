class CallLogModel {
  int? id;
  String contactId;
  String callType;
  String mediaType;
  DateTime timestamp;
  int duration;

  CallLogModel({
    this.id,
    required this.contactId,
    required this.callType,
    required this.mediaType,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'callType': callType,
      'mediaType': mediaType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'duration': duration,
    };
  }

  factory CallLogModel.fromMap(Map<String, dynamic> map) {
    return CallLogModel(
      id: map['id'],
      contactId: map['contactId'],
      callType: map['callType'],
      mediaType: map['mediaType'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      duration: map['duration'],
    );
  }
}
