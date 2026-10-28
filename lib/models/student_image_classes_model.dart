class StudentImageClassesResponseModel {
  bool? success;
  String? message;
  StudentImageClassesData? data;

  StudentImageClassesResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory StudentImageClassesResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentImageClassesResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? StudentImageClassesData.fromJson(json['data']) : null,
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

class StudentImageClassesData {
  List<StudentClassItem>? classes;
  List<StudentSectionItem>? allSections;
  List<StudentStreamItem>? allStreams;

  StudentImageClassesData({
    this.classes,
    this.allSections,
    this.allStreams,
  });

  factory StudentImageClassesData.fromJson(Map<String, dynamic> json) {
    return StudentImageClassesData(
      classes: json['classes'] != null
          ? (json['classes'] as List).map((i) => StudentClassItem.fromJson(i)).toList()
          : null,
      allSections: json['all_sections'] != null
          ? (json['all_sections'] as List).map((i) => StudentSectionItem.fromJson(i)).toList()
          : null,
      allStreams: json['all_streams'] != null
          ? (json['all_streams'] as List).map((i) => StudentStreamItem.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes': classes?.map((v) => v.toJson()).toList(),
      'all_sections': allSections?.map((v) => v.toJson()).toList(),
      'all_streams': allStreams?.map((v) => v.toJson()).toList(),
    };
  }
}

class StudentClassItem {
  int? classId;
  String? className;
  List<StudentSectionItem>? sections;
  List<StudentStreamItem>? streams;

  StudentClassItem({
    this.classId,
    this.className,
    this.sections,
    this.streams,
  });

  factory StudentClassItem.fromJson(Map<String, dynamic> json) {
    return StudentClassItem(
      classId: json['class_id'] is int ? json['class_id'] : int.tryParse(json['class_id']?.toString() ?? ''),
      className: json['class_name']?.toString(),
      sections: json['sections'] != null
          ? (json['sections'] as List).map((i) => StudentSectionItem.fromJson(i)).toList()
          : null,
      streams: json['streams'] != null
          ? (json['streams'] as List).map((i) => StudentStreamItem.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'sections': sections?.map((v) => v.toJson()).toList(),
      'streams': streams?.map((v) => v.toJson()).toList(),
    };
  }
}

class StudentSectionItem {
  int? sectionId;
  String? sectionName;

  StudentSectionItem({
    this.sectionId,
    this.sectionName,
  });

  factory StudentSectionItem.fromJson(Map<String, dynamic> json) {
    return StudentSectionItem(
      sectionId: json['section_id'] is int ? json['section_id'] : int.tryParse(json['section_id']?.toString() ?? ''),
      sectionName: json['section_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'section_name': sectionName,
    };
  }
}

class StudentStreamItem {
  int? streamId;
  String? streamName;

  StudentStreamItem({
    this.streamId,
    this.streamName,
  });

  factory StudentStreamItem.fromJson(Map<String, dynamic> json) {
    return StudentStreamItem(
      streamId: json['stream_id'] is int ? json['stream_id'] : int.tryParse(json['stream_id']?.toString() ?? ''),
      streamName: json['stream_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stream_id': streamId,
      'stream_name': streamName,
    };
  }
}
