class ApiService {
  // This is a mockup for an actual API service
  static Future<ApiResponse> postTimesheet(Map<String, dynamic> timesheetData) async {
    // Replace with actual API call implementation
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return ApiResponse(success: true); // Mocked response
  }
}

class ApiResponse {
  final bool success;
  ApiResponse({required this.success});
}
