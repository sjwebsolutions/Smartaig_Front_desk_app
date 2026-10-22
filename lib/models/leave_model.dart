class LeaveItem {
  final String id;
  final String applicantName;
  final String applicantRole; // Staff, Teacher, Student, etc.
  final String leaveType; // Casual Leave, Sick Leave, Earned Leave, Emergency Leave, etc.
  final String fromDate;
  final String toDate;
  final int daysCount;
  final String reason;
  String status; // Pending, Approved, Rejected
  final String appliedDate;
  String? approvedBy;
  String? remarks;

  LeaveItem({
    required this.id,
    required this.applicantName,
    required this.applicantRole,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.approvedBy,
    this.remarks,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      id: json['id']?.toString() ?? '',
      applicantName: json['applicant_name'] ?? json['name'] ?? '',
      applicantRole: json['applicant_role'] ?? json['role'] ?? 'Staff',
      leaveType: json['leave_type'] ?? 'Casual Leave',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      daysCount: json['days_count'] as int? ?? 1,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      appliedDate: json['applied_date'] ?? '',
      approvedBy: json['approved_by'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicant_name': applicantName,
      'applicant_role': applicantRole,
      'leave_type': leaveType,
      'from_date': fromDate,
      'to_date': toDate,
      'days_count': daysCount,
      'reason': reason,
      'status': status,
      'applied_date': appliedDate,
      'approved_by': approvedBy,
      'remarks': remarks,
    };
  }
}
