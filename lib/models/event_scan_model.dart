class EventScanResponseModel {
  final bool? success;
  final String? message;
  final EventScanData? data;

  EventScanResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory EventScanResponseModel.fromJson(Map<String, dynamic> json) {
    return EventScanResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] is Map<String, dynamic>)
          ? EventScanData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class EventScanData {
  final int? totalValidScansToday;
  final List<EventScanItem>? scans;

  EventScanData({
    this.totalValidScansToday,
    this.scans,
  });

  factory EventScanData.fromJson(Map<String, dynamic> json) {
    return EventScanData(
      totalValidScansToday: json['total_valid_scans_today'] is int
          ? json['total_valid_scans_today']
          : int.tryParse(json['total_valid_scans_today']?.toString() ?? ''),
      scans: (json['scans'] is List)
          ? (json['scans'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => EventScanItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_valid_scans_today': totalValidScansToday,
      'scans': scans?.map((v) => v.toJson()).toList(),
    };
  }
}

class EventScanItem {
  final dynamic id;
  final String? passNumber;
  final String? eventTitle;
  final String? studentName;
  final String? admissionNo;
  final String? classSection;
  final String? scanStatus;
  final String? scanMessage;
  final String? gateName;
  final String? scannedBy;
  final String? scannedAt;
  final String? scannedAtFull;

  EventScanItem({
    this.id,
    this.passNumber,
    this.eventTitle,
    this.studentName,
    this.admissionNo,
    this.classSection,
    this.scanStatus,
    this.scanMessage,
    this.gateName,
    this.scannedBy,
    this.scannedAt,
    this.scannedAtFull,
  });

  factory EventScanItem.fromJson(Map<String, dynamic> json) {
    return EventScanItem(
      id: json['id'],
      passNumber: (json['pass_number'] ?? json['pass_no'])?.toString(),
      eventTitle: (json['event_title'] ?? json['title'])?.toString(),
      studentName: json['student_name']?.toString(),
      admissionNo: (json['admission_no'] ?? json['admission_number'])?.toString(),
      classSection: json['class_section']?.toString(),
      scanStatus: json['scan_status']?.toString(),
      scanMessage: (json['scan_message'] ?? json['message'])?.toString(),
      gateName: json['gate_name']?.toString(),
      scannedBy: json['scanned_by']?.toString(),
      scannedAt: json['scanned_at']?.toString(),
      scannedAtFull: json['scanned_at_full']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pass_number': passNumber,
      'event_title': eventTitle,
      'student_name': studentName,
      'admission_no': admissionNo,
      'class_section': classSection,
      'scan_status': scanStatus,
      'scan_message': scanMessage,
      'gate_name': gateName,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt,
      'scanned_at_full': scannedAtFull,
    };
  }
}

// -------------------------------------------------------------
// EVENT PASS SCAN RESULT DETAILS MODELS
// -------------------------------------------------------------
class PassScanResultModel {
  final bool? success;
  final String? message;
  final bool? isAlreadyCheckedIn;
  final bool? canCheckin;
  final String? warning;
  final PassScanResultData? data;

  PassScanResultModel({
    this.success,
    this.message,
    this.isAlreadyCheckedIn,
    this.canCheckin,
    this.warning,
    this.data,
  });

  factory PassScanResultModel.fromJson(Map<String, dynamic> json) {
    String? msg = json['message']?.toString() ?? json['scan_message']?.toString();
    if ((msg == null || msg.isEmpty) && json['data'] is Map<String, dynamic>) {
      msg = json['data']['scan_message']?.toString() ?? json['data']['message']?.toString();
    }

    return PassScanResultModel(
      success: json['success'] == true || json['status'] == 'success' || json['status'] == true,
      message: msg,
      isAlreadyCheckedIn: json['is_already_checked_in'] == true || json['is_already_checkedin'] == true,
      canCheckin: json['can_checkin'] == true,
      warning: json['warning']?.toString(),
      data: (json['data'] is Map<String, dynamic>)
          ? PassScanResultData.fromJson(json['data'])
          : null,
    );
  }
}

class PassScanResultData {
  final PassInfo? pass;
  final EventInfo? event;
  final StudentInfo? student;
  final List<AttendeeInfo>? approvedAttendees;
  final List<AttendeeInfo>? rejectedAttendees;

  PassScanResultData({
    this.pass,
    this.event,
    this.student,
    this.approvedAttendees,
    this.rejectedAttendees,
  });

  factory PassScanResultData.fromJson(Map<String, dynamic> json) {
    return PassScanResultData(
      pass: (json['pass'] is Map<String, dynamic>) ? PassInfo.fromJson(json['pass']) : null,
      event: (json['event'] is Map<String, dynamic>) ? EventInfo.fromJson(json['event']) : null,
      student: (json['student'] is Map<String, dynamic>) ? StudentInfo.fromJson(json['student']) : null,
      approvedAttendees: (json['approved_attendees'] is List)
          ? (json['approved_attendees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => AttendeeInfo.fromJson(i))
              .toList()
          : null,
      rejectedAttendees: (json['rejected_attendees'] is List)
          ? (json['rejected_attendees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => AttendeeInfo.fromJson(i))
              .toList()
          : null,
    );
  }
}

class PassInfo {
  final dynamic id;
  final String? uuid;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;
  final String? firstCheckinAt;
  final int? totalAttendeesRequested;
  final int? totalAttendeesApproved;
  final int? totalCheckedIn;
  final int? totalRemaining;

  PassInfo({
    this.id,
    this.uuid,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.firstCheckinAt,
    this.totalAttendeesRequested,
    this.totalAttendeesApproved,
    this.totalCheckedIn,
    this.totalRemaining,
  });

  factory PassInfo.fromJson(Map<String, dynamic> json) {
    return PassInfo(
      id: json['id'],
      uuid: json['uuid']?.toString(),
      passNumber: (json['pass_number'] ?? json['pass_no'])?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      firstCheckinAt: json['first_checkin_at']?.toString(),
      totalAttendeesRequested: json['total_attendees_requested'] is int
          ? json['total_attendees_requested']
          : int.tryParse(json['total_attendees_requested']?.toString() ?? ''),
      totalAttendeesApproved: json['total_attendees_approved'] is int
          ? json['total_attendees_approved']
          : int.tryParse(json['total_attendees_approved']?.toString() ?? ''),
      totalCheckedIn: json['total_checked_in'] is int
          ? json['total_checked_in']
          : int.tryParse(json['total_checked_in']?.toString() ?? ''),
      totalRemaining: json['total_remaining'] is int
          ? json['total_remaining']
          : int.tryParse(json['total_remaining']?.toString() ?? ''),
    );
  }
}

class EventInfo {
  final dynamic id;
  final String? title;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;

  EventInfo({
    this.id,
    this.title,
    this.venue,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      id: json['id'],
      title: json['title']?.toString(),
      venue: json['venue']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
    );
  }
}

class StudentInfo {
  final dynamic id;
  final String? studentName;
  final String? admissionNumber;
  final String? rollNo;
  final String? studentUniqueId;
  final String? studentClass;
  final String? section;
  final String? classSection;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherName;
  final String? motherMobile;
  final String? photoUrl;

  StudentInfo({
    this.id,
    this.studentName,
    this.admissionNumber,
    this.rollNo,
    this.studentUniqueId,
    this.studentClass,
    this.section,
    this.classSection,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.photoUrl,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'],
      studentName: json['student_name']?.toString(),
      admissionNumber: (json['admission_number'] ?? json['admission_no'])?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      studentClass: json['class']?.toString(),
      section: json['section']?.toString(),
      classSection: json['class_section']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class AttendeeInfo {
  final dynamic id;
  final String? name;
  final String? personType;
  final String? mobileNo;
  final String? maskedAadhaar;
  final String? photoUrl;
  final bool? isCheckedIn;
  final String? checkedInAt;

  AttendeeInfo({
    this.id,
    this.name,
    this.personType,
    this.mobileNo,
    this.maskedAadhaar,
    this.photoUrl,
    this.isCheckedIn,
    this.checkedInAt,
  });

  factory AttendeeInfo.fromJson(Map<String, dynamic> json) {
    return AttendeeInfo(
      id: json['id'],
      name: json['name']?.toString(),
      personType: json['person_type']?.toString(),
      mobileNo: (json['mobile_no'] ?? json['mobile'])?.toString(),
      maskedAadhaar: json['masked_aadhaar']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      isCheckedIn: json['is_checked_in'] == true || json['is_checkedin'] == true,
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }
}
