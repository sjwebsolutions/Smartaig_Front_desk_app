class AdmissionResponseModel {
  final bool? success;
  final List<AdmissionEnquiryModel>? data;

  AdmissionResponseModel({
    this.success,
    this.data,
  });

  factory AdmissionResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return AdmissionResponseModel(
      success: parsedSuccess,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AdmissionEnquiryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdmissionEnquiryModel {
  final int? id;
  final String? inquiryNumber;
  final String? fullName;
  final String? gender;
  final String? dob;
  final String? sessionYear;
  final dynamic studentClassId;
  final String? className;
  final String? status;
  final String? statusLabel;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherMobile;
  final String? studentImageUrl;
  final String? createdBy;
  final String? createdAt;

  AdmissionEnquiryModel({
    this.id,
    this.inquiryNumber,
    this.fullName,
    this.gender,
    this.dob,
    this.sessionYear,
    this.studentClassId,
    this.className,
    this.status,
    this.statusLabel,
    this.fatherName,
    this.fatherMobile,
    this.motherMobile,
    this.studentImageUrl,
    this.createdBy,
    this.createdAt,
  });

  factory AdmissionEnquiryModel.fromJson(Map<String, dynamic> json) {
    return AdmissionEnquiryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      inquiryNumber: json['inquiry_number']?.toString(),
      fullName: json['full_name']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      sessionYear: json['session_year']?.toString(),
      studentClassId: json['student_class_id'],
      className: json['class_name']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      studentImageUrl: json['student_image_url']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class AdmissionDetailResponseModel {
  final bool? success;
  final AdmissionDetailModel? data;

  AdmissionDetailResponseModel({
    this.success,
    this.data,
  });

  factory AdmissionDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return AdmissionDetailResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdmissionDetailModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AdmissionDetailModel {
  final int? id;
  final String? inquiryNumber;
  final String? fullName;
  final String? gender;
  final String? dob;
  final String? aadhaarNo;
  final String? category;
  final String? religion;
  final String? caste;
  final dynamic studentClassId;
  final String? className;
  final String? previousSchool;
  final String? lastClassAttended;
  final String? reasonForLeaving;
  final String? fatherName;
  final String? motherName;
  final String? fatherMobile;
  final String? motherMobile;
  final String? fatherOccupation;
  final String? motherOccupation;
  final String? fatherQualification;
  final String? motherQualification;
  final String? familyIncome;
  final String? medicalHistory;
  final String? alternateContact;
  final String? address;
  final String? locality;
  final String? city;
  final String? state;
  final String? pincode;
  final String? sessionYear;
  final String? status;
  final String? statusLabel;
  final String? followUpStatus;
  final String? interestLevel;
  final String? remarks;
  final String? siblingsDetails;
  final String? studentImageUrl;
  final String? createdBy;
  final String? createdAt;
  final List<AdmissionFollowupItem>? followups;

  AdmissionDetailModel({
    this.id,
    this.inquiryNumber,
    this.fullName,
    this.gender,
    this.dob,
    this.aadhaarNo,
    this.category,
    this.religion,
    this.caste,
    this.studentClassId,
    this.className,
    this.previousSchool,
    this.lastClassAttended,
    this.reasonForLeaving,
    this.fatherName,
    this.motherName,
    this.fatherMobile,
    this.motherMobile,
    this.fatherOccupation,
    this.motherOccupation,
    this.fatherQualification,
    this.motherQualification,
    this.familyIncome,
    this.medicalHistory,
    this.alternateContact,
    this.address,
    this.locality,
    this.city,
    this.state,
    this.pincode,
    this.sessionYear,
    this.status,
    this.statusLabel,
    this.followUpStatus,
    this.interestLevel,
    this.remarks,
    this.siblingsDetails,
    this.studentImageUrl,
    this.createdBy,
    this.createdAt,
    this.followups,
  });

  factory AdmissionDetailModel.fromJson(Map<String, dynamic> json) {
    return AdmissionDetailModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      inquiryNumber: json['inquiry_number']?.toString(),
      fullName: json['full_name']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      aadhaarNo: json['aadhaar_no']?.toString(),
      category: json['category']?.toString(),
      religion: json['religion']?.toString(),
      caste: json['caste']?.toString(),
      studentClassId: json['student_class_id'],
      className: json['class_name']?.toString(),
      previousSchool: json['previous_school']?.toString(),
      lastClassAttended: json['last_class_attended']?.toString(),
      reasonForLeaving: json['reason_for_leaving']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      fatherOccupation: json['father_occupation']?.toString(),
      motherOccupation: json['mother_occupation']?.toString(),
      fatherQualification: json['father_qualification']?.toString(),
      motherQualification: json['mother_qualification']?.toString(),
      familyIncome: json['family_income']?.toString(),
      medicalHistory: json['medical_history']?.toString(),
      alternateContact: json['alternate_contact']?.toString(),
      address: json['address']?.toString(),
      locality: json['locality']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      sessionYear: json['session_year']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      followUpStatus: json['follow_up_status']?.toString(),
      interestLevel: json['interest_level']?.toString(),
      remarks: json['remarks']?.toString(),
      siblingsDetails: json['siblings_details']?.toString(),
      studentImageUrl: json['student_image_url']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      followups: (json['followups'] as List<dynamic>?)
          ?.map((e) => AdmissionFollowupItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdmissionFollowupItem {
  final int? id;
  final String? note;
  final String? session;
  final String? createdBy;
  final String? createdAt;

  AdmissionFollowupItem({
    this.id,
    this.note,
    this.session,
    this.createdBy,
    this.createdAt,
  });

  factory AdmissionFollowupItem.fromJson(Map<String, dynamic> json) {
    return AdmissionFollowupItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      note: json['note']?.toString(),
      session: json['session']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class AddAdmissionFollowupResponseModel {
  final bool? success;
  final String? message;
  final AdmissionFollowupItem? data;

  AddAdmissionFollowupResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory AddAdmissionFollowupResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return AddAdmissionFollowupResponseModel(
      success: parsedSuccess,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AdmissionFollowupItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AdmissionClassResponseModel {
  final bool? success;
  final List<AdmissionClassItem>? data;

  AdmissionClassResponseModel({
    this.success,
    this.data,
  });

  factory AdmissionClassResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return AdmissionClassResponseModel(
      success: parsedSuccess,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AdmissionClassItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdmissionClassItem {
  final int? id;
  final String? name;

  AdmissionClassItem({
    this.id,
    this.name,
  });

  factory AdmissionClassItem.fromJson(Map<String, dynamic> json) {
    return AdmissionClassItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
    );
  }
}

class AddAdmissionResponseModel {
  final bool? success;
  final String? message;
  final AddAdmissionData? data;

  AddAdmissionResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory AddAdmissionResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }
    return AddAdmissionResponseModel(
      success: parsedSuccess,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddAdmissionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AddAdmissionData {
  final int? id;
  final String? inquiryNumber;
  final String? fullName;
  final String? status;
  final String? sessionYear;
  final String? studentImageUrl;
  final String? createdBy;
  final String? createdAt;

  AddAdmissionData({
    this.id,
    this.inquiryNumber,
    this.fullName,
    this.status,
    this.sessionYear,
    this.studentImageUrl,
    this.createdBy,
    this.createdAt,
  });

  factory AddAdmissionData.fromJson(Map<String, dynamic> json) {
    return AddAdmissionData(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      inquiryNumber: json['inquiry_number']?.toString(),
      fullName: json['full_name']?.toString(),
      status: json['status']?.toString(),
      sessionYear: json['session_year']?.toString(),
      studentImageUrl: json['student_image_url']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
