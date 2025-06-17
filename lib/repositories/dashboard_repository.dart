import '../models/dashboard/dashboard_stats.dart';
import '../services/api_seevice.dart';

class DashboardRepository {
  final ApiService _apiService;

  DashboardRepository({required ApiService apiService}) : _apiService = apiService;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.getDashboardStats();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<DashboardStats> refreshDashboardStats() async {
    try {
      final response = await _apiService.getDashboardStats();
      return response;
    } catch (e) {
      throw Exception('Failed to refresh dashboard stats: $e');
    }
  }
}
