class TransportHaltResponseModel {
  final bool success;
  final TransportHaltData? data;
  final String? message;

  TransportHaltResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory TransportHaltResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return TransportHaltResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransportHaltData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TransportHaltData {
  final List<TransportHaltItem> halts;
  final TransportHaltPagination? pagination;

  TransportHaltData({
    required this.halts,
    this.pagination,
  });

  factory TransportHaltData.fromJson(Map<String, dynamic> json) {
    List<TransportHaltItem> haltsList = [];
    if (json['halts'] != null && json['halts'] is List) {
      haltsList = (json['halts'] as List)
          .map((e) => TransportHaltItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TransportHaltData(
      halts: haltsList,
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? TransportHaltPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransportHaltItem {
  final int id;
  final TransportHaltBus? bus;
  final TransportHaltTrip? trip;
  final String? startedAt;
  final String? startedAtTime;
  final String? endedAt;
  final String? endedAtTime;
  final bool isOngoing;
  final int? durationSeconds;
  final String? durationFormatted;
  final String? reason;
  final TransportHaltLocation? location;
  final bool isAlertSent;

  TransportHaltItem({
    required this.id,
    this.bus,
    this.trip,
    this.startedAt,
    this.startedAtTime,
    this.endedAt,
    this.endedAtTime,
    required this.isOngoing,
    this.durationSeconds,
    this.durationFormatted,
    this.reason,
    this.location,
    required this.isAlertSent,
  });

  factory TransportHaltItem.fromJson(Map<String, dynamic> json) {
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

    return TransportHaltItem(
      id: parseInt(json['id']),
      bus: json['bus'] != null && json['bus'] is Map<String, dynamic>
          ? TransportHaltBus.fromJson(json['bus'] as Map<String, dynamic>)
          : null,
      trip: json['trip'] != null && json['trip'] is Map<String, dynamic>
          ? TransportHaltTrip.fromJson(json['trip'] as Map<String, dynamic>)
          : null,
      startedAt: json['started_at']?.toString(),
      startedAtTime: json['started_at_time']?.toString(),
      endedAt: json['ended_at']?.toString(),
      endedAtTime: json['ended_at_time']?.toString(),
      isOngoing: parseBool(json['is_ongoing']),
      durationSeconds: parseNullableInt(json['duration_seconds']),
      durationFormatted: json['duration_formatted']?.toString(),
      reason: json['reason']?.toString(),
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? TransportHaltLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      isAlertSent: parseBool(json['is_alert_sent']),
    );
  }
}

class TransportHaltBus {
  final int id;
  final String busNumber;
  final String? plateNumber;

  TransportHaltBus({
    required this.id,
    required this.busNumber,
    this.plateNumber,
  });

  factory TransportHaltBus.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportHaltBus(
      id: parseInt(json['id']),
      busNumber: json['bus_number']?.toString() ?? 'Bus',
      plateNumber: json['plate_number']?.toString(),
    );
  }
}

class TransportHaltTrip {
  final int id;
  final String? tripType;
  final String? routeName;
  final String? driverName;
  final String? driverPhone;

  TransportHaltTrip({
    required this.id,
    this.tripType,
    this.routeName,
    this.driverName,
    this.driverPhone,
  });

  factory TransportHaltTrip.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportHaltTrip(
      id: parseInt(json['id']),
      tripType: json['trip_type']?.toString(),
      routeName: json['route_name']?.toString(),
      driverName: json['driver_name']?.toString(),
      driverPhone: json['driver_phone']?.toString(),
    );
  }
}

class TransportHaltLocation {
  final num? latitude;
  final num? longitude;
  final String? address;

  TransportHaltLocation({
    this.latitude,
    this.longitude,
    this.address,
  });

  factory TransportHaltLocation.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString());
      return null;
    }

    return TransportHaltLocation(
      latitude: parseNum(json['latitude']),
      longitude: parseNum(json['longitude']),
      address: json['address']?.toString(),
    );
  }
}

class TransportHaltPagination {
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  TransportHaltPagination({
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory TransportHaltPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 1;
      return 1;
    }

    return TransportHaltPagination(
      total: parseInt(json['total']),
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
    );
  }
}
