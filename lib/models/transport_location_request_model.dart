class TransportLocationRequestsResponseModel {
  final bool success;
  final TransportLocationRequestsData? data;
  final String? message;

  TransportLocationRequestsResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory TransportLocationRequestsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return TransportLocationRequestsResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransportLocationRequestsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TransportLocationRequestsData {
  final TransportLocationSummary? summary;
  final List<TransportLocationRequestItem> requests;
  final TransportPagination? pagination;

  TransportLocationRequestsData({
    this.summary,
    required this.requests,
    this.pagination,
  });

  factory TransportLocationRequestsData.fromJson(Map<String, dynamic> json) {
    List<TransportLocationRequestItem> requestList = [];
    if (json['requests'] != null && json['requests'] is List) {
      requestList = (json['requests'] as List)
          .map((e) => TransportLocationRequestItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TransportLocationRequestsData(
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? TransportLocationSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      requests: requestList,
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? TransportPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransportLocationSummary {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  TransportLocationSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory TransportLocationSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportLocationSummary(
      total: parseInt(json['total']),
      pending: parseInt(json['pending']),
      approved: parseInt(json['approved']),
      rejected: parseInt(json['rejected']),
    );
  }
}

class TransportLocationRequestItem {
  final int id;
  final String status;
  final String statusLabel;
  final String? requestedVia;
  final String? requestedByName;
  final String? requestedByRole;
  final String? requestedAt;
  final String? requestedAtTime;
  final String? locationType;
  final TransportStudentInfo? student;
  final TransportInfo? transport;
  final TransportCoordinates? oldCoordinates;
  final TransportCoordinates? proposedCoordinates;
  final TransportAuditInfo? audit;

  TransportLocationRequestItem({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.requestedVia,
    this.requestedByName,
    this.requestedByRole,
    this.requestedAt,
    this.requestedAtTime,
    this.locationType,
    this.student,
    this.transport,
    this.oldCoordinates,
    this.proposedCoordinates,
    this.audit,
  });

  factory TransportLocationRequestItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportLocationRequestItem(
      id: parseInt(json['id']),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      requestedVia: json['requested_via']?.toString(),
      requestedByName: json['requested_by_name']?.toString(),
      requestedByRole: json['requested_by_role']?.toString(),
      requestedAt: json['requested_at']?.toString(),
      requestedAtTime: json['requested_at_time']?.toString(),
      locationType: json['location_type']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? TransportStudentInfo.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      transport: json['transport'] != null && json['transport'] is Map<String, dynamic>
          ? TransportInfo.fromJson(json['transport'] as Map<String, dynamic>)
          : null,
      oldCoordinates: json['old_coordinates'] != null && json['old_coordinates'] is Map<String, dynamic>
          ? TransportCoordinates.fromJson(json['old_coordinates'] as Map<String, dynamic>)
          : null,
      proposedCoordinates: json['proposed_coordinates'] != null && json['proposed_coordinates'] is Map<String, dynamic>
          ? TransportCoordinates.fromJson(json['proposed_coordinates'] as Map<String, dynamic>)
          : null,
      audit: json['audit'] != null && json['audit'] is Map<String, dynamic>
          ? TransportAuditInfo.fromJson(json['audit'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransportStudentInfo {
  final int id;
  final String? uniqueId;
  final String name;
  final String? className;
  final String? sectionName;
  final String? parentPhone;

  TransportStudentInfo({
    required this.id,
    this.uniqueId,
    required this.name,
    this.className,
    this.sectionName,
    this.parentPhone,
  });

  factory TransportStudentInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportStudentInfo(
      id: parseInt(json['id']),
      uniqueId: json['unique_id']?.toString(),
      name: json['name']?.toString() ?? 'Student',
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      parentPhone: json['parent_phone']?.toString(),
    );
  }

  String get fullClassSection {
    final List<String> parts = [];
    if (className != null && className!.isNotEmpty) parts.add('Class $className');
    if (sectionName != null && sectionName!.isNotEmpty) parts.add('Sec ${sectionName!.toUpperCase()}');
    return parts.isNotEmpty ? parts.join(' - ') : 'N/A';
  }
}

class TransportInfo {
  final String? busNumber;
  final String? routeName;
  final String? stoppageName;

  TransportInfo({
    this.busNumber,
    this.routeName,
    this.stoppageName,
  });

  factory TransportInfo.fromJson(Map<String, dynamic> json) {
    return TransportInfo(
      busNumber: json['bus_number']?.toString(),
      routeName: json['route_name']?.toString(),
      stoppageName: json['stoppage_name']?.toString(),
    );
  }
}

class TransportCoordinates {
  final num? pickupLatitude;
  final num? pickupLongitude;
  final num? dropLatitude;
  final num? dropLongitude;
  final String? address;
  final String? notes;

  TransportCoordinates({
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    this.address,
    this.notes,
  });

  factory TransportCoordinates.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString());
      return null;
    }

    return TransportCoordinates(
      pickupLatitude: parseNum(json['pickup_latitude']),
      pickupLongitude: parseNum(json['pickup_longitude']),
      dropLatitude: parseNum(json['drop_latitude']),
      dropLongitude: parseNum(json['drop_longitude']),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class TransportAuditInfo {
  final int? actionById;
  final String? actionByName;
  final String? actionByRole;
  final String? actionVia;
  final String? actionViaLabel;
  final String? actionAt;
  final String? rejectionReason;

  TransportAuditInfo({
    this.actionById,
    this.actionByName,
    this.actionByRole,
    this.actionVia,
    this.actionViaLabel,
    this.actionAt,
    this.rejectionReason,
  });

  factory TransportAuditInfo.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString());
      return null;
    }

    return TransportAuditInfo(
      actionById: parseInt(json['action_by_id']),
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionVia: json['action_via']?.toString(),
      actionViaLabel: json['action_via_label']?.toString(),
      actionAt: json['action_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }
}

class TransportPagination {
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  TransportPagination({
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory TransportPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 1;
      return 1;
    }

    return TransportPagination(
      total: parseInt(json['total']),
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
    );
  }
}

class TransportLocationRequestDetailResponseModel {
  final bool success;
  final TransportLocationRequestDetailItem? data;
  final String? message;

  TransportLocationRequestDetailResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory TransportLocationRequestDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return TransportLocationRequestDetailResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransportLocationRequestDetailItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TransportLocationRequestDetailItem {
  final int id;
  final String status;
  final String statusLabel;
  final String? requestedVia;
  final String? requestedByName;
  final String? requestedByRole;
  final String? requestedAt;
  final String? locationType;
  final String? addressNotes;
  final String? rejectionReason;
  final int? actionById;
  final String? actionByName;
  final String? actionByRole;
  final String? actionVia;
  final String? actionViaLabel;
  final String? actionAt;
  final TransportStudentInfo? student;
  final TransportInfo? transport;
  final TransportCoordinates? oldCoordinates;
  final TransportCoordinates? proposedCoordinates;

  TransportLocationRequestDetailItem({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.requestedVia,
    this.requestedByName,
    this.requestedByRole,
    this.requestedAt,
    this.locationType,
    this.addressNotes,
    this.rejectionReason,
    this.actionById,
    this.actionByName,
    this.actionByRole,
    this.actionVia,
    this.actionViaLabel,
    this.actionAt,
    this.student,
    this.transport,
    this.oldCoordinates,
    this.proposedCoordinates,
  });

  factory TransportLocationRequestDetailItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString());
      return null;
    }

    return TransportLocationRequestDetailItem(
      id: parseInt(json['id']),
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      requestedVia: json['requested_via']?.toString(),
      requestedByName: json['requested_by_name']?.toString(),
      requestedByRole: json['requested_by_role']?.toString(),
      requestedAt: json['requested_at']?.toString(),
      locationType: json['location_type']?.toString(),
      addressNotes: json['address_notes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      actionById: parseNullableInt(json['action_by_id']),
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionVia: json['action_via']?.toString(),
      actionViaLabel: json['action_via_label']?.toString(),
      actionAt: json['action_at']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? TransportStudentInfo.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      transport: json['transport'] != null && json['transport'] is Map<String, dynamic>
          ? TransportInfo.fromJson(json['transport'] as Map<String, dynamic>)
          : null,
      oldCoordinates: json['old_coordinates'] != null && json['old_coordinates'] is Map<String, dynamic>
          ? TransportCoordinates.fromJson(json['old_coordinates'] as Map<String, dynamic>)
          : null,
      proposedCoordinates: json['proposed_coordinates'] != null && json['proposed_coordinates'] is Map<String, dynamic>
          ? TransportCoordinates.fromJson(json['proposed_coordinates'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActionTransportLocationResponseModel {
  final bool success;
  final String message;
  final ActionTransportData? data;

  ActionTransportLocationResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ActionTransportLocationResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return ActionTransportLocationResponseModel(
      success: parsedSuccess,
      message: json['message']?.toString() ?? (parsedSuccess ? 'Success' : 'Operation failed'),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ActionTransportData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActionTransportData {
  final int id;
  final String status;
  final String? actionBy;
  final String? actionVia;
  final String? actionAt;
  final String? reason;

  ActionTransportData({
    required this.id,
    required this.status,
    this.actionBy,
    this.actionVia,
    this.actionAt,
    this.reason,
  });

  factory ActionTransportData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return ActionTransportData(
      id: parseInt(json['id']),
      status: json['status']?.toString() ?? 'completed',
      actionBy: json['approved_by']?.toString() ?? json['rejected_by']?.toString(),
      actionVia: json['action_via']?.toString(),
      actionAt: json['approved_at']?.toString() ?? json['rejected_at']?.toString(),
      reason: json['reason']?.toString() ?? json['rejection_reason']?.toString(),
    );
  }
}
