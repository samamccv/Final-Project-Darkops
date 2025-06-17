// lib/models/scan/scan_models.dart
import 'package:equatable/equatable.dart';

// Base scan request/response models
abstract class ScanRequest extends Equatable {
  const ScanRequest();
}

abstract class ScanResponse extends Equatable {
  const ScanResponse();
}

// SMS Scan Models
class SMSAnalysisRequest extends ScanRequest {
  final String message;

  const SMSAnalysisRequest({required this.message});

  Map<String, dynamic> toJson() => {'message': message};

  @override
  List<Object> get props => [message];
}

class ModelResult extends Equatable {
  final bool isPhishing;
  final double confidence;
  final String riskLevel;
  final String modelName;
  final String? explanation;
  final String status;

  const ModelResult({
    required this.isPhishing,
    required this.confidence,
    required this.riskLevel,
    required this.modelName,
    this.explanation,
    required this.status,
  });

  factory ModelResult.fromJson(Map<String, dynamic> json) {
    return ModelResult(
      isPhishing: json['is_phishing'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'unknown',
      modelName: json['model_name'] ?? 'Unknown Model',
      explanation: json['explanation'],
      status: json['status'] ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [
    isPhishing,
    confidence,
    riskLevel,
    modelName,
    explanation,
    status,
  ];
}

class CombinedAssessment extends Equatable {
  final bool isPhishing;
  final double confidence;
  final String riskLevel;
  final bool consensus;
  final String explanation;

  const CombinedAssessment({
    required this.isPhishing,
    required this.confidence,
    required this.riskLevel,
    required this.consensus,
    required this.explanation,
  });

  factory CombinedAssessment.fromJson(Map<String, dynamic> json) {
    return CombinedAssessment(
      isPhishing: json['is_phishing'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'unknown',
      consensus: json['consensus'] ?? false,
      explanation: json['explanation'] ?? '',
    );
  }

  @override
  List<Object> get props => [
    isPhishing,
    confidence,
    riskLevel,
    consensus,
    explanation,
  ];
}

class SMSAnalysisResponse extends ScanResponse {
  // Legacy fields for backward compatibility
  final String prediction;
  final bool isPhishing;
  final double? confidence;
  final String? riskLevel;

  // Dual-model results
  final ModelResult? model1;
  final ModelResult? model2;

  // Combined assessment
  final CombinedAssessment? combinedAssessment;

  // Analysis metadata
  final String? analysisTimestamp;
  final List<String>? modelsUsed;

  const SMSAnalysisResponse({
    required this.prediction,
    required this.isPhishing,
    this.confidence,
    this.riskLevel,
    this.model1,
    this.model2,
    this.combinedAssessment,
    this.analysisTimestamp,
    this.modelsUsed,
  });

  factory SMSAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return SMSAnalysisResponse(
      prediction:
          json['prediction'] ??
          (json['is_phishing'] == true ? 'phishing' : 'ham'),
      isPhishing: json['is_phishing'] ?? false,
      confidence: json['confidence']?.toDouble(),
      riskLevel: json['risk_level'],
      model1:
          json['model_1'] != null
              ? ModelResult.fromJson(json['model_1'])
              : null,
      model2:
          json['model_2'] != null
              ? ModelResult.fromJson(json['model_2'])
              : null,
      combinedAssessment:
          json['combined_assessment'] != null
              ? CombinedAssessment.fromJson(json['combined_assessment'])
              : null,
      analysisTimestamp: json['analysis_timestamp'],
      modelsUsed:
          json['models_used'] != null
              ? List<String>.from(json['models_used'])
              : null,
    );
  }

  // Helper methods for UI display
  String get displayModelName1 => _getDisplayModelName(model1?.modelName);
  String get displayModelName2 => _getDisplayModelName(model2?.modelName);

  String _getDisplayModelName(String? modelName) {
    if (modelName == null) return 'Unknown Model';
    if (modelName.contains('Gemini') ||
        modelName.contains('Model 2') ||
        modelName.contains('model_2') ||
        modelName.toLowerCase().contains('gemini')) {
      return 'Model V2.0';
    }
    if (modelName.contains('BERT') ||
        modelName.contains('Model 1') ||
        modelName.contains('model_1') ||
        modelName.toLowerCase().contains('bert')) {
      return 'Model V1.0';
    }
    return modelName;
  }

  // Get the primary result to display (combined assessment if available, otherwise legacy)
  bool get primaryIsPhishing => combinedAssessment?.isPhishing ?? isPhishing;
  double get primaryConfidence =>
      combinedAssessment?.confidence ?? confidence ?? 0.0;
  String get primaryRiskLevel =>
      combinedAssessment?.riskLevel ?? riskLevel ?? 'unknown';

  // Check if this is a dual-model result
  bool get isDualModel => model1 != null || model2 != null;

  // Check if models are available and successful
  bool get hasModel1 => model1?.status == 'success';
  bool get hasModel2 => model2?.status == 'success';

  @override
  List<Object?> get props => [
    prediction,
    isPhishing,
    confidence,
    riskLevel,
    model1,
    model2,
    combinedAssessment,
    analysisTimestamp,
    modelsUsed,
  ];
}

// URL Scan Models
class URLAnalysisRequest extends ScanRequest {
  final String url;

  const URLAnalysisRequest({required this.url});

  Map<String, dynamic> toJson() => {'url': url};

  @override
  List<Object> get props => [url];
}

class URLAnalysisResponse extends ScanResponse {
  final String url;
  final bool isSafe;
  final double confidence;
  final String prediction;
  final Map<String, dynamic>? urlAnalysis;

  const URLAnalysisResponse({
    required this.url,
    required this.isSafe,
    required this.confidence,
    required this.prediction,
    this.urlAnalysis,
  });

  factory URLAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return URLAnalysisResponse(
      url: json['url'] ?? '',
      isSafe: json['is_safe'] ?? false,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      prediction: json['prediction'] ?? '',
      urlAnalysis: json['url_analysis'],
    );
  }

  @override
  List<Object?> get props => [url, isSafe, confidence, prediction, urlAnalysis];
}

// Email Scan Models
class EmailAnalysisResponse extends ScanResponse {
  final Map<String, dynamic> headers;
  final String? senderIp;
  final EmailIpInfo? ipInfo;
  final List<EmailAttachment> attachments;
  final EmailPhishingDetection phishingDetection;
  final String analysisTimestamp;
  final String? screenshotUrl;
  final List<EmailScanEngine>? scanEngines;

  const EmailAnalysisResponse({
    required this.headers,
    this.senderIp,
    this.ipInfo,
    required this.attachments,
    required this.phishingDetection,
    required this.analysisTimestamp,
    this.screenshotUrl,
    this.scanEngines,
  });

  factory EmailAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return EmailAnalysisResponse(
      headers: json['headers'] ?? {},
      senderIp: json['sender_ip'],
      ipInfo:
          json['ip_info'] != null
              ? EmailIpInfo.fromJson(json['ip_info'])
              : null,
      attachments:
          (json['attachments'] as List?)
              ?.map((e) => EmailAttachment.fromJson(e))
              .toList() ??
          [],
      phishingDetection: EmailPhishingDetection.fromJson(
        json['phishing_detection'] ?? {},
      ),
      analysisTimestamp: json['analysis_timestamp'] ?? '',
      screenshotUrl: json['screenshot_url'],
      scanEngines:
          (json['scanEngines'] as List?)
              ?.map((e) => EmailScanEngine.fromJson(e))
              .toList(),
    );
  }

  // Helper methods for UI display
  bool get isPhishing =>
      phishingDetection.predictionLabel?.toLowerCase() == "phishing" ||
      phishingDetection.prediction == 1;

  double get confidence {
    final conf = phishingDetection.confidence ?? 0.0;
    return conf > 1 ? conf : conf * 100;
  }

  String get threatLevel {
    if (isPhishing) {
      if (confidence >= 80) return "CRITICAL";
      if (confidence >= 60) return "HIGH";
      return "MEDIUM";
    }
    return "LOW";
  }

  String get fromEmail => headers['From'] ?? 'Unknown';
  String get toEmail => headers['To'] ?? 'Unknown';
  String get subject => headers['Subject'] ?? 'No Subject';
  String get dateString => headers['Date'] ?? 'Unknown';

  @override
  List<Object?> get props => [
    headers,
    senderIp,
    ipInfo,
    attachments,
    phishingDetection,
    analysisTimestamp,
    screenshotUrl,
    scanEngines,
  ];
}

class EmailIpInfo extends Equatable {
  final EmailIpInfoDetails? ipinfo;
  final EmailAbuseIpDb? abuseipdb;

  const EmailIpInfo({this.ipinfo, this.abuseipdb});

  factory EmailIpInfo.fromJson(Map<String, dynamic> json) {
    return EmailIpInfo(
      ipinfo:
          json['ipinfo'] != null
              ? EmailIpInfoDetails.fromJson(json['ipinfo'])
              : null,
      abuseipdb:
          json['abuseipdb'] != null
              ? EmailAbuseIpDb.fromJson(json['abuseipdb'])
              : null,
    );
  }

  @override
  List<Object?> get props => [ipinfo, abuseipdb];
}

class EmailIpInfoDetails extends Equatable {
  final String? ip;
  final String? hostname;
  final String? city;
  final String? region;
  final String? country;
  final String? loc;
  final String? org;
  final String? postal;
  final String? timezone;

  const EmailIpInfoDetails({
    this.ip,
    this.hostname,
    this.city,
    this.region,
    this.country,
    this.loc,
    this.org,
    this.postal,
    this.timezone,
  });

  factory EmailIpInfoDetails.fromJson(Map<String, dynamic> json) {
    return EmailIpInfoDetails(
      ip: json['ip'],
      hostname: json['hostname'],
      city: json['city'],
      region: json['region'],
      country: json['country'],
      loc: json['loc'],
      org: json['org'],
      postal: json['postal'],
      timezone: json['timezone'],
    );
  }

  String get locationString {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (region != null) parts.add(region!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
    ip,
    hostname,
    city,
    region,
    country,
    loc,
    org,
    postal,
    timezone,
  ];
}

class EmailAbuseIpDb extends Equatable {
  final String? ipAddress;
  final bool? isPublic;
  final int? ipVersion;
  final bool? isWhitelisted;
  final int? abuseConfidenceScore;
  final String? countryCode;
  final String? usageType;
  final String? isp;
  final String? domain;
  final List<String>? hostnames;
  final bool? isTor;
  final int? totalReports;
  final int? numDistinctUsers;
  final String? lastReportedAt;

  const EmailAbuseIpDb({
    this.ipAddress,
    this.isPublic,
    this.ipVersion,
    this.isWhitelisted,
    this.abuseConfidenceScore,
    this.countryCode,
    this.usageType,
    this.isp,
    this.domain,
    this.hostnames,
    this.isTor,
    this.totalReports,
    this.numDistinctUsers,
    this.lastReportedAt,
  });

  factory EmailAbuseIpDb.fromJson(Map<String, dynamic> json) {
    return EmailAbuseIpDb(
      ipAddress: json['ipAddress'],
      isPublic: json['isPublic'],
      ipVersion: json['ipVersion'],
      isWhitelisted: json['isWhitelisted'],
      abuseConfidenceScore: json['abuseConfidenceScore'],
      countryCode: json['countryCode'],
      usageType: json['usageType'],
      isp: json['isp'],
      domain: json['domain'],
      hostnames: (json['hostnames'] as List?)?.cast<String>(),
      isTor: json['isTor'],
      totalReports: json['totalReports'],
      numDistinctUsers: json['numDistinctUsers'],
      lastReportedAt: json['lastReportedAt'],
    );
  }

  @override
  List<Object?> get props => [
    ipAddress,
    isPublic,
    ipVersion,
    isWhitelisted,
    abuseConfidenceScore,
    countryCode,
    usageType,
    isp,
    domain,
    hostnames,
    isTor,
    totalReports,
    numDistinctUsers,
    lastReportedAt,
  ];
}

class EmailScanEngine extends Equatable {
  final String name;
  final String result;
  final double confidence;
  final String? riskLevel;
  final String? details;
  final String? version;
  final String? updateDate;

  const EmailScanEngine({
    required this.name,
    required this.result,
    required this.confidence,
    this.riskLevel,
    this.details,
    this.version,
    this.updateDate,
  });

  factory EmailScanEngine.fromJson(Map<String, dynamic> json) {
    return EmailScanEngine(
      name: json['name'] ?? '',
      result: json['result'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'],
      details: json['details'],
      version: json['version'],
      updateDate: json['updateDate'],
    );
  }

  bool get isThreat =>
      result.toLowerCase() == "phishing" ||
      result.toLowerCase() == "malicious" ||
      result.toLowerCase() == "fail";

  @override
  List<Object?> get props => [
    name,
    result,
    confidence,
    riskLevel,
    details,
    version,
    updateDate,
  ];
}

class EmailAttachment extends Equatable {
  final String filename;
  final String? contentType;
  final int? size;
  final String? path;
  final bool? isMalicious;
  final String? scanResult;

  const EmailAttachment({
    required this.filename,
    this.contentType,
    this.size,
    this.path,
    this.isMalicious,
    this.scanResult,
  });

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      filename: json['filename'] ?? '',
      contentType: json['content_type'],
      size: json['size'],
      path: json['path'],
      isMalicious: json['is_malicious'],
      scanResult: json['scan_result'],
    );
  }

  @override
  List<Object?> get props => [
    filename,
    contentType,
    size,
    path,
    isMalicious,
    scanResult,
  ];
}

class EmailPhishingDetection extends Equatable {
  final String? prediction;
  final String? predictionLabel;
  final double? confidence;
  final int? predictionValue;

  const EmailPhishingDetection({
    this.prediction,
    this.predictionLabel,
    this.confidence,
    this.predictionValue,
  });

  factory EmailPhishingDetection.fromJson(Map<String, dynamic> json) {
    return EmailPhishingDetection(
      prediction: json['prediction']?.toString(),
      predictionLabel: json['prediction_label'],
      confidence: json['confidence']?.toDouble(),
      predictionValue: json['prediction']?.toInt(),
    );
  }

  @override
  List<Object?> get props => [
    prediction,
    predictionLabel,
    confidence,
    predictionValue,
  ];
}

// QR Code Scan Models
class QRAnalysisRequest extends ScanRequest {
  final String content;

  const QRAnalysisRequest({required this.content});

  Map<String, dynamic> toJson() => {'content': content};

  @override
  List<Object> get props => [content];
}

class QRAnalysisResponse extends ScanResponse {
  final String content;
  final String contentType;
  final bool isUrl;
  final Map<String, dynamic>? urlAnalysis;
  final String analysisTimestamp;

  const QRAnalysisResponse({
    required this.content,
    required this.contentType,
    required this.isUrl,
    this.urlAnalysis,
    required this.analysisTimestamp,
  });

  factory QRAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return QRAnalysisResponse(
      content: json['content'] ?? '',
      contentType: json['content_type'] ?? '',
      isUrl: json['is_url'] ?? false,
      urlAnalysis: json['url_analysis'],
      analysisTimestamp: json['analysis_timestamp'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    content,
    contentType,
    isUrl,
    urlAnalysis,
    analysisTimestamp,
  ];
}

// APK Scan Models
class APKAnalysisResponse extends ScanResponse {
  final String filename;
  final String scanId;
  final Map<String, dynamic> scanResults;
  final List<String> threatsDetected;
  final String scanTimestamp;
  final Map<String, dynamic>? malwareDetection;

  const APKAnalysisResponse({
    required this.filename,
    required this.scanId,
    required this.scanResults,
    required this.threatsDetected,
    required this.scanTimestamp,
    this.malwareDetection,
  });

  factory APKAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return APKAnalysisResponse(
      filename: json['filename'] ?? '',
      scanId: json['scan_id'] ?? '',
      scanResults: json['scan_results'] ?? {},
      threatsDetected: List<String>.from(json['threats_detected'] ?? []),
      scanTimestamp: json['scan_timestamp'] ?? '',
      malwareDetection: json['malware_detection'],
    );
  }

  @override
  List<Object?> get props => [
    filename,
    scanId,
    scanResults,
    threatsDetected,
    scanTimestamp,
    malwareDetection,
  ];
}

// Scan Result Models for GraphQL Integration
class ScanResultSubmission extends Equatable {
  final String scanType;
  final String target;
  final double threatScore;
  final String threatLevel;
  final String sr;
  final List<Finding> findings;
  final double? confidence;

  const ScanResultSubmission({
    required this.scanType,
    required this.target,
    required this.threatScore,
    required this.threatLevel,
    required this.sr,
    required this.findings,
    this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'scanType': scanType,
    'target': target,
    'threatScore': threatScore,
    'threatLevel': threatLevel,
    'sr': sr,
    'findings': findings.map((f) => f.toJson()).toList(),
    'confidence': confidence,
  };

  @override
  List<Object?> get props => [
    scanType,
    target,
    threatScore,
    threatLevel,
    sr,
    findings,
    confidence,
  ];
}

class Finding extends Equatable {
  final String type;
  final String severity;
  final String description;
  final Map<String, dynamic>? details;

  const Finding({
    required this.type,
    required this.severity,
    required this.description,
    this.details,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity,
    'description': description,
    'details': details,
  };

  @override
  List<Object?> get props => [type, severity, description, details];
}
