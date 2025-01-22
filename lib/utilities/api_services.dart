class ApiService {
  static Future<ApiResponse> postTimesheet(Map<String, dynamic> timesheetData) async {
    await Future.delayed(Duration(seconds: 2)); 
    return ApiResponse(success: true); 
  }
}

class ApiResponse {
  final bool success;
  ApiResponse({required this.success});
}
