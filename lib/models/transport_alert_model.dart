class TransportAlertResponseModel {
  final bool success;
  final TransportAlertData? data;
  final String? message;

  TransportAlertResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory TransportAlertResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return TransportAlertResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransportAlertData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TransportAlertData {
  final List<TransportAlertItem> alerts;
  final TransportAlertPagination? pagination;

  TransportAlertData({
    required this.alerts,
    this.pagination,
  });

  factory TransportAlertData.fromJson(Map<String, dynamic> json) {
    List<TransportAlertItem> alertList = [];
    if (json['alerts'] != null && json['alerts'] is List) {
      alertList = (json['alerts'] as List)
          .map((e) => TransportAlertItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TransportAlertData(
      alerts: alertList,
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? TransportAlertPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransportAlertItem {
  final int id;
  final String alertType;
  final String alertTypeLabel;
  final String severity;
  final String title;
  final String message;
  final int? delayMinutes;
  final TransportAlertBus? bus;
  final TransportAlertRoute? route;
  final TransportAlertDriver? driver;
  final TransportAlertReportedBy? reportedBy;
  final TransportAlertLocation? location;
  final bool isResolved;
  final String? resolvedAt;
  final String? resolvedByName;
  final String? resolutionNotes;
  final TransportParentBroadcast? parentBroadcast;
  final String? createdAt;
  final String? createdAtTime;
  final String? createdAtAgo;

  TransportAlertItem({
    required this.id,
    required this.alertType,
    required this.alertTypeLabel,
    required this.severity,
    required this.title,
    required this.message,
    this.delayMinutes,
    this.bus,
    this.route,
    this.driver,
    this.reportedBy,
    this.location,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedByName,
    this.resolutionNotes,
    this.parentBroadcast,
    this.createdAt,
    this.createdAtTime,
    this.createdAtAgo,
  });

  factory TransportAlertItem.fromJson(Map<String, dynamic> json) {
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

    bool parseBool(dynamic val) {
      if (val == true || val == 1 || val?.toString().toLowerCase() == 'true') return true;
      return false;
    }

    return TransportAlertItem(
      id: parseInt(json['id']),
      alertType: json['alert_type']?.toString() ?? 'alert',
      alertTypeLabel: json['alert_type_label']?.toString() ?? 'Alert',
      severity: json['severity']?.toString() ?? 'warning',
      title: json['title']?.toString() ?? 'Alert',
      message: json['message']?.toString() ?? '',
      delayMinutes: parseNullableInt(json['delay_minutes']),
      bus: json['bus'] != null && json['bus'] is Map<String, dynamic>
          ? TransportAlertBus.fromJson(json['bus'] as Map<String, dynamic>)
          : null,
      route: json['route'] != null && json['route'] is Map<String, dynamic>
          ? TransportAlertRoute.fromJson(json['route'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null && json['driver'] is Map<String, dynamic>
          ? TransportAlertDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      reportedBy: json['reported_by'] != null && json['reported_by'] is Map<String, dynamic>
          ? TransportAlertReportedBy.fromJson(json['reported_by'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? TransportAlertLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      isResolved: parseBool(json['is_resolved']),
      resolvedAt: json['resolved_at']?.toString(),
      resolvedByName: json['resolved_by_name']?.toString(),
      resolutionNotes: json['resolution_notes']?.toString(),
      parentBroadcast: json['parent_broadcast'] != null && json['parent_broadcast'] is Map<String, dynamic>
          ? TransportParentBroadcast.fromJson(json['parent_broadcast'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at']?.toString(),
      createdAtTime: json['created_at_time']?.toString(),
      createdAtAgo: json['created_at_ago']?.toString(),
    );
  }
}

class TransportAlertBus {
  final int id;
  final String busNumber;
  final String? plateNumber;

  TransportAlertBus({
    required this.id,
    required this.busNumber,
    this.plateNumber,
  });

  factory TransportAlertBus.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportAlertBus(
      id: parseInt(json['id']),
      busNumber: json['bus_number']?.toString() ?? 'Bus',
      plateNumber: json['plate_number']?.toString(),
    );
  }
}

class TransportAlertRoute {
  final int id;
  final String name;

  TransportAlertRoute({
    required this.id,
    required this.name,
  });

  factory TransportAlertRoute.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportAlertRoute(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? 'Route',
    );
  }
}

class TransportAlertDriver {
  final int id;
  final String name;
  final String? phone;

  TransportAlertDriver({
    required this.id,
    required this.name,
    this.phone,
  });

  factory TransportAlertDriver.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportAlertDriver(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? 'Driver',
      phone: json['phone']?.toString(),
    );
  }
}

class TransportAlertReportedBy {
  final int id;
  final String name;
  final String? role;

  TransportAlertReportedBy({
    required this.id,
    required this.name,
    this.role,
  });

  factory TransportAlertReportedBy.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportAlertReportedBy(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? 'Reporter',
      role: json['role']?.toString(),
    );
  }
}

class TransportAlertLocation {
  final num? latitude;
  final num? longitude;
  final String? locationName;

  TransportAlertLocation({
    this.latitude,
    this.longitude,
    this.locationName,
  });

  factory TransportAlertLocation.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString());
      return null;
    }

    return TransportAlertLocation(
      latitude: parseNum(json['latitude']),
      longitude: parseNum(json['longitude']),
      locationName: json['location_name']?.toString(),
    );
  }
}

class TransportParentBroadcast {
  final bool sent;
  final String? sentAt;
  final int parentsCount;
  final String? broadcastMessage;

  TransportParentBroadcast({
    required this.sent,
    this.sentAt,
    required this.parentsCount,
    this.broadcastMessage,
  });

  factory TransportParentBroadcast.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val == true || val == 1 || val?.toString().toLowerCase() == 'true') return true;
      return false;
    }

    return TransportParentBroadcast(
      sent: parseBool(json['sent']),
      sentAt: json['sent_at']?.toString(),
      parentsCount: parseInt(json['parents_count']),
      broadcastMessage: json['broadcast_message']?.toString(),
    );
  }
}

class TransportAlertPagination {
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  TransportAlertPagination({
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory TransportAlertPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 1;
      return 1;
    }

    return TransportAlertPagination(
      total: parseInt(json['total']),
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
    );
  }
}
