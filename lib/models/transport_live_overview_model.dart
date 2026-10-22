class TransportLiveOverviewResponseModel {
  final bool success;
  final TransportLiveOverviewData? data;
  final String? message;

  TransportLiveOverviewResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory TransportLiveOverviewResponseModel.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    bool parsedSuccess = false;
    if (rawSuccess == true || rawSuccess == 1 || rawSuccess.toString().toLowerCase() == 'true') {
      parsedSuccess = true;
    }

    return TransportLiveOverviewResponseModel(
      success: parsedSuccess,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? TransportLiveOverviewData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

class TransportLiveOverviewData {
  final TransportLiveOverviewSummary? summary;
  final List<TransportFleetItem> fleet;

  TransportLiveOverviewData({
    this.summary,
    required this.fleet,
  });

  factory TransportLiveOverviewData.fromJson(Map<String, dynamic> json) {
    List<TransportFleetItem> fleetList = [];
    if (json['fleet'] != null && json['fleet'] is List) {
      fleetList = (json['fleet'] as List)
          .map((e) => TransportFleetItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TransportLiveOverviewData(
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? TransportLiveOverviewSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      fleet: fleetList,
    );
  }
}

class TransportLiveOverviewSummary {
  final int totalBuses;
  final int activeTrips;
  final int movingBuses;
  final int haltedBuses;
  final int signalLost;
  final int idleBuses;
  final int completedTripsToday;
  final int studentsOnBoard;
  final int unresolvedAlerts;
  final String? updatedAt;

  TransportLiveOverviewSummary({
    required this.totalBuses,
    required this.activeTrips,
    required this.movingBuses,
    required this.haltedBuses,
    required this.signalLost,
    required this.idleBuses,
    required this.completedTripsToday,
    required this.studentsOnBoard,
    required this.unresolvedAlerts,
    this.updatedAt,
  });

  factory TransportLiveOverviewSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportLiveOverviewSummary(
      totalBuses: parseInt(json['total_buses']),
      activeTrips: parseInt(json['active_trips']),
      movingBuses: parseInt(json['moving_buses']),
      haltedBuses: parseInt(json['halted_buses']),
      signalLost: parseInt(json['signal_lost']),
      idleBuses: parseInt(json['idle_buses']),
      completedTripsToday: parseInt(json['completed_trips_today']),
      studentsOnBoard: parseInt(json['students_on_board']),
      unresolvedAlerts: parseInt(json['unresolved_alerts']),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class TransportFleetItem {
  final int busId;
  final String busNumber;
  final String? plateNumber;
  final int seatingCapacity;
  final String vehicleStatus;
  final String vehicleStatusText;
  final TransportAssignedRoute? assignedRoute;
  final TransportDriver? driver;
  final TransportActiveTrip? activeTrip;

  TransportFleetItem({
    required this.busId,
    required this.busNumber,
    this.plateNumber,
    required this.seatingCapacity,
    required this.vehicleStatus,
    required this.vehicleStatusText,
    this.assignedRoute,
    this.driver,
    this.activeTrip,
  });

  factory TransportFleetItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportFleetItem(
      busId: parseInt(json['bus_id']),
      busNumber: json['bus_number']?.toString() ?? 'Bus',
      plateNumber: json['plate_number']?.toString(),
      seatingCapacity: parseInt(json['seating_capacity']),
      vehicleStatus: json['vehicle_status']?.toString() ?? 'idle',
      vehicleStatusText: json['vehicle_status_text']?.toString() ?? 'Idle',
      assignedRoute: json['assigned_route'] != null && json['assigned_route'] is Map<String, dynamic>
          ? TransportAssignedRoute.fromJson(json['assigned_route'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null && json['driver'] is Map<String, dynamic>
          ? TransportDriver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      activeTrip: json['active_trip'] != null && json['active_trip'] is Map<String, dynamic>
          ? TransportActiveTrip.fromJson(json['active_trip'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TransportAssignedRoute {
  final int id;
  final String name;
  final String? code;

  TransportAssignedRoute({
    required this.id,
    required this.name,
    this.code,
  });

  factory TransportAssignedRoute.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportAssignedRoute(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? 'Route',
      code: json['code']?.toString(),
    );
  }
}

class TransportDriver {
  final int id;
  final String name;
  final String? phone;
  final String? photo;

  TransportDriver({
    required this.id,
    required this.name,
    this.phone,
    this.photo,
  });

  factory TransportDriver.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportDriver(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? 'Driver',
      phone: json['phone']?.toString(),
      photo: json['photo']?.toString(),
    );
  }
}

class TransportActiveTrip {
  final int id;
  final String tripType;
  final String tripTypeLabel;
  final String? startedAt;
  final String? startedAtTime;
  final String? elapsedFormatted;
  final TransportTelemetry? telemetry;
  final TransportPassengerManifest? passengerManifest;
  final TransportActiveHalt? activeHalt;
  final int activeAlertsCount;

  TransportActiveTrip({
    required this.id,
    required this.tripType,
    required this.tripTypeLabel,
    this.startedAt,
    this.startedAtTime,
    this.elapsedFormatted,
    this.telemetry,
    this.passengerManifest,
    this.activeHalt,
    required this.activeAlertsCount,
  });

  factory TransportActiveTrip.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportActiveTrip(
      id: parseInt(json['id']),
      tripType: json['trip_type']?.toString() ?? 'pickup',
      tripTypeLabel: json['trip_type_label']?.toString() ?? 'Pickup Shift',
      startedAt: json['started_at']?.toString(),
      startedAtTime: json['started_at_time']?.toString(),
      elapsedFormatted: json['elapsed_formatted']?.toString(),
      telemetry: json['telemetry'] != null && json['telemetry'] is Map<String, dynamic>
          ? TransportTelemetry.fromJson(json['telemetry'] as Map<String, dynamic>)
          : null,
      passengerManifest: json['passenger_manifest'] != null && json['passenger_manifest'] is Map<String, dynamic>
          ? TransportPassengerManifest.fromJson(json['passenger_manifest'] as Map<String, dynamic>)
          : null,
      activeHalt: json['active_halt'] != null && json['active_halt'] is Map<String, dynamic>
          ? TransportActiveHalt.fromJson(json['active_halt'] as Map<String, dynamic>)
          : null,
      activeAlertsCount: parseInt(json['active_alerts_count']),
    );
  }
}

class TransportTelemetry {
  final num? latitude;
  final num? longitude;
  final num speed;
  final String? lastPingAt;
  final String? lastPingAgo;
  final bool isSignalLost;

  TransportTelemetry({
    this.latitude,
    this.longitude,
    required this.speed,
    this.lastPingAt,
    this.lastPingAgo,
    required this.isSignalLost,
  });

  factory TransportTelemetry.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString());
      return null;
    }

    bool parseBool(dynamic val) {
      if (val == true || val == 1 || val?.toString().toLowerCase() == 'true') return true;
      return false;
    }

    return TransportTelemetry(
      latitude: parseNum(json['latitude']),
      longitude: parseNum(json['longitude']),
      speed: parseNum(json['speed']) ?? 0,
      lastPingAt: json['last_ping_at']?.toString(),
      lastPingAgo: json['last_ping_ago']?.toString(),
      isSignalLost: parseBool(json['is_signal_lost']),
    );
  }
}

class TransportPassengerManifest {
  final int totalAllocated;
  final int boarded;
  final int deboarded;
  final int absent;
  final num progressPercent;

  TransportPassengerManifest({
    required this.totalAllocated,
    required this.boarded,
    required this.deboarded,
    required this.absent,
    required this.progressPercent,
  });

  factory TransportPassengerManifest.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    num parseNum(dynamic val) {
      if (val is num) return val;
      if (val != null) return num.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportPassengerManifest(
      totalAllocated: parseInt(json['total_allocated']),
      boarded: parseInt(json['boarded']),
      deboarded: parseInt(json['deboarded']),
      absent: parseInt(json['absent']),
      progressPercent: parseNum(json['progress_percent']),
    );
  }
}

class TransportActiveHalt {
  final int id;
  final String? reason;
  final String? startedAt;
  final String? durationText;

  TransportActiveHalt({
    required this.id,
    this.reason,
    this.startedAt,
    this.durationText,
  });

  factory TransportActiveHalt.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return TransportActiveHalt(
      id: parseInt(json['id']),
      reason: json['reason']?.toString(),
      startedAt: json['started_at']?.toString(),
      durationText: json['duration_text']?.toString(),
    );
  }
}
