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

class QrAttendanceSettingsResponseModel {
  bool? success;
  String? message;
  QrAttendanceSettingsData? data;

  QrAttendanceSettingsResponseModel({
    this.success,
    this.message,
    this.data,
  });

  QrAttendanceSettingsResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = QrAttendanceSettingsData.fromJson(Map<String, dynamic>.from(json['data']));
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

class QrAttendanceSettingsData {
  bool? qrAttendanceEnabled;
  bool? canScan;
  String? permissionMessage;
  bool? autoAbsentEnabled;
  String? autoAbsentCutoffTime;
  ScannerInfo? scannerInfo;
  QrSettingsStats? stats;

  QrAttendanceSettingsData({
    this.qrAttendanceEnabled,
    this.canScan,
    this.permissionMessage,
    this.autoAbsentEnabled,
    this.autoAbsentCutoffTime,
    this.scannerInfo,
    this.stats,
  });

  QrAttendanceSettingsData.fromJson(Map<String, dynamic> json) {
    qrAttendanceEnabled = _parseBool(json['qr_attendance_enabled']);
    canScan = _parseBool(json['can_scan']);
    permissionMessage = json['permission_message']?.toString();
    autoAbsentEnabled = _parseBool(json['auto_absent_enabled']);
    autoAbsentCutoffTime = json['auto_absent_cutoff_time']?.toString();

    if (json['scanner_info'] != null && json['scanner_info'] is Map<String, dynamic>) {
      scannerInfo = ScannerInfo.fromJson(Map<String, dynamic>.from(json['scanner_info']));
    }

    if (json['stats'] != null && json['stats'] is Map<String, dynamic>) {
      stats = QrSettingsStats.fromJson(Map<String, dynamic>.from(json['stats']));
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

class QrSettingsStats {
  int? scannedByMeToday;
  int? totalPresentToday;

  QrSettingsStats({
    this.scannedByMeToday,
    this.totalPresentToday,
  });

  QrSettingsStats.fromJson(Map<String, dynamic> json) {
    scannedByMeToday = _parseInt(json['scanned_by_me_today'] ?? json['scanned_today']);
    totalPresentToday = _parseInt(json['total_present_today'] ?? json['present_today']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['scanned_by_me_today'] = scannedByMeToday;
    map['total_present_today'] = totalPresentToday;
    return map;
  }
}
