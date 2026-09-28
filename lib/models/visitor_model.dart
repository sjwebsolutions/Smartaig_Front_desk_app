class VisitorResponseModel {
  final bool? success;
  final List<VisitorItem>? data;
  final String? message;

  VisitorResponseModel({
    this.success,
    this.data,
    this.message,
  });

  factory VisitorResponseModel.fromJson(Map<String, dynamic> json) {
    return VisitorResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => VisitorItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      message: json['message'] as String?,
    );
  }
}

class VisitorItem {
  final int? id;
  final String? name;
  final String? mobileNo;
  final String? whatsappNo;
  final String? visitorType;
  final String? visitTypeDetail;
  final String? purposeOfVisit;
  final String? visitDate;
  final String? visitTime;
  final String? markedVia;
  final bool? isLocationVerified;
  final String? createdBy;
  final List<VisitorAssociatedStudent>? associatedStudents;

  VisitorItem({
    this.id,
    this.name,
    this.mobileNo,
    this.whatsappNo,
    this.visitorType,
    this.visitTypeDetail,
    this.purposeOfVisit,
    this.visitDate,
    this.visitTime,
    this.markedVia,
    this.isLocationVerified,
    this.createdBy,
    this.associatedStudents,
  });

  factory VisitorItem.fromJson(Map<String, dynamic> json) {
    return VisitorItem(
      id: json['id'] as int?,
      name: json['name'] as String?,
      mobileNo: json['mobile_no'] as String?,
      whatsappNo: json['whatsapp_no'] as String?,
      visitorType: json['visitor_type'] as String?,
      visitTypeDetail: json['visit_type_detail'] as String?,
      purposeOfVisit: json['purpose_of_visit'] as String?,
      visitDate: json['visit_date'] as String?,
      visitTime: json['visit_time'] as String?,
      markedVia: json['marked_via'] as String?,
      isLocationVerified: json['is_location_verified'] as bool?,
      createdBy: json['created_by'] as String?,
      associatedStudents: json['associated_students'] != null
          ? (json['associated_students'] as List)
              .map((i) => VisitorAssociatedStudent.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class VisitorAssociatedStudent {
  final int? id;
  final String? name;
  final String? className;
  final String? sectionName;
  final String? rollNo;

  VisitorAssociatedStudent({
    this.id,
    this.name,
    this.className,
    this.sectionName,
    this.rollNo,
  });

  factory VisitorAssociatedStudent.fromJson(Map<String, dynamic> json) {
    return VisitorAssociatedStudent(
      id: json['id'] as int?,
      name: json['name'] as String?,
      className: json['class_name'] as String?,
      sectionName: json['section_name'] as String?,
      rollNo: json['roll_no'] as String?,
    );
  }
}
