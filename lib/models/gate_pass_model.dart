class GatePassResponseModel {
  final bool? success;
  final List<GatePassItem>? data;
  final String? message;

  GatePassResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory GatePassResponseModel.fromJson(Map<String, dynamic> json) {
    return GatePassResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => GatePassItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      message: json['message'] as String?,
    );
  }
}

class GatePassItem {
  final int? id;
  final String? gatePassNo;
  final String? date;
  final String? time;
  final String? exitTime;
  final String? status;
  final String? reason;
  final GatePassGuardian? guardian;
  final GatePassStudent? student;
  final String? createdBy;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectedBy;
  final String? rejectedAt;

  GatePassItem({
    this.id,
    this.gatePassNo,
    this.date,
    this.time,
    this.exitTime,
    this.status,
    this.reason,
    this.guardian,
    this.student,
    this.createdBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
  });

  factory GatePassItem.fromJson(Map<String, dynamic> json) {
    return GatePassItem(
      id: json['id'] as int?,
      gatePassNo: json['gate_pass_no'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      exitTime: json['exit_time'] as String?,
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      guardian: json['guardian'] != null ? GatePassGuardian.fromJson(json['guardian'] as Map<String, dynamic>) : null,
      student: json['student'] != null ? GatePassStudent.fromJson(json['student'] as Map<String, dynamic>) : null,
      createdBy: json['created_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] as String?,
      rejectedBy: json['rejected_by'] as String?,
      rejectedAt: json['rejected_at'] as String?,
    );
  }
}

class GatePassGuardian {
  final String? personName;
  final String? relation;
  final String? contactNo;

  GatePassGuardian({
    this.personName,
    this.relation,
    this.contactNo,
  });

  factory GatePassGuardian.fromJson(Map<String, dynamic> json) {
    return GatePassGuardian(
      personName: json['person_name'] as String?,
      relation: json['relation'] as String?,
      contactNo: json['contact_no'] as String?,
    );
  }
}

class GatePassStudent {
  final int? id;
  final String? name;
  final String? rollNo;
  final String? className;
  final String? sectionName;
  final String? streamName;

  GatePassStudent({
    this.id,
    this.name,
    this.rollNo,
    this.className,
    this.sectionName,
    this.streamName,
  });

  factory GatePassStudent.fromJson(Map<String, dynamic> json) {
    return GatePassStudent(
      id: json['id'] as int?,
      name: json['name'] as String?,
      rollNo: json['roll_no'] as String?,
      className: json['class_name'] as String?,
      sectionName: json['section_name'] as String?,
      streamName: json['stream_name'] as String?,
    );
  }
}

class ApproveGatePassResponseModel {
  final bool? success;
  final String? message;
  final GatePassApprovalData? data;

  ApproveGatePassResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory ApproveGatePassResponseModel.fromJson(Map<String, dynamic> json) {
    return ApproveGatePassResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? GatePassApprovalData.fromJson(json['data'] as Map<String, dynamic>) : null,
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

class GatePassApprovalData {
  final int? id;
  final String? gatePassNo;
  final String? status;
  final String? approvedBy;
  final String? approvedAt;

  GatePassApprovalData({
    this.id,
    this.gatePassNo,
    this.status,
    this.approvedBy,
    this.approvedAt,
  });

  factory GatePassApprovalData.fromJson(Map<String, dynamic> json) {
    return GatePassApprovalData(
      id: json['id'] as int?,
      gatePassNo: json['gate_pass_no'] as String?,
      status: json['status'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gate_pass_no': gatePassNo,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
    };
  }
}

class RejectGatePassResponseModel {
  final bool? success;
  final String? message;
  final GatePassRejectionData? data;

  RejectGatePassResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory RejectGatePassResponseModel.fromJson(Map<String, dynamic> json) {
    return RejectGatePassResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? GatePassRejectionData.fromJson(json['data'] as Map<String, dynamic>) : null,
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

class GatePassRejectionData {
  final int? id;
  final String? gatePassNo;
  final String? status;
  final String? rejectedBy;
  final String? rejectedAt;

  GatePassRejectionData({
    this.id,
    this.gatePassNo,
    this.status,
    this.rejectedBy,
    this.rejectedAt,
  });

  factory GatePassRejectionData.fromJson(Map<String, dynamic> json) {
    return GatePassRejectionData(
      id: json['id'] as int?,
      gatePassNo: json['gate_pass_no'] as String?,
      status: json['status'] as String?,
      rejectedBy: json['rejected_by'] as String?,
      rejectedAt: json['rejected_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gate_pass_no': gatePassNo,
      'status': status,
      'rejected_by': rejectedBy,
      'rejected_at': rejectedAt,
    };
  }
}


