import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(const DashboardState()) {
    // Register event handlers
    on<DashboardDataRequested>(_onDashboardDataRequested);
    on<DashboardDataRefreshed>(_onDashboardDataRefreshed);
    on<DashboardErrorCleared>(_onDashboardErrorCleared);
  }

  // Handle initial dashboard data request
  Future<void> _onDashboardDataRequested(
    DashboardDataRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final dashboardStats = await _dashboardRepository.getDashboardStats();
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          dashboardStats: dashboardStats,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Handle dashboard data refresh
  Future<void> _onDashboardDataRefreshed(
    DashboardDataRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show loading state for refresh to avoid UI flicker
    try {
      final dashboardStats = await _dashboardRepository.refreshDashboardStats();
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          dashboardStats: dashboardStats,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // Clear error messages
  void _onDashboardErrorCleared(
    DashboardErrorCleared event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
