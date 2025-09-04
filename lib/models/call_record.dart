import 'package:uuid/uuid.dart';

class CallRecord {
  final String id;
  final List<String> participants;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? transcription;
  final String? aiSummary;
  final String callType; // 'video', 'audio'

  CallRecord({
    String? id,
    required this.participants,
    DateTime? startTime,
    this.endTime,
    this.duration,
    this.transcription,
    this.aiSummary,
    this.callType = 'video',
  }) : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants.join(','),
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'duration': duration?.inSeconds,
      'transcription': transcription,
      'ai_summary': aiSummary,
      'call_type': callType,
    };
  }

  factory CallRecord.fromMap(Map<String, dynamic> map) {
    return CallRecord(
      id: map['id'],
      participants: map['participants'].split(','),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      duration: map['duration'] != null 
          ? Duration(seconds: map['duration'])
          : null,
      transcription: map['transcription'],
      aiSummary: map['ai_summary'],
      callType: map['call_type'] ?? 'video',
    );
  }

  CallRecord copyWith({
    String? id,
    List<String>? participants,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? transcription,
    String? aiSummary,
    String? callType,
  }) {
    return CallRecord(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      transcription: transcription ?? this.transcription,
      aiSummary: aiSummary ?? this.aiSummary,
      callType: callType ?? this.callType,
    );
  }
}
