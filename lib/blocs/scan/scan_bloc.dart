// lib/blocs/scan/scan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/scan_service.dart';
import '../../services/google_auth_service.dart';
import '../../models/scan/scan_models.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanService _scanService;

  ScanBloc({
    required ScanService scanService,
    required GoogleAuthService googleAuthService,
  }) : _scanService = scanService,
       super(const ScanState()) {
    // SMS Events
    on<AnalyzeSMSEvent>(_onAnalyzeSMS);
    on<ParseSMSFromDeviceEvent>(_onParseSMSFromDevice);

    // URL Events
    on<AnalyzeURLEvent>(_onAnalyzeURL);

    // Email Events
    on<AnalyzeEmailEvent>(_onAnalyzeEmail);
    on<ConnectGmailEvent>(_onConnectGmail);
    on<ScanGmailEmailsEvent>(_onScanGmailEmails);

    // QR Events
    on<AnalyzeQRFromCameraEvent>(_onAnalyzeQRFromCamera);
    on<AnalyzeQRFromGalleryEvent>(_onAnalyzeQRFromGallery);
    on<AnalyzeQRContentEvent>(_onAnalyzeQRContent);

    // APK Events
    on<AnalyzeAPKEvent>(_onAnalyzeAPK);
    on<PickAPKFileEvent>(_onPickAPKFile);

    // General Events
    on<ResetScanStateEvent>(_onResetScanState);
    on<ClearScanResultEvent>(_onClearScanResult);
    on<RetryLastScanEvent>(_onRetryLastScan);
  }

  // SMS Analysis
  Future<void> _onAnalyzeSMS(
    AnalyzeSMSEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.loading,
        currentScanType: ScanType.sms,
        lastScanTarget: event.message,
        progress: 0.0,
      ),
    );

    try {
      emit(state.copyWith(progress: 0.3));

      final result = await _scanService.analyzeSMSWithSubmission(event.message);

      emit(state.copyWith(progress: 1.0));

      emit(
        state.copyWith(
          status: ScanStatus.success,
          smsResult: result,
          scannedContent: event.message,
          progress: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScanStatus.failure,
          errorMessage: e.toString(),
          progress: null,
        ),
      );
    }
  }

  Future<void> _onParseSMSFromDevice(
    ParseSMSFromDeviceEvent event,
    Emitter<ScanState> emit,
  ) async {
    // Check SMS permission
    final permission = await Permission.sms.request();
    if (!permission.isGranted) {
      emit(
        state.copyWith(
          status: ScanStatus.permissionRequired,
          errorMessage: 'SMS permission is required to read messages',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ScanStatus.loading));

    try {
      // Note: sms_advanced package would be used here to read SMS
      // For now, we'll emit a placeholder
      emit(
        state.copyWith(
          status: ScanStatus.success,
          deviceSMSMessages: ['Sample SMS message from device'],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScanStatus.failure,
          errorMessage: 'Failed to read SMS messages: $e',
        ),
      );
    }
  }

  // URL Analysis
  Future<void> _onAnalyzeURL(
    AnalyzeURLEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.loading,
        currentScanType: ScanType.url,
        lastScanTarget: event.url,
        progress: 0.0,
      ),
    );

    try {
      emit(state.copyWith(progress: 0.3));

      final result = await _scanService.analyzeURLWithSubmission(event.url);

      emit(state.copyWith(progress: 1.0));

      emit(
        state.copyWith(
          status: ScanStatus.success,
          urlResult: result,
          scannedContent: event.url,
          progress: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScanStatus.failure,
          errorMessage: e.toString(),
          progress: null,
        ),
      );
    }
  }

  // General Events
  void _onResetScanState(ResetScanStateEvent event, Emitter<ScanState> emit) {
    emit(const ScanState());
  }

  void _onClearScanResult(ClearScanResultEvent event, Emitter<ScanState> emit) {
    emit(state.clearResults());
  }

  void _onRetryLastScan(RetryLastScanEvent event, Emitter<ScanState> emit) {
    final lastTarget = state.lastScanTarget;
    final scanType = state.currentScanType;

    if (lastTarget != null && scanType != null) {
      switch (scanType) {
        case ScanType.sms:
          add(AnalyzeSMSEvent(lastTarget));
          break;
        case ScanType.url:
          add(AnalyzeURLEvent(lastTarget));
          break;
        case ScanType.qr:
          add(AnalyzeQRContentEvent(lastTarget));
          break;
        default:
          emit(
            state.copyWith(
              status: ScanStatus.failure,
              errorMessage: 'Cannot retry this scan type',
            ),
          );
      }
    }
  }

  // Placeholder methods for other scan types
  Future<void> _onAnalyzeEmail(
    AnalyzeEmailEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'Email scanning not implemented yet',
      ),
    );
  }

  Future<void> _onConnectGmail(
    ConnectGmailEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'Gmail connection not implemented yet',
      ),
    );
  }

  Future<void> _onScanGmailEmails(
    ScanGmailEmailsEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'Gmail scanning not implemented yet',
      ),
    );
  }

  Future<void> _onAnalyzeQRFromCamera(
    AnalyzeQRFromCameraEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'QR camera scanning not implemented yet',
      ),
    );
  }

  Future<void> _onAnalyzeQRFromGallery(
    AnalyzeQRFromGalleryEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'QR gallery scanning not implemented yet',
      ),
    );
  }

  Future<void> _onAnalyzeQRContent(
    AnalyzeQRContentEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.loading,
        currentScanType: ScanType.qr,
        lastScanTarget: event.content,
        progress: 0.0,
      ),
    );

    try {
      emit(state.copyWith(progress: 0.3));

      final result = await _scanService.analyzeQR(
        QRAnalysisRequest(content: event.content),
      );

      emit(state.copyWith(progress: 1.0));

      emit(
        state.copyWith(
          status: ScanStatus.success,
          qrResult: result,
          scannedContent: event.content,
          progress: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScanStatus.failure,
          errorMessage: e.toString(),
          progress: null,
        ),
      );
    }
  }

  Future<void> _onPickAPKFile(
    PickAPKFileEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'APK file picking not implemented yet',
      ),
    );
  }

  Future<void> _onAnalyzeAPK(
    AnalyzeAPKEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScanStatus.failure,
        errorMessage: 'APK analysis not implemented yet',
      ),
    );
  }
}
