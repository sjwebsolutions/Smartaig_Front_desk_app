class SupportSettingsResponseModel {
  final bool? success;
  final String? message;
  final SupportSettingsData? data;

  SupportSettingsResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory SupportSettingsResponseModel.fromJson(Map<String, dynamic> json) {
    return SupportSettingsResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? SupportSettingsData.fromJson(json['data']) : null,
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

class SupportSettingsData {
  final String? name;
  final String? whatsapp;
  final String? mobile;
  final String? email;

  SupportSettingsData({
    this.name,
    this.whatsapp,
    this.mobile,
    this.email,
  });

  factory SupportSettingsData.fromJson(Map<String, dynamic> json) {
    return SupportSettingsData(
      name: json['name'],
      whatsapp: json['whatsapp']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'whatsapp': whatsapp,
      'mobile': mobile,
      'email': email,
    };
  }
}
