/// Generic API Response wrapper untuk handle berbagai format response dari API Gateway
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });

  /// Create success response
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required String error,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  /// Create from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    try {
      // Handle different response formats
      if (json.containsKey('success')) {
        // Format: {"success": true, "data": [...], "message": "..."}
        return ApiResponse<T>(
          success: json['success'] as bool,
          message: json['message'] as String?,
          data: json['data'] != null ? fromJsonT(json['data']) : null,
          error: json['error'] as String?,
          statusCode: json['status_code'] as int?,
          metadata: json['metadata'] as Map<String, dynamic>?,
        );
      } else if (json.containsKey('error')) {
        // Error format: {"error": "...", "details": "..."}
        return ApiResponse<T>(
          success: false,
          error: json['error'] as String,
          message: json['details'] as String? ?? json['message'] as String?,
          statusCode: json['status_code'] as int?,
        );
      } else {
        // Direct data format: [...]
        return ApiResponse<T>(
          success: true,
          data: fromJsonT(json),
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: $e',
      );
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': toJsonT(data as T),
      if (error != null) 'error': error,
      if (statusCode != null) 'status_code': statusCode,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Service status model untuk health check endpoints
class ServiceStatus {
  final String serviceName;
  final String status; // 'healthy', 'unhealthy', 'unknown'
  final String? url;
  final int? responseTime;
  final String? error;
  final DateTime timestamp;

  ServiceStatus({
    required this.serviceName,
    required this.status,
    this.url,
    this.responseTime,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      serviceName: json['service_name'] as String? ?? 'unknown',
      status: json['status'] as String? ?? 'unknown',
      url: json['url'] as String?,
      responseTime: json['response_time'] as int?,
      error: json['error'] as String?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'status': status,
      'url': url,
      'response_time': responseTime,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isHealthy => status.toLowerCase() == 'healthy' || status.toLowerCase() == 'reachable';
}

/// Pagination model untuk list responses
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = (json['data'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    final total = json['total'] as int? ?? dataList.length;
    final page = json['page'] as int? ?? 1;
    final perPage = json['per_page'] as int? ?? dataList.length;
    final totalPages = json['total_pages'] as int? ?? (total / perPage).ceil();

    return PaginatedResponse<T>(
      data: dataList,
      total: total,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    );
  }

  /// Create from simple list (no pagination info)
  factory PaginatedResponse.fromList(List<T> data) {
    return PaginatedResponse<T>(
      data: data,
      total: data.length,
      page: 1,
      perPage: data.length,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }
}