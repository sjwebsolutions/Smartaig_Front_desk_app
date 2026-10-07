int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString().trim());
}

class StudentCountResponseModel {
  bool? success;
  String? message;
  StudentCountData? data;

  StudentCountResponseModel({this.success, this.message, this.data});

  StudentCountResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true ||
        json['status'] == true ||
        json['status'] == 200 ||
        json['status'] == 'success' ||
        json['status'] == '1';

    message = json['message']?.toString() ?? json['msg']?.toString();

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = StudentCountData.fromJson(Map<String, dynamic>.from(json['data']));
    }

    if (data != null) {
      success = true;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class StudentCountData {
  String? date;
  String? academicYear;
  OverallStats? overallStats;
  List<ClassWiseCount>? classWiseCounts;

  StudentCountData({
    this.date,
    this.academicYear,
    this.overallStats,
    this.classWiseCounts,
  });

  StudentCountData.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    academicYear = json['academic_year']?.toString();

    if (json['overall_stats'] != null && json['overall_stats'] is Map<String, dynamic>) {
      overallStats = OverallStats.fromJson(Map<String, dynamic>.from(json['overall_stats']));
    }

    if (json['class_wise_counts'] != null && json['class_wise_counts'] is List) {
      classWiseCounts = (json['class_wise_counts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ClassWiseCount.fromJson(item))
          .toList();
    } else {
      classWiseCounts = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['date'] = date;
    map['academic_year'] = academicYear;
    if (overallStats != null) {
      map['overall_stats'] = overallStats!.toJson();
    }
    if (classWiseCounts != null) {
      map['class_wise_counts'] = classWiseCounts!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class OverallStats {
  int? boysTotal;
  int? girlsTotal;
  int? overallTotal;

  OverallStats({
    this.boysTotal,
    this.girlsTotal,
    this.overallTotal,
  });

  OverallStats.fromJson(Map<String, dynamic> json) {
    boysTotal = _parseInt(json['boys_total']);
    girlsTotal = _parseInt(json['girls_total']);
    overallTotal = _parseInt(json['overall_total']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['boys_total'] = boysTotal;
    map['girls_total'] = girlsTotal;
    map['overall_total'] = overallTotal;
    return map;
  }
}

class ClassWiseCount {
  String? className;
  String? streamName;
  String? sectionName;
  int? boys;
  int? girls;
  int? total;

  ClassWiseCount({
    this.className,
    this.streamName,
    this.sectionName,
    this.boys,
    this.girls,
    this.total,
  });

  ClassWiseCount.fromJson(Map<String, dynamic> json) {
    className = json['class_name']?.toString();
    streamName = json['stream_name']?.toString();
    sectionName = json['section_name']?.toString();
    boys = _parseInt(json['boys']);
    girls = _parseInt(json['girls']);
    total = _parseInt(json['total']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['class_name'] = className;
    map['stream_name'] = streamName;
    map['section_name'] = sectionName;
    map['boys'] = boys;
    map['girls'] = girls;
    map['total'] = total;
    return map;
  }

  String get fullSectionTitle {
    final List<String> parts = [];
    if (className != null && className!.isNotEmpty) {
      parts.add('Class $className');
    }
    if (sectionName != null && sectionName!.isNotEmpty && sectionName!.toLowerCase() != 'n/a') {
      parts.add('Sec ${sectionName!.toUpperCase()}');
    }
    if (streamName != null && streamName!.isNotEmpty && streamName!.toLowerCase() != 'n/a') {
      parts.add(streamName!);
    }
    return parts.isNotEmpty ? parts.join(' - ') : (className ?? 'N/A');
  }
}
