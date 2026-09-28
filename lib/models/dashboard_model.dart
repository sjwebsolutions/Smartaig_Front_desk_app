int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString().trim());
}

class DashboardResponseModel {
  bool? success;
  String? message;
  DashboardData? data;

  DashboardResponseModel({this.success, this.message, this.data});

  DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    Map<String, dynamic> dataMap = {};
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      dataMap = Map<String, dynamic>.from(json['data']);
    } else if (json['result'] != null && json['result'] is Map<String, dynamic>) {
      dataMap = Map<String, dynamic>.from(json['result']);
    } else {
      dataMap = Map<String, dynamic>.from(json);
    }

    data = DashboardData.fromJson(dataMap);

    if (data?.staff != null || data?.todayStats != null || data?.callbackRequests != null) {
      success = true;
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

class DashboardData {
  DashboardStaff? staff;
  String? activeSession;
  DashboardSchool? school;
  TodayStats? todayStats;
  CallbackRequests? callbackRequests;
  TodayInfo? todayInfo;

  DashboardData({
    this.staff,
    this.activeSession,
    this.school,
    this.todayStats,
    this.callbackRequests,
    this.todayInfo,
  });

  DashboardData.fromJson(Map<String, dynamic> json) {
    staff = json['staff'] != null && json['staff'] is Map<String, dynamic>
        ? DashboardStaff.fromJson(Map<String, dynamic>.from(json['staff']))
        : null;

    activeSession = json['active_session']?.toString();

    school = json['school'] != null && json['school'] is Map<String, dynamic>
        ? DashboardSchool.fromJson(Map<String, dynamic>.from(json['school']))
        : null;

    todayStats = json['today_stats'] != null && json['today_stats'] is Map<String, dynamic>
        ? TodayStats.fromJson(Map<String, dynamic>.from(json['today_stats']))
        : null;

    callbackRequests = json['callback_requests'] != null && json['callback_requests'] is Map<String, dynamic>
        ? CallbackRequests.fromJson(Map<String, dynamic>.from(json['callback_requests']))
        : null;

    todayInfo = json['today_info'] != null && json['today_info'] is Map<String, dynamic>
        ? TodayInfo.fromJson(Map<String, dynamic>.from(json['today_info']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (staff != null) {
      map['staff'] = staff!.toJson();
    }
    map['active_session'] = activeSession;
    if (school != null) {
      map['school'] = school!.toJson();
    }
    if (todayStats != null) {
      map['today_stats'] = todayStats!.toJson();
    }
    if (callbackRequests != null) {
      map['callback_requests'] = callbackRequests!.toJson();
    }
    if (todayInfo != null) {
      map['today_info'] = todayInfo!.toJson();
    }
    return map;
  }
}

class DashboardStaff {
  int? id;
  String? name;
  String? role;
  String? staffType;
  String? designation;
  String? whatsappNumber;
  String? phone;
  String? email;
  int? schoolId;
  String? teacherUniqueId;
  String? gender;
  String? status;
  String? image;
  String? thumbnail;
  String? address;

  DashboardStaff({
    this.id,
    this.name,
    this.role,
    this.staffType,
    this.designation,
    this.whatsappNumber,
    this.phone,
    this.email,
    this.schoolId,
    this.teacherUniqueId,
    this.gender,
    this.status,
    this.image,
    this.thumbnail,
    this.address,
  });

  DashboardStaff.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    name = json['name']?.toString();
    role = json['role']?.toString();
    staffType = json['staff_type']?.toString();
    designation = json['designation']?.toString();
    whatsappNumber = json['whatsapp_number']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    schoolId = _parseInt(json['school_id']);
    teacherUniqueId = json['teacher_unique_id']?.toString();
    gender = json['gender']?.toString();
    status = json['status']?.toString();
    image = json['image']?.toString();
    thumbnail = json['thumbnail']?.toString();
    address = json['address']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['role'] = role;
    map['staff_type'] = staffType;
    map['designation'] = designation;
    map['whatsapp_number'] = whatsappNumber;
    map['phone'] = phone;
    map['email'] = email;
    map['school_id'] = schoolId;
    map['teacher_unique_id'] = teacherUniqueId;
    map['gender'] = gender;
    map['status'] = status;
    map['image'] = image;
    map['thumbnail'] = thumbnail;
    map['address'] = address;
    return map;
  }
}

class DashboardSchool {
  int? id;
  String? name;
  String? logo;
  String? address;
  String? phone;
  String? email;
  String? city;
  String? state;

  DashboardSchool({
    this.id,
    this.name,
    this.logo,
    this.address,
    this.phone,
    this.email,
    this.city,
    this.state,
  });

  DashboardSchool.fromJson(Map<String, dynamic> json) {
    id = _parseInt(json['id']);
    name = json['name']?.toString();
    logo = json['logo']?.toString();
    address = json['address']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['logo'] = logo;
    map['address'] = address;
    map['phone'] = phone;
    map['email'] = email;
    map['city'] = city;
    map['state'] = state;
    return map;
  }
}

class TodayStats {
  int? visitorsCount;
  int? gatePassesCount;

  TodayStats({this.visitorsCount, this.gatePassesCount});

  TodayStats.fromJson(Map<String, dynamic> json) {
    visitorsCount = _parseInt(json['visitors_count']);
    gatePassesCount = _parseInt(json['gate_passes_count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['visitors_count'] = visitorsCount;
    map['gate_passes_count'] = gatePassesCount;
    return map;
  }
}

class CallbackRequests {
  int? pending;
  int? inProgress;
  int? completedToday;

  CallbackRequests({
    this.pending,
    this.inProgress,
    this.completedToday,
  });

  CallbackRequests.fromJson(Map<String, dynamic> json) {
    pending = _parseInt(json['pending']);
    inProgress = _parseInt(json['in_progress']);
    completedToday = _parseInt(json['completed_today']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['pending'] = pending;
    map['in_progress'] = inProgress;
    map['completed_today'] = completedToday;
    return map;
  }
}

class TodayInfo {
  String? date;
  String? dayName;

  TodayInfo({this.date, this.dayName});

  TodayInfo.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    dayName = json['day_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['date'] = date;
    map['day_name'] = dayName;
    return map;
  }
}
