class OtpRequestModel {
  String? whatsappNumber;
  String? deviceUuid;
  String? deviceName;
  String? deviceOs;
  String? fcmToken;

  OtpRequestModel({
    this.whatsappNumber,
    this.deviceUuid,
    this.deviceName,
    this.deviceOs,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['whatsapp_number'] = whatsappNumber;
    data['device_uuid'] = deviceUuid;
    data['device_name'] = deviceName;
    data['device_os'] = deviceOs;
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      data['fcm_token'] = fcmToken;
      data['device_token'] = fcmToken;
    }
    return data;
  }
}

class OtpResponseModel {
  bool? success;
  String? message;

  OtpResponseModel({this.success, this.message});

  OtpResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';
    message = json['message']?.toString() ?? json['msg']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class VerifyOtpRequestModel {
  String? whatsappNumber;
  String? otpCode;
  String? deviceUuid;
  String? deviceName;
  String? deviceOs;
  String? fcmToken;

  VerifyOtpRequestModel({
    this.whatsappNumber,
    this.otpCode,
    this.deviceUuid,
    this.deviceName,
    this.deviceOs,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['whatsapp_number'] = whatsappNumber;
    data['otp_code'] = otpCode;
    data['device_uuid'] = deviceUuid;
    data['device_name'] = deviceName;
    data['device_os'] = deviceOs;
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      data['fcm_token'] = fcmToken;
      data['device_token'] = fcmToken;
    }
    return data;
  }
}

class VerifyOtpResponseModel {
  bool? success;
  String? message;
  Data? data;

  VerifyOtpResponseModel({this.success, this.message, this.data});

  VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    Map<String, dynamic> dataMap = {};
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      dataMap = Map<String, dynamic>.from(json['data']);
    } else {
      dataMap = Map<String, dynamic>.from(json);
    }

    final rootToken = json['token'] ??
        json['access_token'] ??
        json['auth_token'] ??
        json['bearer_token'] ??
        json['jwt'] ??
        json['api_token'];

    if (rootToken != null && rootToken.toString().isNotEmpty) {
      dataMap['token'] = rootToken.toString();
    }

    data = Data.fromJson(dataMap);

    if (data?.token != null && data!.token!.isNotEmpty) {
      success = true;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? token;
  Staff? staff;
  School? school;

  Data({this.token, this.staff, this.school});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token']?.toString() ??
        json['access_token']?.toString() ??
        json['auth_token']?.toString() ??
        json['bearer_token']?.toString() ??
        json['jwt']?.toString() ??
        json['api_token']?.toString();

    staff = json['staff'] != null && json['staff'] is Map<String, dynamic>
        ? Staff.fromJson(Map<String, dynamic>.from(json['staff']))
        : null;
    school = json['school'] != null && json['school'] is Map<String, dynamic>
        ? School.fromJson(Map<String, dynamic>.from(json['school']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (staff != null) {
      data['staff'] = staff!.toJson();
    }
    if (school != null) {
      data['school'] = school!.toJson();
    }
    return data;
  }
}

class Staff {
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

  Staff({
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

  Staff.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    role = json['role']?.toString();
    staffType = json['staff_type']?.toString();
    designation = json['designation']?.toString();
    whatsappNumber = json['whatsapp_number']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    schoolId = json['school_id'];
    teacherUniqueId = json['teacher_unique_id']?.toString();
    gender = json['gender']?.toString();
    status = json['status']?.toString();
    image = json['image']?.toString();
    thumbnail = json['thumbnail']?.toString();
    address = json['address']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['role'] = role;
    data['staff_type'] = staffType;
    data['designation'] = designation;
    data['whatsapp_number'] = whatsappNumber;
    data['phone'] = phone;
    data['email'] = email;
    data['school_id'] = schoolId;
    data['teacher_unique_id'] = teacherUniqueId;
    data['gender'] = gender;
    data['status'] = status;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['address'] = address;
    return data;
  }
}

class School {
  int? id;
  String? name;
  String? logo;
  String? address;
  String? phone;
  String? email;
  String? city;
  String? state;

  School({
    this.id,
    this.name,
    this.logo,
    this.address,
    this.phone,
    this.email,
    this.city,
    this.state,
  });

  School.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    logo = json['logo']?.toString();
    address = json['address']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    data['city'] = city;
    data['state'] = state;
    return data;
  }
}
