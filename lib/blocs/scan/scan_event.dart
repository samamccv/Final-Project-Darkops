// lib/blocs/scan/scan_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

// SMS Events
class AnalyzeSMSEvent extends ScanEvent {
  final String message;

  const AnalyzeSMSEvent(this.message);

  @override
  List<Object> get props => [message];
}

class ParseSMSFromDeviceEvent extends ScanEvent {
  const ParseSMSFromDeviceEvent();
}

// URL Events
class AnalyzeURLEvent extends ScanEvent {
  final String url;

  const AnalyzeURLEvent(this.url);

  @override
  List<Object> get props => [url];
}

// Email Events
class AnalyzeEmailEvent extends ScanEvent {
  final File emailFile;

  const AnalyzeEmailEvent(this.emailFile);

  @override
  List<Object> get props => [emailFile];
}

class ConnectGmailEvent extends ScanEvent {
  const ConnectGmailEvent();
}

class ScanGmailEmailsEvent extends ScanEvent {
  final int limit;

  const ScanGmailEmailsEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

// QR Code Events
class AnalyzeQRFromCameraEvent extends ScanEvent {
  const AnalyzeQRFromCameraEvent();
}

class AnalyzeQRFromGalleryEvent extends ScanEvent {
  const AnalyzeQRFromGalleryEvent();
}

class AnalyzeQRContentEvent extends ScanEvent {
  final String content;

  const AnalyzeQRContentEvent(this.content);

  @override
  List<Object> get props => [content];
}

// APK Events
class AnalyzeAPKEvent extends ScanEvent {
  final File apkFile;

  const AnalyzeAPKEvent(this.apkFile);

  @override
  List<Object> get props => [apkFile];
}

class PickAPKFileEvent extends ScanEvent {
  const PickAPKFileEvent();
}

// General Events
class ResetScanStateEvent extends ScanEvent {
  const ResetScanStateEvent();
}

class ClearScanResultEvent extends ScanEvent {
  const ClearScanResultEvent();
}

class RetryLastScanEvent extends ScanEvent {
  const RetryLastScanEvent();
}
