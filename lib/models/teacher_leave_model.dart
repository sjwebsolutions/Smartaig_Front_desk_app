class TeacherLeaveResponseModel {
  final bool success;
  final bool canApprove;
  final List<TeacherLeaveItem> data;
  final String? message;

  TeacherLeaveResponseModel({
    required this.success,
    this.canApprove = false,
    required this.data,
    this.message,
  });

  factory TeacherLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    final rawCanApprove = json['can_approve'];
    bool parsedCanApprove = false;
    if (rawCanApprove == true || rawCanApprove == 1 || rawCanApprove.toString().toLowerCase() == 'true') {
      parsedCanApprove = true;
    }

    List<TeacherLeaveItem> items = [];
    if (json['data'] != null && json['data'] is List) {
      items = (json['data'] as List)
          .map((e) => TeacherLeaveItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TeacherLeaveResponseModel(
      success: parsedSuccess,
      canApprove: parsedCanApprove,
      data: items,
      message: json['message']?.toString(),
    );
  }
}

class TeacherLeaveItem {
  final int id;
  final int? teacherId;
  final String teacherName;
  final String? teacherCode;
  final String? teacherPhone;
  final String? teacherDesignation;
  final String? teacherAvatar;
  final String leaveType;
  final String leaveTypeLabel;
  final String dayType;
  final String dayTypeLabel;
  final String? halfDayStartTime;
  final String? halfDayEndTime;
  final String fromDate;
  final String toDate;
  final String fromDateFormatted;
  final String toDateFormatted;
  final num totalDays;
  final String? reason;
  final String? attachmentUrl;
  final String status;
  final String statusLabel;
  final String? actionByRole;
  final String? actionByName;
  final String? actionViaApp;
  final String? actionAt;
  final String? approverRemarks;
  final String? rejectionReason;
  final String? createdAt;
  final List<TeacherLeaveLog> logs;

  TeacherLeaveItem({
    required this.id,
    this.teacherId,
    required this.teacherName,
    this.teacherCode,
    this.teacherPhone,
    this.teacherDesignation,
    this.teacherAvatar,
    required this.leaveType,
    required this.leaveTypeLabel,
    required this.dayType,
    required this.dayTypeLabel,
    this.halfDayStartTime,
    this.halfDayEndTime,
    required this.fromDate,
    required this.toDate,
    required this.fromDateFormatted,
    required this.toDateFormatted,
    required this.totalDays,
    this.reason,
    this.attachmentUrl,
    required this.status,
    required this.statusLabel,
    this.actionByRole,
    this.actionByName,
    this.actionViaApp,
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    this.createdAt,
    this.logs = const [],
  });

  factory TeacherLeaveItem.fromJson(Map<String, dynamic> json) {
    List<TeacherLeaveLog> parsedLogs = [];
    if (json['logs'] != null && json['logs'] is List) {
      parsedLogs = (json['logs'] as List)
          .map((e) => TeacherLeaveLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TeacherLeaveItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      teacherId: json['teacher_id'] is int ? json['teacher_id'] as int : int.tryParse(json['teacher_id']?.toString() ?? ''),
      teacherName: json['teacher_name']?.toString() ?? 'Teacher',
      teacherCode: json['teacher_code']?.toString(),
      teacherPhone: json['teacher_phone']?.toString(),
      teacherDesignation: json['teacher_designation']?.toString(),
      teacherAvatar: json['teacher_avatar']?.toString(),
      leaveType: json['leave_type']?.toString() ?? 'casual',
      leaveTypeLabel: json['leave_type_label']?.toString() ?? 'Casual',
      dayType: json['day_type']?.toString() ?? 'full_day',
      dayTypeLabel: json['day_type_label']?.toString() ?? 'Full Day',
      halfDayStartTime: json['half_day_start_time']?.toString(),
      halfDayEndTime: json['half_day_end_time']?.toString(),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      fromDateFormatted: json['from_date_formatted']?.toString() ?? json['from_date']?.toString() ?? '',
      toDateFormatted: json['to_date_formatted']?.toString() ?? json['to_date']?.toString() ?? '',
      totalDays: json['total_days'] is num ? json['total_days'] as num : num.tryParse(json['total_days']?.toString() ?? '1') ?? 1,
      reason: json['reason']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      actionByRole: json['action_by_role']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionViaApp: json['action_via_app']?.toString(),
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
      logs: parsedLogs,
    );
  }
}

class TeacherLeaveLog {
  final int id;
  final String? action;
  final String? actionLabel;
  final String? actionByName;
  final String? actionByRole;
  final String? actionViaApp;
  final String? notes;
  final String? createdAt;

  TeacherLeaveLog({
    required this.id,
    this.action,
    this.actionLabel,
    this.actionByName,
    this.actionByRole,
    this.actionViaApp,
    this.notes,
    this.createdAt,
  });

  factory TeacherLeaveLog.fromJson(Map<String, dynamic> json) {
    return TeacherLeaveLog(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString(),
      actionLabel: json['action_label']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionViaApp: json['action_via_app']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ActionTeacherLeaveResponseModel {
  final bool success;
  final String message;

  ActionTeacherLeaveResponseModel({
    required this.success,
    required this.message,
  });

  factory ActionTeacherLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return ActionTeacherLeaveResponseModel(
      success: parsedSuccess,
      message: json['message']?.toString() ?? (parsedSuccess ? 'Success' : 'Operation failed'),
    );
  }
}
