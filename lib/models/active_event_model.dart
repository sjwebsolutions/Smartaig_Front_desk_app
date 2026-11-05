class ActiveEventResponseModel {
  final bool? success;
  final String? message;
  final List<ActiveEventItem>? data;

  ActiveEventResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory ActiveEventResponseModel.fromJson(Map<String, dynamic> json) {
    return ActiveEventResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] is List)
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => ActiveEventItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class ActiveEventItem {
  final dynamic id;
  final String? eventCode;
  final String? title;
  final String? subTitle;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? registrationDeadline;
  final int? maxGuestsPerStudent;
  final bool? requiresApproval;
  final bool? requireAadhaar;
  final bool? requirePhoto;
  final bool? allowMultipleCheckins;
  final String? bannerUrl;
  final LiveTelecastInfo? liveTelecast;

  ActiveEventItem({
    this.id,
    this.eventCode,
    this.title,
    this.subTitle,
    this.venue,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.registrationDeadline,
    this.maxGuestsPerStudent,
    this.requiresApproval,
    this.requireAadhaar,
    this.requirePhoto,
    this.allowMultipleCheckins,
    this.bannerUrl,
    this.liveTelecast,
  });

  factory ActiveEventItem.fromJson(Map<String, dynamic> json) {
    return ActiveEventItem(
      id: json['id'],
      eventCode: json['event_code']?.toString(),
      title: json['title']?.toString(),
      subTitle: json['sub_title']?.toString(),
      venue: json['venue']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      registrationDeadline: json['registration_deadline']?.toString(),
      maxGuestsPerStudent: json['max_guests_per_student'] is int
          ? json['max_guests_per_student']
          : int.tryParse(json['max_guests_per_student']?.toString() ?? ''),
      requiresApproval: json['requires_approval'] == true,
      requireAadhaar: json['require_aadhaar'] == true,
      requirePhoto: json['require_photo'] == true,
      allowMultipleCheckins: json['allow_multiple_checkins'] == true,
      bannerUrl: json['banner_url']?.toString(),
      liveTelecast: (json['live_telecast'] is Map<String, dynamic>)
          ? LiveTelecastInfo.fromJson(json['live_telecast'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_code': eventCode,
      'title': title,
      'sub_title': subTitle,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'registration_deadline': registrationDeadline,
      'max_guests_per_student': maxGuestsPerStudent,
      'requires_approval': requiresApproval,
      'require_aadhaar': requireAadhaar,
      'require_photo': requirePhoto,
      'allow_multiple_checkins': allowMultipleCheckins,
      'banner_url': bannerUrl,
      'live_telecast': liveTelecast?.toJson(),
    };
  }
}

class LiveTelecastInfo {
  final bool? isLive;
  final String? youtubeUrl;
  final String? youtubeVideoId;
  final String? embedUrl;
  final String? title;
  final String? startedAt;
  final String? endedAt;

  LiveTelecastInfo({
    this.isLive,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.embedUrl,
    this.title,
    this.startedAt,
    this.endedAt,
  });

  factory LiveTelecastInfo.fromJson(Map<String, dynamic> json) {
    return LiveTelecastInfo(
      isLive: json['is_live'] == true,
      youtubeUrl: json['youtube_url']?.toString(),
      youtubeVideoId: json['youtube_video_id']?.toString(),
      embedUrl: json['embed_url']?.toString(),
      title: json['title']?.toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_live': isLive,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'embed_url': embedUrl,
      'title': title,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }
}
