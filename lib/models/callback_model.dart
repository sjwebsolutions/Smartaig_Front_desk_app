class CallbackResponseModel {
  final bool? success;
  final CallbackCounts? counts;
  final List<CallbackRequestItem>? data;
  final CallbackMeta? meta;
  final String? message;

  CallbackResponseModel({
    this.success,
    this.counts,
    this.data,
    this.meta,
    this.message,
  });

  factory CallbackResponseModel.fromJson(Map<String, dynamic> json) {
    return CallbackResponseModel(
      success: json['success'] as bool?,
      counts: json['counts'] != null ? CallbackCounts.fromJson(json['counts'] as Map<String, dynamic>) : null,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => CallbackRequestItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      meta: json['meta'] != null ? CallbackMeta.fromJson(json['meta'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
    );
  }
}

class CallbackDetailResponseModel {
  final bool? success;
  final CallbackDetailItem? data;
  final String? message;

  CallbackDetailResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory CallbackDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return CallbackDetailResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null ? CallbackDetailItem.fromJson(json['data'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
    );
  }
}

class StoreCallbackNoteResponseModel {
  final bool? success;
  final String? message;
  final StoreCallbackNoteData? data;

  StoreCallbackNoteResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StoreCallbackNoteResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreCallbackNoteResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? StoreCallbackNoteData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class StoreCallbackNoteData {
  final int? callbackRequestId;
  final String? currentStatus;
  final CallbackLogItem? log;

  StoreCallbackNoteData({
    this.callbackRequestId,
    this.currentStatus,
    this.log,
  });

  factory StoreCallbackNoteData.fromJson(Map<String, dynamic> json) {
    return StoreCallbackNoteData(
      callbackRequestId: json['callback_request_id'] as int?,
      currentStatus: json['current_status'] as String?,
      log: json['log'] != null ? CallbackLogItem.fromJson(json['log'] as Map<String, dynamic>) : null,
    );
  }
}

class UpdateCallbackStatusResponseModel {
  final bool? success;
  final String? message;
  final UpdateCallbackStatusData? data;

  UpdateCallbackStatusResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory UpdateCallbackStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateCallbackStatusResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? UpdateCallbackStatusData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }
}

class UpdateCallbackStatusData {
  final int? id;
  final String? status;
  final String? completedAt;

  UpdateCallbackStatusData({
    this.id,
    this.status,
    this.completedAt,
  });

  factory UpdateCallbackStatusData.fromJson(Map<String, dynamic> json) {
    return UpdateCallbackStatusData(
      id: json['id'] as int?,
      status: json['status'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class CallbackCounts {
  final int pending;
  final int inProgress;
  final int completedToday;
  final int all;

  CallbackCounts({
    this.pending = 0,
    this.inProgress = 0,
    this.completedToday = 0,
    this.all = 0,
  });

  factory CallbackCounts.fromJson(Map<String, dynamic> json) {
    return CallbackCounts(
      pending: json['pending'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      completedToday: json['completed_today'] as int? ?? 0,
      all: json['all'] as int? ?? 0,
    );
  }
}

class CallbackMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  CallbackMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory CallbackMeta.fromJson(Map<String, dynamic> json) {
    return CallbackMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}

class CallbackRequestItem {
  final int? id;
  final String? status;
  final String? reason;
  final String? description;
  final String? requestedAt;
  final String? timeAgo;
  final CallbackParent? parent;
  final CallbackStudent? student;
  final CallbackLatestLog? latestLog;

  CallbackRequestItem({
    this.id,
    this.status,
    this.reason,
    this.description,
    this.requestedAt,
    this.timeAgo,
    this.parent,
    this.student,
    this.latestLog,
  });

  factory CallbackRequestItem.fromJson(Map<String, dynamic> json) {
    return CallbackRequestItem(
      id: json['id'] as int?,
      status: json['status'] as String?,
      reason: (json['reason'] ?? json['description'] ?? json['details'])?.toString(),
      description: (json['description'] ?? json['details'] ?? json['reason'])?.toString(),
      requestedAt: json['requested_at'] as String?,
      timeAgo: json['time_ago'] as String?,
      parent: json['parent'] != null ? CallbackParent.fromJson(json['parent'] as Map<String, dynamic>) : null,
      student: json['student'] != null ? CallbackStudent.fromJson(json['student'] as Map<String, dynamic>) : null,
      latestLog: json['latest_log'] != null ? CallbackLatestLog.fromJson(json['latest_log'] as Map<String, dynamic>) : null,
    );
  }
}

class CallbackDetailItem {
  final int? id;
  final String? status;
  final String? reason;
  final String? description;
  final String? requestedAt;
  final String? timeAgo;
  final String? completedAt;
  final CallbackParent? parent;
  final CallbackStudent? student;
  final List<CallbackLogItem>? logs;

  CallbackDetailItem({
    this.id,
    this.status,
    this.reason,
    this.description,
    this.requestedAt,
    this.timeAgo,
    this.completedAt,
    this.parent,
    this.student,
    this.logs,
  });

  factory CallbackDetailItem.fromJson(Map<String, dynamic> json) {
    return CallbackDetailItem(
      id: json['id'] as int?,
      status: json['status'] as String?,
      reason: (json['reason'] ?? json['description'] ?? json['details'])?.toString(),
      description: (json['description'] ?? json['details'] ?? json['reason'])?.toString(),
      requestedAt: json['requested_at'] as String?,
      timeAgo: json['time_ago'] as String?,
      completedAt: json['completed_at'] as String?,
      parent: json['parent'] != null ? CallbackParent.fromJson(json['parent'] as Map<String, dynamic>) : null,
      student: json['student'] != null ? CallbackStudent.fromJson(json['student'] as Map<String, dynamic>) : null,
      logs: json['logs'] != null
          ? (json['logs'] as List).map((i) => CallbackLogItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

class CallbackLogItem {
  final int? id;
  final String? action;
  final String? callStatus;
  final String? notes;
  final String? previousStatus;
  final String? newStatus;
  final String? staffName;
  final String? staffRole;
  final String? createdAt;
  final String? timeAgo;

  CallbackLogItem({
    this.id,
    this.action,
    this.callStatus,
    this.notes,
    this.previousStatus,
    this.newStatus,
    this.staffName,
    this.staffRole,
    this.createdAt,
    this.timeAgo,
  });

  factory CallbackLogItem.fromJson(Map<String, dynamic> json) {
    return CallbackLogItem(
      id: json['id'] as int?,
      action: json['action'] as String?,
      callStatus: json['call_status'] as String?,
      notes: (json['notes'] ?? json['description'] ?? json['remark'])?.toString(),
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String?,
      staffName: json['staff_name'] as String?,
      staffRole: json['staff_role'] as String?,
      createdAt: json['created_at'] as String?,
      timeAgo: json['time_ago'] as String?,
    );
  }
}

class CallbackParent {
  final String? name;
  final String? mobile;

  CallbackParent({
    this.name,
    this.mobile,
  });

  factory CallbackParent.fromJson(Map<String, dynamic> json) {
    return CallbackParent(
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
    );
  }
}

class CallbackStudent {
  final int? id;
  final String? name;
  final String? className;
  final String? sectionName;
  final String? streamName;
  final String? rollNo;

  CallbackStudent({
    this.id,
    this.name,
    this.className,
    this.sectionName,
    this.streamName,
    this.rollNo,
  });

  factory CallbackStudent.fromJson(Map<String, dynamic> json) {
    return CallbackStudent(
      id: json['id'] as int?,
      name: json['name'] as String?,
      className: json['class_name'] as String?,
      sectionName: json['section_name'] as String?,
      streamName: json['stream_name'] as String?,
      rollNo: json['roll_no'] as String?,
    );
  }
}

class CallbackLatestLog {
  final String? callStatus;
  final String? notes;
  final String? staffName;
  final String? createdAt;

  CallbackLatestLog({
    this.callStatus,
    this.notes,
    this.staffName,
    this.createdAt,
  });

  factory CallbackLatestLog.fromJson(Map<String, dynamic> json) {
    return CallbackLatestLog(
      callStatus: json['call_status'] as String?,
      notes: (json['notes'] ?? json['description'] ?? json['remark'])?.toString(),
      staffName: json['staff_name'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
