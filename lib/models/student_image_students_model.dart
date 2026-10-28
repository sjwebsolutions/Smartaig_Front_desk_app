class StudentImageStudentsResponseModel {
  bool? success;
  int? count;
  String? message;
  List<StudentImageStudentItem>? data;

  StudentImageStudentsResponseModel({
    this.success,
    this.count,
    this.message,
    this.data,
  });

  factory StudentImageStudentsResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentImageStudentsResponseModel(
      success: json['success'] as bool?,
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? ''),
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => StudentImageStudentItem.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class StudentImageStudentItem {
  int? id;
  String? studentUniqueId;
  String? studentName;
  String? studentNamePunjabi;
  String? rollNo;
  String? bloodGroup;
  String? studentMobile;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? streamId;
  String? streamName;
  String? fatherName;
  String? motherName;
  String? fatherMobile;
  String? motherMobile;
  StudentCurrentPhotos? currentPhotos;
  bool? hasPendingRequest;
  StudentPendingRequestDetails? pendingRequestDetails;

  StudentImageStudentItem({
    this.id,
    this.studentUniqueId,
    this.studentName,
    this.studentNamePunjabi,
    this.rollNo,
    this.bloodGroup,
    this.studentMobile,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.fatherName,
    this.motherName,
    this.fatherMobile,
    this.motherMobile,
    this.currentPhotos,
    this.hasPendingRequest,
    this.pendingRequestDetails,
  });

  factory StudentImageStudentItem.fromJson(Map<String, dynamic> json) {
    return StudentImageStudentItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentUniqueId: json['student_unique_id']?.toString(),
      studentName: json['student_name']?.toString(),
      studentNamePunjabi: json['student_name_punjabi']?.toString(),
      rollNo: json['roll_no']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      studentMobile: json['student_mobile']?.toString(),
      classId: json['class_id'] is int ? json['class_id'] : int.tryParse(json['class_id']?.toString() ?? ''),
      className: json['class_name']?.toString(),
      sectionId: json['section_id'] is int ? json['section_id'] : int.tryParse(json['section_id']?.toString() ?? ''),
      sectionName: json['section_name']?.toString(),
      streamId: json['stream_id'] is int ? json['stream_id'] : int.tryParse(json['stream_id']?.toString() ?? ''),
      streamName: json['stream_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      currentPhotos: json['current_photos'] != null
          ? StudentCurrentPhotos.fromJson(json['current_photos'])
          : null,
      hasPendingRequest: json['has_pending_request'] as bool?,
      pendingRequestDetails: json['pending_request_details'] != null
          ? StudentPendingRequestDetails.fromJson(json['pending_request_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_unique_id': studentUniqueId,
      'student_name': studentName,
      'student_name_punjabi': studentNamePunjabi,
      'roll_no': rollNo,
      'blood_group': bloodGroup,
      'student_mobile': studentMobile,
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'section_name': sectionName,
      'stream_id': streamId,
      'stream_name': streamName,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_mobile': fatherMobile,
      'mother_mobile': motherMobile,
      'current_photos': currentPhotos?.toJson(),
      'has_pending_request': hasPendingRequest,
      'pending_request_details': pendingRequestDetails?.toJson(),
    };
  }
}

class StudentCurrentPhotos {
  String? studentPhotoUrl;
  String? fatherPhotoUrl;
  String? motherPhotoUrl;
  bool? isStudentPhotoUploaded;
  bool? isFatherPhotoUploaded;
  bool? isMotherPhotoUploaded;

  StudentCurrentPhotos({
    this.studentPhotoUrl,
    this.fatherPhotoUrl,
    this.motherPhotoUrl,
    this.isStudentPhotoUploaded,
    this.isFatherPhotoUploaded,
    this.isMotherPhotoUploaded,
  });

  factory StudentCurrentPhotos.fromJson(Map<String, dynamic> json) {
    return StudentCurrentPhotos(
      studentPhotoUrl: json['student_photo_url']?.toString(),
      fatherPhotoUrl: json['father_photo_url']?.toString(),
      motherPhotoUrl: json['mother_photo_url']?.toString(),
      isStudentPhotoUploaded: json['is_student_photo_uploaded'] as bool?,
      isFatherPhotoUploaded: json['is_father_photo_uploaded'] as bool?,
      isMotherPhotoUploaded: json['is_mother_photo_uploaded'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_photo_url': studentPhotoUrl,
      'father_photo_url': fatherPhotoUrl,
      'mother_photo_url': motherPhotoUrl,
      'is_student_photo_uploaded': isStudentPhotoUploaded,
      'is_father_photo_uploaded': isFatherPhotoUploaded,
      'is_mother_photo_uploaded': isMotherPhotoUploaded,
    };
  }
}

class StudentPendingRequestDetails {
  int? id;
  String? submittedBy;
  String? requestedVia;
  String? createdAt;
  bool? hasNewProfileImage;
  bool? hasNewFatherImage;
  bool? hasNewMotherImage;

  StudentPendingRequestDetails({
    this.id,
    this.submittedBy,
    this.requestedVia,
    this.createdAt,
    this.hasNewProfileImage,
    this.hasNewFatherImage,
    this.hasNewMotherImage,
  });

  factory StudentPendingRequestDetails.fromJson(Map<String, dynamic> json) {
    return StudentPendingRequestDetails(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      submittedBy: json['submitted_by']?.toString(),
      requestedVia: json['requested_via']?.toString(),
      createdAt: json['created_at']?.toString(),
      hasNewProfileImage: json['has_new_profile_image'] as bool?,
      hasNewFatherImage: json['has_new_father_image'] as bool?,
      hasNewMotherImage: json['has_new_mother_image'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submitted_by': submittedBy,
      'requested_via': requestedVia,
      'created_at': createdAt,
      'has_new_profile_image': hasNewProfileImage,
      'has_new_father_image': hasNewFatherImage,
      'has_new_mother_image': hasNewMotherImage,
    };
  }
}
