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

// -------------------------------------------------------------
// CHECK-IN API RESPONSE MODEL
// -------------------------------------------------------------
class PassCheckinResponseModel {
  final bool? success;
  final String? message;
  final PassCheckinDataModel? data;

  PassCheckinResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory PassCheckinResponseModel.fromJson(Map<String, dynamic> json) {
    return PassCheckinResponseModel(
      success: json['success'] == true || json['status'] == 'success' || json['status'] == true,
      message: json['message']?.toString(),
      data: (json['data'] is Map<String, dynamic>)
          ? PassCheckinDataModel.fromJson(json['data'])
          : null,
    );
  }
}

class PassCheckinDataModel {
  final String? passNumber;
  final String? checkinStatus;
  final int? admittedCount;
  final List<String>? admittedAttendees;
  final int? totalCheckedIn;
  final int? totalApproved;
  final String? checkedInAt;
  final String? gateName;

  PassCheckinDataModel({
    this.passNumber,
    this.checkinStatus,
    this.admittedCount,
    this.admittedAttendees,
    this.totalCheckedIn,
    this.totalApproved,
    this.checkedInAt,
    this.gateName,
  });

  factory PassCheckinDataModel.fromJson(Map<String, dynamic> json) {
    return PassCheckinDataModel(
      passNumber: (json['pass_number'] ?? json['pass_no'])?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      admittedCount: json['admitted_count'] is int
          ? json['admitted_count']
          : int.tryParse(json['admitted_count']?.toString() ?? ''),
      admittedAttendees: (json['admitted_attendees'] is List)
          ? (json['admitted_attendees'] as List).map((e) => e.toString()).toList()
          : null,
      totalCheckedIn: json['total_checked_in'] is int
          ? json['total_checked_in']
          : int.tryParse(json['total_checked_in']?.toString() ?? ''),
      totalApproved: json['total_approved'] is int
          ? json['total_approved']
          : int.tryParse(json['total_approved']?.toString() ?? ''),
      checkedInAt: json['checked_in_at']?.toString(),
      gateName: json['gate_name']?.toString(),
    );
  }
}

// -------------------------------------------------------------
// EVENT STUDENT SEARCH API MODELS
// -------------------------------------------------------------
class EventSearchStudentResponseModel {
  final bool? success;
  final List<EventSearchStudentItem>? data;
  final int? totalCount;

  EventSearchStudentResponseModel({
    this.success,
    this.data,
    this.totalCount,
  });

  factory EventSearchStudentResponseModel.fromJson(Map<String, dynamic> json) {
    return EventSearchStudentResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] is List)
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => EventSearchStudentItem.fromJson(i))
              .toList()
          : null,
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? ''),
    );
  }
}

class EventSearchStudentItem {
  final dynamic id;
  final String? studentName;
  final String? admissionNumber;
  final String? rollNo;
  final String? studentUniqueId;
  final String? className;
  final String? sectionName;
  final String? streamName;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherName;
  final String? motherMobile;
  final String? whatsappNo;
  final String? studentAadhaar;
  final String? fatherAadhaar;
  final String? motherAadhaar;
  final String? studentPhotoUrl;
  final String? fatherPhotoUrl;
  final String? motherPhotoUrl;
  final bool? passExists;
  final dynamic passId;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;

  EventSearchStudentItem({
    this.id,
    this.studentName,
    this.admissionNumber,
    this.rollNo,
    this.studentUniqueId,
    this.className,
    this.sectionName,
    this.streamName,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.whatsappNo,
    this.studentAadhaar,
    this.fatherAadhaar,
    this.motherAadhaar,
    this.studentPhotoUrl,
    this.fatherPhotoUrl,
    this.motherPhotoUrl,
    this.passExists,
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
  });

  factory EventSearchStudentItem.fromJson(Map<String, dynamic> json) {
    return EventSearchStudentItem(
      id: json['id'],
      studentName: json['student_name']?.toString(),
      admissionNumber: json['admission_number']?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      streamName: json['stream_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      whatsappNo: json['whatsapp_no']?.toString(),
      studentAadhaar: json['student_aadhaar']?.toString(),
      fatherAadhaar: json['father_aadhaar']?.toString(),
      motherAadhaar: json['mother_aadhaar']?.toString(),
      studentPhotoUrl: json['student_photo_url']?.toString(),
      fatherPhotoUrl: json['father_photo_url']?.toString(),
      motherPhotoUrl: json['mother_photo_url']?.toString(),
      passExists: json['pass_exists'] == true,
      passId: json['pass_id'],
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
    );
  }
}

// -------------------------------------------------------------
// EVENT PASS APPLICATIONS API MODELS (/events/passes/applications)
// -------------------------------------------------------------
class PassApplicationResponseModel {
  final bool? success;
  final List<PassApplicationItem>? data;
  final int? currentPage;
  final int? perPage;
  final int? totalCount;
  final int? totalPages;

  PassApplicationResponseModel({
    this.success,
    this.data,
    this.currentPage,
    this.perPage,
    this.totalCount,
    this.totalPages,
  });

  factory PassApplicationResponseModel.fromJson(Map<String, dynamic> json) {
    return PassApplicationResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] is List)
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => PassApplicationItem.fromJson(i))
              .toList()
          : null,
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? ''),
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? ''),
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? ''),
      totalPages: json['total_pages'] is int
          ? json['total_pages']
          : int.tryParse(json['total_pages']?.toString() ?? ''),
    );
  }
}

class PassApplicationItem {
  final dynamic id;
  final String? uuid;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;
  final int? totalAttendeesRequested;
  final int? totalAttendeesApproved;
  final String? createdAt;
  final String? actionAt;
  final String? actionByName;
  final String? actionByRole;
  final String? adminRemarks;
  final PassAppStudent? student;
  final List<PassAppAttendee>? attendees;

  PassApplicationItem({
    this.id,
    this.uuid,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.totalAttendeesRequested,
    this.totalAttendeesApproved,
    this.createdAt,
    this.actionAt,
    this.actionByName,
    this.actionByRole,
    this.adminRemarks,
    this.student,
    this.attendees,
  });

  factory PassApplicationItem.fromJson(Map<String, dynamic> json) {
    return PassApplicationItem(
      id: json['id'],
      uuid: json['uuid']?.toString(),
      passNumber: (json['pass_number'] ?? json['pass_no'])?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      totalAttendeesRequested: json['total_attendees_requested'] is int
          ? json['total_attendees_requested']
          : int.tryParse(json['total_attendees_requested']?.toString() ?? ''),
      totalAttendeesApproved: json['total_attendees_approved'] is int
          ? json['total_attendees_approved']
          : int.tryParse(json['total_attendees_approved']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      actionAt: json['action_at']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      adminRemarks: json['admin_remarks']?.toString(),
      student: (json['student'] is Map<String, dynamic>)
          ? PassAppStudent.fromJson(json['student'])
          : null,
      attendees: (json['attendees'] is List)
          ? (json['attendees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => PassAppAttendee.fromJson(i))
              .toList()
          : null,
    );
  }
}

class PassAppStudent {
  final dynamic id;
  final String? name;
  final String? admissionNumber;
  final String? rollNo;
  final String? studentClass;
  final String? section;
  final String? stream;
  final String? photoUrl;

  PassAppStudent({
    this.id,
    this.name,
    this.admissionNumber,
    this.rollNo,
    this.studentClass,
    this.section,
    this.stream,
    this.photoUrl,
  });

  factory PassAppStudent.fromJson(Map<String, dynamic> json) {
    return PassAppStudent(
      id: json['id'],
      name: json['name']?.toString(),
      admissionNumber: (json['admission_number'] ?? json['admission_no'])?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentClass: json['class']?.toString(),
      section: json['section']?.toString(),
      stream: json['stream']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class PassAppAttendee {
  final dynamic id;
  final String? name;
  final String? personType;
  final String? mobileNo;
  final String? whatsappNo;
  final String? aadhaarMasked;
  final String? approvalStatus;
  final String? rejectionReason;
  final bool? isCheckedIn;
  final String? checkedInAt;
  final String? photoUrl;

  PassAppAttendee({
    this.id,
    this.name,
    this.personType,
    this.mobileNo,
    this.whatsappNo,
    this.aadhaarMasked,
    this.approvalStatus,
    this.rejectionReason,
    this.isCheckedIn,
    this.checkedInAt,
    this.photoUrl,
  });

  factory PassAppAttendee.fromJson(Map<String, dynamic> json) {
    return PassAppAttendee(
      id: json['id'],
      name: json['name']?.toString(),
      personType: json['person_type']?.toString(),
      mobileNo: (json['mobile_no'] ?? json['mobile'])?.toString(),
      whatsappNo: json['whatsapp_no']?.toString(),
      aadhaarMasked: json['aadhaar_masked']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      isCheckedIn: json['is_checked_in'] == true || json['is_checkedin'] == true,
      checkedInAt: json['checked_in_at']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

// -------------------------------------------------------------
// ISSUE WALK-IN PASS API MODELS (/events/passes/issue-walk-in)
// -------------------------------------------------------------
class IssueWalkInPassResponseModel {
  final bool? success;
  final String? message;
  final IssueWalkInPassData? data;

  IssueWalkInPassResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory IssueWalkInPassResponseModel.fromJson(Map<String, dynamic> json) {
    return IssueWalkInPassResponseModel(
      success: json['success'] == true || json['status'] == 'success' || json['status'] == true,
      message: json['message']?.toString(),
      data: (json['data'] is Map<String, dynamic>)
          ? IssueWalkInPassData.fromJson(json['data'])
          : null,
    );
  }
}

class IssueWalkInPassData {
  final dynamic passId;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;
  final String? qrPayload;
  final WalkInPassStudent? student;
  final List<WalkInPassAttendee>? attendees;
  final WalkInPassGateEntry? gateEntry;

  IssueWalkInPassData({
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.qrPayload,
    this.student,
    this.attendees,
    this.gateEntry,
  });

  factory IssueWalkInPassData.fromJson(Map<String, dynamic> json) {
    return IssueWalkInPassData(
      passId: json['pass_id'] ?? json['id'],
      passNumber: (json['pass_number'] ?? json['pass_no'])?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      qrPayload: json['qr_payload']?.toString(),
      student: (json['student'] is Map<String, dynamic>)
          ? WalkInPassStudent.fromJson(json['student'])
          : null,
      attendees: (json['attendees'] is List)
          ? (json['attendees'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => WalkInPassAttendee.fromJson(i))
              .toList()
          : null,
      gateEntry: (json['gate_entry'] is Map<String, dynamic>)
          ? WalkInPassGateEntry.fromJson(json['gate_entry'])
          : null,
    );
  }
}

class WalkInPassStudent {
  final dynamic id;
  final String? name;
  final String? studentClass;
  final String? section;

  WalkInPassStudent({
    this.id,
    this.name,
    this.studentClass,
    this.section,
  });

  factory WalkInPassStudent.fromJson(Map<String, dynamic> json) {
    return WalkInPassStudent(
      id: json['id'],
      name: json['name']?.toString(),
      studentClass: json['class']?.toString(),
      section: json['section']?.toString(),
    );
  }
}

class WalkInPassAttendee {
  final dynamic id;
  final String? name;
  final String? personType;
  final String? mobileNo;
  final bool? isCheckedIn;
  final String? photoUrl;

  WalkInPassAttendee({
    this.id,
    this.name,
    this.personType,
    this.mobileNo,
    this.isCheckedIn,
    this.photoUrl,
  });

  factory WalkInPassAttendee.fromJson(Map<String, dynamic> json) {
    return WalkInPassAttendee(
      id: json['id'],
      name: json['name']?.toString(),
      personType: json['person_type']?.toString(),
      mobileNo: (json['mobile_no'] ?? json['mobile'])?.toString(),
      isCheckedIn: json['is_checked_in'] == true || json['is_checkedin'] == true,
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class WalkInPassGateEntry {
  final bool? isCheckedIn;
  final String? gateName;
  final int? checkedInCount;
  final String? checkedInAt;

  WalkInPassGateEntry({
    this.isCheckedIn,
    this.gateName,
    this.checkedInCount,
    this.checkedInAt,
  });

  factory WalkInPassGateEntry.fromJson(Map<String, dynamic> json) {
    return WalkInPassGateEntry(
      isCheckedIn: json['is_checked_in'] == true || json['is_checkedin'] == true,
      gateName: json['gate_name']?.toString(),
      checkedInCount: json['checked_in_count'] is int
          ? json['checked_in_count']
          : int.tryParse(json['checked_in_count']?.toString() ?? ''),
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }
}

// -------------------------------------------------------------
// UPDATE PASS STATUS API MODELS (/events/passes/update-status)
// -------------------------------------------------------------
class UpdatePassStatusResponseModel {
  final bool? success;
  final String? message;
  final String? action;
  final String? newStatus;
  final int? updatedCount;
  final List<dynamic>? updatedIds;

  UpdatePassStatusResponseModel({
    this.success,
    this.message,
    this.action,
    this.newStatus,
    this.updatedCount,
    this.updatedIds,
  });

  factory UpdatePassStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdatePassStatusResponseModel(
      success: json['success'] == true || json['status'] == 'success' || json['status'] == true,
      message: json['message']?.toString(),
      action: json['action']?.toString(),
      newStatus: json['new_status']?.toString(),
      updatedCount: json['updated_count'] is int
          ? json['updated_count']
          : int.tryParse(json['updated_count']?.toString() ?? ''),
      updatedIds: (json['updated_ids'] is List) ? json['updated_ids'] as List : null,
    );
  }
}
