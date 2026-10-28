class StudentImageStoreResponseModel {
  bool? success;
  String? message;
  StudentImageStoreData? data;

  StudentImageStoreResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StudentImageStoreResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentImageStoreResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? StudentImageStoreData.fromJson(json['data']) : null,
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

class StudentImageStoreData {
  int? requestId;
  String? studentUniqueId;
  String? studentName;
  String? status;
  SubmittedPhotos? submittedPhotos;

  StudentImageStoreData({
    this.requestId,
    this.studentUniqueId,
    this.studentName,
    this.status,
    this.submittedPhotos,
  });

  factory StudentImageStoreData.fromJson(Map<String, dynamic> json) {
    return StudentImageStoreData(
      requestId: json['request_id'] is int ? json['request_id'] : int.tryParse(json['request_id']?.toString() ?? ''),
      studentUniqueId: json['student_unique_id']?.toString(),
      studentName: json['student_name']?.toString(),
      status: json['status']?.toString(),
      submittedPhotos: json['submitted_photos'] != null
          ? SubmittedPhotos.fromJson(json['submitted_photos'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'student_unique_id': studentUniqueId,
      'student_name': studentName,
      'status': status,
      'submitted_photos': submittedPhotos?.toJson(),
    };
  }
}

class SubmittedPhotos {
  bool? profileImage;
  bool? fatherImage;
  bool? motherImage;

  SubmittedPhotos({
    this.profileImage,
    this.fatherImage,
    this.motherImage,
  });

  factory SubmittedPhotos.fromJson(Map<String, dynamic> json) {
    return SubmittedPhotos(
      profileImage: json['profile_image'] as bool?,
      fatherImage: json['father_image'] as bool?,
      motherImage: json['mother_image'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_image': profileImage,
      'father_image': fatherImage,
      'mother_image': motherImage,
    };
  }
}
