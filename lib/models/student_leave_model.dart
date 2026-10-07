class StudentLeaveResponseModel {
  final bool success;
  final bool canApprove;
  final List<StudentLeaveItem> data;
  final String? message;

  StudentLeaveResponseModel({
    required this.success,
    this.canApprove = false,
    required this.data,
    this.message,
  });

  factory StudentLeaveResponseModel.fromJson(Map<String, dynamic> json) {
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

    List<StudentLeaveItem> items = [];
    if (json['data'] != null && json['data'] is List) {
      items = (json['data'] as List)
          .map((e) => StudentLeaveItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return StudentLeaveResponseModel(
      success: parsedSuccess,
      canApprove: parsedCanApprove,
      data: items,
      message: json['message']?.toString(),
    );
  }
}

class StudentLeaveItem {
  final int id;
  final int? studentId;
  final int? studentClassId;
  final int? studentSectionId;
  final int? studentStreamId;
  final String studentName;
  final String? admissionNumber;
  final String? rollNo;
  final String? className;
  final String? sectionName;
  final String? streamName;
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
  final String? actionAt;
  final String? approverRemarks;
  final String? rejectionReason;
  final String? createdAt;

  StudentLeaveItem({
    required this.id,
    this.studentId,
    this.studentClassId,
    this.studentSectionId,
    this.studentStreamId,
    required this.studentName,
    this.admissionNumber,
    this.rollNo,
    this.className,
    this.sectionName,
    this.streamName,
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
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    this.createdAt,
  });

  factory StudentLeaveItem.fromJson(Map<String, dynamic> json) {
    return StudentLeaveItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id'] is int ? json['student_id'] as int : int.tryParse(json['student_id']?.toString() ?? ''),
      studentClassId: json['student_class_id'] is int ? json['student_class_id'] as int : int.tryParse(json['student_class_id']?.toString() ?? ''),
      studentSectionId: json['student_section_id'] is int ? json['student_section_id'] as int : int.tryParse(json['student_section_id']?.toString() ?? ''),
      studentStreamId: json['student_stream_id'] is int ? json['student_stream_id'] as int : int.tryParse(json['student_stream_id']?.toString() ?? ''),
      studentName: json['student_name']?.toString() ?? 'Student',
      admissionNumber: json['admission_number']?.toString(),
      rollNo: json['roll_no']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      streamName: json['stream_name']?.toString(),
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
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  String get fullClassSection {
    final List<String> parts = [];
    if (className != null && className!.isNotEmpty) parts.add('Class $className');
    if (sectionName != null && sectionName!.isNotEmpty) parts.add('Sec ${sectionName!.toUpperCase()}');
    if (streamName != null && streamName!.isNotEmpty) parts.add(streamName!);
    return parts.isNotEmpty ? parts.join(' - ') : 'N/A';
  }
}

class ActionStudentLeaveResponseModel {
  final bool success;
  final String message;

  ActionStudentLeaveResponseModel({
    required this.success,
    required this.message,
  });

  factory ActionStudentLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return ActionStudentLeaveResponseModel(
      success: parsedSuccess,
      message: json['message']?.toString() ?? (parsedSuccess ? 'Success' : 'Operation failed'),
    );
  }
}
