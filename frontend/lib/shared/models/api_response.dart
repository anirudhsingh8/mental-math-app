/// A generic model for handling API responses in a consistent way
class ApiResponse<T> {
  /// Whether the API call was successful
  final bool success;

  /// Optional data returned from the API
  final T? data;

  /// Optional message from the API
  final String? message;

  /// Optional error details if the request failed
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  /// Create an ApiResponse from raw JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    // Handle the case where data may not be present
    T? data;
    if (json.containsKey('data') && json['data'] != null) {
      data = fromJson(json['data']);
    }

    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: data,
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }
}

class ApiPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  ApiPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) {
    return ApiPagination(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
    );
  }
}
