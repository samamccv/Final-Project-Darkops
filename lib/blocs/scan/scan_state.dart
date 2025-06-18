// lib/blocs/scan/scan_state.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../models/scan/scan_models.dart';
import '../../services/sms_service.dart';

enum ScanStatus {
  initial,
  loading,
  success,
  failure,
  permissionRequired,
  gmailConnected,
  gmailDisconnected,
}

enum ScanType { sms, email, url, qr, apk }

class ScanState extends Equatable {
  final ScanStatus status;
  final ScanType? currentScanType;
  final String? errorMessage;
  final double? progress;

  // Scan Results
  final SMSAnalysisResponse? smsResult;
  final URLAnalysisResponse? urlResult;
  final EmailAnalysisResponse? emailResult;
  final QRAnalysisResponse? qrResult;
  final APKAnalysisResponse? apkResult;

  // Additional Data
  final String? scannedContent;
  final File? scannedFile;
  final List<String>? deviceSMSMessages;
  final List<DeviceSMSMessage>? deviceSMSMessagesList;
  final bool isGmailConnected;
  final List<Map<String, dynamic>>? gmailEmails;
  final String? lastScanTarget;

  const ScanState({
    this.status = ScanStatus.initial,
    this.currentScanType,
    this.errorMessage,
    this.progress,
    this.smsResult,
    this.urlResult,
    this.emailResult,
    this.qrResult,
    this.apkResult,
    this.scannedContent,
    this.scannedFile,
    this.deviceSMSMessages,
    this.deviceSMSMessagesList,
    this.isGmailConnected = false,
    this.gmailEmails,
    this.lastScanTarget,
  });

  ScanState copyWith({
    ScanStatus? status,
    ScanType? currentScanType,
    String? errorMessage,
    double? progress,
    SMSAnalysisResponse? smsResult,
    URLAnalysisResponse? urlResult,
    EmailAnalysisResponse? emailResult,
    QRAnalysisResponse? qrResult,
    APKAnalysisResponse? apkResult,
    String? scannedContent,
    File? scannedFile,
    List<String>? deviceSMSMessages,
    List<DeviceSMSMessage>? deviceSMSMessagesList,
    bool? isGmailConnected,
    List<Map<String, dynamic>>? gmailEmails,
    String? lastScanTarget,
  }) {
    return ScanState(
      status: status ?? this.status,
      currentScanType: currentScanType ?? this.currentScanType,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
      smsResult: smsResult ?? this.smsResult,
      urlResult: urlResult ?? this.urlResult,
      emailResult: emailResult ?? this.emailResult,
      qrResult: qrResult ?? this.qrResult,
      apkResult: apkResult ?? this.apkResult,
      scannedContent: scannedContent ?? this.scannedContent,
      scannedFile: scannedFile ?? this.scannedFile,
      deviceSMSMessages: deviceSMSMessages ?? this.deviceSMSMessages,
      deviceSMSMessagesList:
          deviceSMSMessagesList ?? this.deviceSMSMessagesList,
      isGmailConnected: isGmailConnected ?? this.isGmailConnected,
      gmailEmails: gmailEmails ?? this.gmailEmails,
      lastScanTarget: lastScanTarget ?? this.lastScanTarget,
    );
  }

  ScanState clearResults() {
    return ScanState(
      status: ScanStatus.initial,
      currentScanType: null,
      errorMessage: null,
      progress: null,
      smsResult: null,
      urlResult: null,
      emailResult: null,
      qrResult: null,
      apkResult: null,
      scannedContent: null,
      scannedFile: null,
      deviceSMSMessages: deviceSMSMessages,
      deviceSMSMessagesList: deviceSMSMessagesList,
      isGmailConnected: isGmailConnected,
      gmailEmails: gmailEmails,
      lastScanTarget: null,
    );
  }

  // Getters for current scan result
  dynamic get currentResult {
    switch (currentScanType) {
      case ScanType.sms:
        return smsResult;
      case ScanType.url:
        return urlResult;
      case ScanType.email:
        return emailResult;
      case ScanType.qr:
        return qrResult;
      case ScanType.apk:
        return apkResult;
      default:
        return null;
    }
  }

  String? get currentThreatLevel {
    final result = currentResult;
    if (result is SMSAnalysisResponse) {
      return result.isPhishing ? 'HIGH' : 'LOW';
    } else if (result is URLAnalysisResponse) {
      return result.isSafe ? 'LOW' : 'HIGH';
    } else if (result is EmailAnalysisResponse) {
      return result.phishingDetection.prediction != null ? 'HIGH' : 'LOW';
    } else if (result is QRAnalysisResponse) {
      return result.isUrl ? 'MEDIUM' : 'LOW';
    } else if (result is APKAnalysisResponse) {
      return result.threatsDetected.isNotEmpty ? 'CRITICAL' : 'LOW';
    }
    return null;
  }

  double? get currentThreatScore {
    final result = currentResult;
    if (result is SMSAnalysisResponse) {
      return result.isPhishing ? 8.0 : 2.0;
    } else if (result is URLAnalysisResponse) {
      return result.isSafe ? 2.0 : 7.0;
    } else if (result is EmailAnalysisResponse) {
      return result.phishingDetection.prediction != null ? 7.0 : 3.0;
    } else if (result is QRAnalysisResponse) {
      return result.isUrl ? 5.0 : 2.0;
    } else if (result is APKAnalysisResponse) {
      return result.threatsDetected.isNotEmpty ? 9.0 : 3.0;
    }
    return null;
  }

  String? get currentScanTypeString {
    switch (currentScanType) {
      case ScanType.sms:
        return 'SMS';
      case ScanType.url:
        return 'URL';
      case ScanType.email:
        return 'EMAIL';
      case ScanType.qr:
        return 'QR';
      case ScanType.apk:
        return 'APK';
      default:
        return null;
    }
  }

  bool get hasResult => currentResult != null;
  bool get isLoading => status == ScanStatus.loading;
  bool get hasError => status == ScanStatus.failure;
  bool get isSuccess => status == ScanStatus.success;

  @override
  List<Object?> get props => [
    status,
    currentScanType,
    errorMessage,
    progress,
    smsResult,
    urlResult,
    emailResult,
    qrResult,
    apkResult,
    scannedContent,
    scannedFile,
    deviceSMSMessages,
    deviceSMSMessagesList,
    isGmailConnected,
    gmailEmails,
    lastScanTarget,
  ];
}
