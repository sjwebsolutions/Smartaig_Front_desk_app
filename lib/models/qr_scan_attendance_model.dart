import 'scan_attendance_model.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString().trim());
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  final str = value.toString().toLowerCase().trim();
  return str == 'true' || str == '1' || str == 'yes';
}

class QrScanAttendanceResponseModel {
  bool? success;
  bool? alreadyMarked;
  String? message;
  QrScanAttendanceData? data;

  QrScanAttendanceResponseModel({
    this.success,
    this.alreadyMarked,
    this.message,
    this.data,
  });

  QrScanAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    alreadyMarked = _parseBool(json['already_marked'] ?? json['is_already_marked']) ?? false;
    message = json['message']?.toString() ?? json['msg']?.toString();

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = QrScanAttendanceData.fromJson(Map<String, dynamic>.from(json['data']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['already_marked'] = alreadyMarked;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class QrScanAttendanceData {
  StudentScanInfo? student;
  AttendanceScanInfo? attendance;
  bool? onLeaveWarning;
  dynamic leaveDetails;

  QrScanAttendanceData({
    this.student,
    this.attendance,
    this.onLeaveWarning,
    this.leaveDetails,
  });

  QrScanAttendanceData.fromJson(Map<String, dynamic> json) {
    if (json['student'] != null && json['student'] is Map<String, dynamic>) {
      student = StudentScanInfo.fromJson(Map<String, dynamic>.from(json['student']));
    }

    if (json['attendance'] != null && json['attendance'] is Map<String, dynamic>) {
      attendance = AttendanceScanInfo.fromJson(Map<String, dynamic>.from(json['attendance']));
    }

    onLeaveWarning = _parseBool(json['on_leave_warning']) ?? false;
    leaveDetails = json['leave_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (student != null) {
      map['student'] = student!.toJson();
    }
    if (attendance != null) {
      map['attendance'] = attendance!.toJson();
    }
    map['on_leave_warning'] = onLeaveWarning;
    map['leave_details'] = leaveDetails;
    return map;
  }

  AttendanceRecordItem toAttendanceRecordItem() {
    return AttendanceRecordItem(
      id: attendance?.id ?? student?.id ?? DateTime.now().millisecondsSinceEpoch,
      code: student?.studentUniqueId ?? student?.admissionNumber ?? '',
      name: student?.studentName ?? 'Student',
      userType: 'student',
      avatar: student?.profileImage,
      className: student?.className,
      sectionName: student?.sectionName,
      rollNo: student?.rollNo,
      designation: null,
      attendanceType: 'check_in',
      status: attendance?.status == 'P' ? 'Present' : (attendance?.status ?? 'Present'),
      date: attendance?.date,
      time: attendance?.punchTime,
      remarks: attendance?.remarks,
    );
  }
}

class StudentScanInfo {
  int? id;
  String? studentUniqueId;
  String? studentName;
  String? studentNamePunjabi;
  String? rollNo;
  String? admissionNumber;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? streamId;
  String? streamName;
  String? gender;
  String? fatherName;
  String? fatherMobile;
  String? profileImage;

  StudentScanInfo({
    this.id,
    this.studentUniqueId,
    this.studentName,
    this.studentNamePunjabi,
    this.rollNo,
    this.admissionNumber,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.gender,
    this.fatherName,
    this.fatherMobile,
    this.profileImage,
  });

  StudentScanInfo.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    studentUniqueId = json['student_unique_id']?.toString();
    studentName = json['student_name']?.toString() ?? json['name']?.toString();
    studentNamePunjabi = json['student_name_punjabi']?.toString();
    rollNo = json['roll_no']?.toString();
    admissionNumber = json['admission_number']?.toString();
    classId = _parseInt(json['class_id']);
    className = json['class_name']?.toString();
    sectionId = _parseInt(json['section_id']);
    sectionName = json['section_name']?.toString();
    streamId = _parseInt(json['stream_id']);
    streamName = json['stream_name']?.toString();
    gender = json['gender']?.toString();
    fatherName = json['father_name']?.toString();
    fatherMobile = json['father_mobile']?.toString();
    profileImage = json['profile_image']?.toString() ?? json['photo']?.toString() ?? json['image']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_unique_id': studentUniqueId,
      'student_name': studentName,
      'student_name_punjabi': studentNamePunjabi,
      'roll_no': rollNo,
      'admission_number': admissionNumber,
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'section_name': sectionName,
      'stream_id': streamId,
      'stream_name': streamName,
      'gender': gender,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'profile_image': profileImage,
    };
  }

  String get classSectionDisplay {
    final parts = <String>[];
    if (className != null && className!.isNotEmpty) parts.add('Class $className');
    if (sectionName != null && sectionName!.isNotEmpty) parts.add('Sec $sectionName');
    if (rollNo != null && rollNo!.isNotEmpty) parts.add('Roll: $rollNo');
    return parts.isNotEmpty ? parts.join(' • ') : 'Student';
  }
}

class AttendanceScanInfo {
  int? id;
  String? status;
  String? date;
  String? punchTime;
  String? attendanceMode;
  String? markedVia;
  String? takenByName;
  String? takenByRole;
  String? remarks;

  AttendanceScanInfo({
    this.id,
    this.status,
    this.date,
    this.punchTime,
    this.attendanceMode,
    this.markedVia,
    this.takenByName,
    this.takenByRole,
    this.remarks,
  });

  AttendanceScanInfo.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    status = json['status']?.toString();
    date = json['date']?.toString();
    punchTime = json['punch_time']?.toString() ?? json['time']?.toString();
    attendanceMode = json['attendance_mode']?.toString();
    markedVia = json['marked_via']?.toString();
    takenByName = json['taken_by_name']?.toString();
    takenByRole = json['taken_by_role']?.toString();
    remarks = json['remarks']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date,
      'punch_time': punchTime,
      'attendance_mode': attendanceMode,
      'marked_via': markedVia,
      'taken_by_name': takenByName,
      'taken_by_role': takenByRole,
      'remarks': remarks,
    };
  }

  bool get isPresent => status?.toUpperCase() == 'P' || status?.toLowerCase() == 'present';
}
