class PoliciesResponseModel {
  final bool? success;
  final String? message;
  final PoliciesData? data;

  PoliciesResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory PoliciesResponseModel.fromJson(Map<String, dynamic> json) {
    return PoliciesResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? PoliciesData.fromJson(json['data']) : null,
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

class PoliciesData {
  final String? termsOfUse;
  final String? privacyPolicy;

  PoliciesData({
    this.termsOfUse,
    this.privacyPolicy,
  });

  factory PoliciesData.fromJson(Map<String, dynamic> json) {
    return PoliciesData(
      termsOfUse: json['terms_of_use'],
      privacyPolicy: json['privacy_policy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms_of_use': termsOfUse,
      'privacy_policy': privacyPolicy,
    };
  }
}
