export 'qr_attendance_settings_model.dart';
export 'qr_scan_attendance_model.dart';

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

class ScanAttendanceResponseModel {
  bool? success;
  String? message;
  ScanAttendanceData? data;

  ScanAttendanceResponseModel({this.success, this.message, this.data});

  ScanAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = ScanAttendanceData.fromJson(Map<String, dynamic>.from(json['data']));
    } else if (json['logs'] != null && json['logs'] is List) {
      data = ScanAttendanceData.fromJson({'logs': json['logs']});
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class ScanAttendanceData {
  bool? qrAttendanceEnabled;
  bool? canScan;
  String? permissionMessage;
  bool? autoAbsentEnabled;
  String? autoAbsentCutoffTime;
  ScannerInfo? scannerInfo;
  ScanAttendanceStats? stats;
  String? date;
  List<AttendanceRecordItem>? logs;

  ScanAttendanceData({
    this.qrAttendanceEnabled,
    this.canScan,
    this.permissionMessage,
    this.autoAbsentEnabled,
    this.autoAbsentCutoffTime,
    this.scannerInfo,
    this.stats,
    this.date,
    this.logs,
  });

  ScanAttendanceData.fromJson(Map<String, dynamic> json) {
    qrAttendanceEnabled = _parseBool(json['qr_attendance_enabled']);
    canScan = _parseBool(json['can_scan']);
    permissionMessage = json['permission_message']?.toString();
    autoAbsentEnabled = _parseBool(json['auto_absent_enabled']);
    autoAbsentCutoffTime = json['auto_absent_cutoff_time']?.toString();

    if (json['scanner_info'] != null && json['scanner_info'] is Map<String, dynamic>) {
      scannerInfo = ScannerInfo.fromJson(Map<String, dynamic>.from(json['scanner_info']));
    }

    if (json['stats'] != null && json['stats'] is Map<String, dynamic>) {
      stats = ScanAttendanceStats.fromJson(Map<String, dynamic>.from(json['stats']));
    }

    date = json['date']?.toString();

    if (json['logs'] != null && json['logs'] is List) {
      logs = (json['logs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => AttendanceRecordItem.fromJson(i))
          .toList();
    } else if (json['records'] != null && json['records'] is List) {
      logs = (json['records'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => AttendanceRecordItem.fromJson(i))
          .toList();
    } else {
      logs = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['qr_attendance_enabled'] = qrAttendanceEnabled;
    map['can_scan'] = canScan;
    map['permission_message'] = permissionMessage;
    map['auto_absent_enabled'] = autoAbsentEnabled;
    map['auto_absent_cutoff_time'] = autoAbsentCutoffTime;
    if (scannerInfo != null) {
      map['scanner_info'] = scannerInfo!.toJson();
    }
    if (stats != null) {
      map['stats'] = stats!.toJson();
    }
    map['date'] = date;
    if (logs != null) {
      map['logs'] = logs!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ScannerInfo {
  String? appRole;
  String? scannerRole;
  int? userId;
  String? userName;

  ScannerInfo({
    this.appRole,
    this.scannerRole,
    this.userId,
    this.userName,
  });

  ScannerInfo.fromJson(Map<String, dynamic> json) {
    appRole = json['app_role']?.toString();
    scannerRole = json['scanner_role']?.toString();
    userId = _parseInt(json['user_id']);
    userName = json['user_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['app_role'] = appRole;
    map['scanner_role'] = scannerRole;
    map['user_id'] = userId;
    map['user_name'] = userName;
    return map;
  }
}

class ScanAttendanceStats {
  int? scannedByMeToday;
  int? totalPresentToday;
  int? totalScans;
  int? studentScans;
  int? teacherScans;
  int? checkIns;
  int? checkOuts;

  ScanAttendanceStats({
    this.scannedByMeToday,
    this.totalPresentToday,
    this.totalScans,
    this.studentScans,
    this.teacherScans,
    this.checkIns,
    this.checkOuts,
  });

  ScanAttendanceStats.fromJson(Map<String, dynamic> json) {
    scannedByMeToday = _parseInt(json['scanned_by_me_today'] ?? json['my_scans']);
    totalPresentToday = _parseInt(json['total_present_today'] ?? json['present_today']);
    totalScans = _parseInt(json['total_scans'] ?? json['total_count'] ?? json['total']);
    studentScans = _parseInt(json['student_scans'] ?? json['students_count'] ?? json['students']);
    teacherScans = _parseInt(json['teacher_scans'] ?? json['teachers_count'] ?? json['teachers']);
    checkIns = _parseInt(json['check_ins'] ?? json['check_in_count'] ?? json['check_ins_count']);
    checkOuts = _parseInt(json['check_outs'] ?? json['check_out_count'] ?? json['check_outs_count']);
  }

  Map<String, dynamic> toJson() {
    return {
      'scanned_by_me_today': scannedByMeToday,
      'total_present_today': totalPresentToday,
      'total_scans': totalScans,
      'student_scans': studentScans,
      'teacher_scans': teacherScans,
      'check_ins': checkIns,
      'check_outs': checkOuts,
    };
  }
}

class AttendanceRecordItem {
  int? id;
  String? code;
  String? name;
  String? userType; // 'student' or 'teacher'
  String? avatar;
  String? className;
  String? sectionName;
  String? rollNo;
  String? designation;
  String? attendanceType; // 'check_in' or 'check_out'
  String? status; // 'Present', 'Late', 'Out', etc.
  String? date;
  String? time;
  String? remarks;

  AttendanceRecordItem({
    this.id,
    this.code,
    this.name,
    this.userType,
    this.avatar,
    this.className,
    this.sectionName,
    this.rollNo,
    this.designation,
    this.attendanceType,
    this.status,
    this.date,
    this.time,
    this.remarks,
  });

  AttendanceRecordItem.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    code = json['code']?.toString() ?? json['student_id']?.toString() ?? json['teacher_id']?.toString() ?? json['qr_code']?.toString();
    name = json['name']?.toString() ?? json['student_name']?.toString() ?? json['teacher_name']?.toString() ?? 'N/A';
    userType = json['user_type']?.toString() ?? json['type']?.toString() ?? (json['class_name'] != null ? 'student' : 'teacher');
    avatar = json['avatar']?.toString() ?? json['photo']?.toString() ?? json['image']?.toString();
    className = json['class_name']?.toString();
    sectionName = json['section_name']?.toString();
    rollNo = json['roll_no']?.toString();
    designation = json['designation']?.toString() ?? json['role']?.toString();
    attendanceType = json['attendance_type']?.toString() ?? json['type_action']?.toString() ?? 'check_in';
    status = json['status']?.toString() ?? 'Present';
    date = json['date']?.toString();
    time = json['time']?.toString() ?? json['scanned_at']?.toString();
    remarks = json['remarks']?.toString() ?? json['notes']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'user_type': userType,
      'avatar': avatar,
      'class_name': className,
      'section_name': sectionName,
      'roll_no': rollNo,
      'designation': designation,
      'attendance_type': attendanceType,
      'status': status,
      'date': date,
      'time': time,
      'remarks': remarks,
    };
  }

  String get subInfo {
    if (userType?.toLowerCase() == 'student') {
      List<String> parts = [];
      if (className != null && className!.isNotEmpty) parts.add('Class $className');
      if (sectionName != null && sectionName!.isNotEmpty) parts.add('Sec $sectionName');
      if (rollNo != null && rollNo!.isNotEmpty) parts.add('Roll: $rollNo');
      return parts.isNotEmpty ? parts.join(' • ') : 'Student';
    } else {
      return designation ?? 'Teacher / Staff';
    }
  }

  bool get isCheckIn => attendanceType?.toLowerCase() == 'check_in' || attendanceType?.toLowerCase() == 'in';
}

class ScanSubmitResponseModel {
  bool? success;
  String? message;
  AttendanceRecordItem? record;

  ScanSubmitResponseModel({this.success, this.message, this.record});

  ScanSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      record = AttendanceRecordItem.fromJson(Map<String, dynamic>.from(json['data']));
    } else if (json['record'] != null && json['record'] is Map<String, dynamic>) {
      record = AttendanceRecordItem.fromJson(Map<String, dynamic>.from(json['record']));
    }
  }
}
