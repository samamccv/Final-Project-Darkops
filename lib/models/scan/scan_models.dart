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

// Legacy URL Analysis Response (kept for backward compatibility)
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

// Comprehensive URL Analysis Response (matches web frontend)
class UrlAnalysisResponse extends ScanResponse {
  final UrlPhishingAnalysis? phishingAnalysis;
  final UrlAnalysisData? urlAnalysis;
  final String? analysisTimestamp;
  final List<UrlScanEngine>? scanEngines;
  final List<UrlFinding>? findings;

  const UrlAnalysisResponse({
    this.phishingAnalysis,
    this.urlAnalysis,
    this.analysisTimestamp,
    this.scanEngines,
    this.findings,
  });

  factory UrlAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return UrlAnalysisResponse(
      phishingAnalysis:
          json['phishing_analysis'] != null
              ? UrlPhishingAnalysis.fromJson(json['phishing_analysis'])
              : null,
      urlAnalysis:
          json['url_analysis'] != null
              ? UrlAnalysisData.fromJson(json['url_analysis'])
              : null,
      analysisTimestamp: json['analysis_timestamp'],
      scanEngines:
          (json['scanEngines'] as List?)
              ?.map((e) => UrlScanEngine.fromJson(e))
              .toList(),
      findings:
          (json['findings'] as List?)
              ?.map((e) => UrlFinding.fromJson(e))
              .toList(),
    );
  }

  @override
  List<Object?> get props => [
    phishingAnalysis,
    urlAnalysis,
    analysisTimestamp,
    scanEngines,
    findings,
  ];
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

// QR Phishing Analysis Response (matching Frontend)
class QRPhishingAnalysisResponse extends ScanResponse {
  final bool isPhishing;
  final double confidence;
  final String? prediction;
  final String? url;
  final List<String>? riskFactors;
  final List<String>? safetyIndicators;
  final QRUrlAnalysisData? urlAnalysis;
  final QRDnsInformation? dnsInformation;
  final QRSecurityAssessment? securityAssessment;
  final QRRecommendations? recommendations;
  final String? analysisTimestamp;

  const QRPhishingAnalysisResponse({
    required this.isPhishing,
    required this.confidence,
    this.prediction,
    this.url,
    this.riskFactors,
    this.safetyIndicators,
    this.urlAnalysis,
    this.dnsInformation,
    this.securityAssessment,
    this.recommendations,
    this.analysisTimestamp,
  });

  factory QRPhishingAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return QRPhishingAnalysisResponse(
      isPhishing: json['is_phishing'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      prediction: json['prediction'],
      url: json['url'],
      riskFactors: (json['risk_factors'] as List?)?.cast<String>(),
      safetyIndicators: (json['safety_indicators'] as List?)?.cast<String>(),
      urlAnalysis:
          json['url_analysis'] != null
              ? QRUrlAnalysisData.fromJson(json['url_analysis'])
              : null,
      dnsInformation:
          json['dns_information'] != null
              ? QRDnsInformation.fromJson(json['dns_information'])
              : null,
      securityAssessment:
          json['security_assessment'] != null
              ? QRSecurityAssessment.fromJson(json['security_assessment'])
              : null,
      recommendations:
          json['recommendations'] != null
              ? QRRecommendations.fromJson(json['recommendations'])
              : null,
      analysisTimestamp: json['analysis_timestamp'],
    );
  }

  @override
  List<Object?> get props => [
    isPhishing,
    confidence,
    prediction,
    url,
    riskFactors,
    safetyIndicators,
    urlAnalysis,
    dnsInformation,
    securityAssessment,
    recommendations,
    analysisTimestamp,
  ];
}

// Supporting classes for QR Phishing Analysis
class QRUrlAnalysisData extends Equatable {
  final QRBasicInfo? basicInfo;
  final QRSecurity? security;
  final QRScanInfo? scanInfo;

  const QRUrlAnalysisData({this.basicInfo, this.security, this.scanInfo});

  factory QRUrlAnalysisData.fromJson(Map<String, dynamic> json) {
    return QRUrlAnalysisData(
      basicInfo:
          json['basic_info'] != null
              ? QRBasicInfo.fromJson(json['basic_info'])
              : null,
      security:
          json['security'] != null
              ? QRSecurity.fromJson(json['security'])
              : null,
      scanInfo:
          json['scan_info'] != null
              ? QRScanInfo.fromJson(json['scan_info'])
              : null,
    );
  }

  @override
  List<Object?> get props => [basicInfo, security, scanInfo];
}

class QRBasicInfo extends Equatable {
  final String? domain;
  final String? ip;
  final String? country;
  final String? server;
  final String? securityState;
  final String? finalUrl;

  const QRBasicInfo({
    this.domain,
    this.ip,
    this.country,
    this.server,
    this.securityState,
    this.finalUrl,
  });

  factory QRBasicInfo.fromJson(Map<String, dynamic> json) {
    return QRBasicInfo(
      domain: json['domain'],
      ip: json['ip'],
      country: json['country'],
      server: json['server'],
      securityState: json['security_state'],
      finalUrl: json['final_url'],
    );
  }

  @override
  List<Object?> get props => [
    domain,
    ip,
    country,
    server,
    securityState,
    finalUrl,
  ];
}

class QRSecurity extends Equatable {
  final bool? malicious;
  final int? score;

  const QRSecurity({this.malicious, this.score});

  factory QRSecurity.fromJson(Map<String, dynamic> json) {
    return QRSecurity(malicious: json['malicious'], score: json['score']);
  }

  @override
  List<Object?> get props => [malicious, score];
}

class QRScanInfo extends Equatable {
  final String? screenshotUrl;

  const QRScanInfo({this.screenshotUrl});

  factory QRScanInfo.fromJson(Map<String, dynamic> json) {
    return QRScanInfo(screenshotUrl: json['screenshot_url']);
  }

  @override
  List<Object?> get props => [screenshotUrl];
}

class QRDnsInformation extends Equatable {
  final String domain;
  final List<String> ipAddresses;
  final String primaryIp;
  final Map<String, dynamic> dnsRecords;
  final Map<String, dynamic> reverseDns;
  final Map<String, dynamic> dnsAnalysis;
  final String dnsTimestamp;

  const QRDnsInformation({
    required this.domain,
    required this.ipAddresses,
    required this.primaryIp,
    required this.dnsRecords,
    required this.reverseDns,
    required this.dnsAnalysis,
    required this.dnsTimestamp,
  });

  factory QRDnsInformation.fromJson(Map<String, dynamic> json) {
    return QRDnsInformation(
      domain: json['domain'] ?? '',
      ipAddresses: (json['ip_addresses'] as List?)?.cast<String>() ?? [],
      primaryIp: json['primary_ip'] ?? '',
      dnsRecords: json['dns_records'] ?? {},
      reverseDns: json['reverse_dns'] ?? {},
      dnsAnalysis: json['dns_analysis'] ?? {},
      dnsTimestamp: json['dns_timestamp'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    domain,
    ipAddresses,
    primaryIp,
    dnsRecords,
    reverseDns,
    dnsAnalysis,
    dnsTimestamp,
  ];
}

class QRSecurityAssessment extends Equatable {
  final String sslStatus;
  final String? domainAge;
  final double? reputationScore;
  final List<String>? threatCategories;

  const QRSecurityAssessment({
    required this.sslStatus,
    this.domainAge,
    this.reputationScore,
    this.threatCategories,
  });

  factory QRSecurityAssessment.fromJson(Map<String, dynamic> json) {
    return QRSecurityAssessment(
      sslStatus: json['ssl_status'] ?? '',
      domainAge: json['domain_age'],
      reputationScore: json['reputation_score']?.toDouble(),
      threatCategories: (json['threat_categories'] as List?)?.cast<String>(),
    );
  }

  @override
  List<Object?> get props => [
    sslStatus,
    domainAge,
    reputationScore,
    threatCategories,
  ];
}

class QRRecommendations extends Equatable {
  final String userAction;
  final List<String> safetyTips;
  final List<String>? additionalChecks;

  const QRRecommendations({
    required this.userAction,
    required this.safetyTips,
    this.additionalChecks,
  });

  factory QRRecommendations.fromJson(Map<String, dynamic> json) {
    return QRRecommendations(
      userAction: json['user_action'] ?? '',
      safetyTips: (json['safety_tips'] as List?)?.cast<String>() ?? [],
      additionalChecks: (json['additional_checks'] as List?)?.cast<String>(),
    );
  }

  @override
  List<Object?> get props => [userAction, safetyTips, additionalChecks];
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

// URL Analysis Supporting Classes
class UrlPhishingAnalysis extends Equatable {
  final String? url;
  final bool? isSafe;
  final double? confidence;
  final String? prediction;

  const UrlPhishingAnalysis({
    this.url,
    this.isSafe,
    this.confidence,
    this.prediction,
  });

  factory UrlPhishingAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlPhishingAnalysis(
      url: json['url'],
      isSafe: json['is_safe'],
      confidence: json['confidence']?.toDouble(),
      prediction: json['prediction'],
    );
  }

  @override
  List<Object?> get props => [url, isSafe, confidence, prediction];
}

class UrlAnalysisData extends Equatable {
  final UrlBasicInfo? basicInfo;
  final List<dynamic>? technologies;
  final UrlBehavior? behavior;
  final UrlSecurity? security;
  final List<dynamic>? consoleMessages;
  final List<dynamic>? cookies;
  final UrlScanInfo? scanInfo;
  final UrlEnhancedSecurity? enhancedSecurity;
  final UrlReputation? reputation;
  final UrlTechnologyStack? technologyStack;

  const UrlAnalysisData({
    this.basicInfo,
    this.technologies,
    this.behavior,
    this.security,
    this.consoleMessages,
    this.cookies,
    this.scanInfo,
    this.enhancedSecurity,
    this.reputation,
    this.technologyStack,
  });

  factory UrlAnalysisData.fromJson(Map<String, dynamic> json) {
    return UrlAnalysisData(
      basicInfo:
          json['basic_info'] != null
              ? UrlBasicInfo.fromJson(json['basic_info'])
              : null,
      technologies: json['technologies'],
      behavior:
          json['behavior'] != null
              ? UrlBehavior.fromJson(json['behavior'])
              : null,
      security:
          json['security'] != null
              ? UrlSecurity.fromJson(json['security'])
              : null,
      consoleMessages: json['console_messages'],
      cookies: json['cookies'],
      scanInfo:
          json['scan_info'] != null
              ? UrlScanInfo.fromJson(json['scan_info'])
              : null,
      enhancedSecurity:
          json['enhanced_security'] != null
              ? UrlEnhancedSecurity.fromJson(json['enhanced_security'])
              : null,
      reputation:
          json['reputation'] != null
              ? UrlReputation.fromJson(json['reputation'])
              : null,
      technologyStack:
          json['technology_stack'] != null
              ? UrlTechnologyStack.fromJson(json['technology_stack'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
    basicInfo,
    technologies,
    behavior,
    security,
    consoleMessages,
    cookies,
    scanInfo,
    enhancedSecurity,
    reputation,
    technologyStack,
  ];
}

class UrlBasicInfo extends Equatable {
  final String? domain;
  final String? ip;
  final String? country;
  final String? server;
  final String? securityState;
  final String? finalUrl;

  const UrlBasicInfo({
    this.domain,
    this.ip,
    this.country,
    this.server,
    this.securityState,
    this.finalUrl,
  });

  factory UrlBasicInfo.fromJson(Map<String, dynamic> json) {
    return UrlBasicInfo(
      domain: json['domain'],
      ip: json['ip'],
      country: json['country'],
      server: json['server'],
      securityState: json['security_state'],
      finalUrl: json['final_url'],
    );
  }

  @override
  List<Object?> get props => [
    domain,
    ip,
    country,
    server,
    securityState,
    finalUrl,
  ];
}

class UrlBehavior extends Equatable {
  final int? requests;
  final int? domains;
  final Map<String, dynamic>? resources;
  final int? redirects;
  final int? mixedContent;

  const UrlBehavior({
    this.requests,
    this.domains,
    this.resources,
    this.redirects,
    this.mixedContent,
  });

  factory UrlBehavior.fromJson(Map<String, dynamic> json) {
    return UrlBehavior(
      requests: json['requests'],
      domains: json['domains'],
      resources: json['resources'],
      redirects: json['redirects'],
      mixedContent: json['mixed_content'],
    );
  }

  @override
  List<Object?> get props => [
    requests,
    domains,
    resources,
    redirects,
    mixedContent,
  ];
}

class UrlSecurity extends Equatable {
  final bool? malicious;
  final int? score;
  final List<String>? categories;
  final List<String>? brands;
  final List<String>? threats;
  final UrlDomSecurity? domSecurity;
  final List<UrlCertificate>? certificates;
  final Map<String, dynamic>? securityHeaders;

  const UrlSecurity({
    this.malicious,
    this.score,
    this.categories,
    this.brands,
    this.threats,
    this.domSecurity,
    this.certificates,
    this.securityHeaders,
  });

  factory UrlSecurity.fromJson(Map<String, dynamic> json) {
    return UrlSecurity(
      malicious: json['malicious'],
      score: json['score'],
      categories: (json['categories'] as List?)?.cast<String>(),
      brands: (json['brands'] as List?)?.cast<String>(),
      threats: (json['threats'] as List?)?.cast<String>(),
      domSecurity:
          json['dom_security'] != null
              ? UrlDomSecurity.fromJson(json['dom_security'])
              : null,
      certificates:
          (json['certificates'] as List?)
              ?.map((e) => UrlCertificate.fromJson(e))
              .toList(),
      securityHeaders: json['security_headers'],
    );
  }

  @override
  List<Object?> get props => [
    malicious,
    score,
    categories,
    brands,
    threats,
    domSecurity,
    certificates,
    securityHeaders,
  ];
}

class UrlDomSecurity extends Equatable {
  final List<dynamic>? vulnerableJsLibs;
  final int? externalScripts;
  final int? forms;
  final int? passwordFields;
  final List<dynamic>? suspiciousElements;

  const UrlDomSecurity({
    this.vulnerableJsLibs,
    this.externalScripts,
    this.forms,
    this.passwordFields,
    this.suspiciousElements,
  });

  factory UrlDomSecurity.fromJson(Map<String, dynamic> json) {
    return UrlDomSecurity(
      vulnerableJsLibs: json['vulnerable_js_libs'],
      externalScripts: json['external_scripts'],
      forms: json['forms'],
      passwordFields: json['password_fields'],
      suspiciousElements: json['suspicious_elements'],
    );
  }

  @override
  List<Object?> get props => [
    vulnerableJsLibs,
    externalScripts,
    forms,
    passwordFields,
    suspiciousElements,
  ];
}

class UrlCertificate extends Equatable {
  final String? subjectName;
  final String? issuer;
  final int? validFrom;
  final int? validTo;

  const UrlCertificate({
    this.subjectName,
    this.issuer,
    this.validFrom,
    this.validTo,
  });

  factory UrlCertificate.fromJson(Map<String, dynamic> json) {
    return UrlCertificate(
      subjectName: json['subjectName'],
      issuer: json['issuer'],
      validFrom: json['validFrom'],
      validTo: json['validTo'],
    );
  }

  @override
  List<Object?> get props => [subjectName, issuer, validFrom, validTo];
}

class UrlScanInfo extends Equatable {
  final String? scanId;
  final String? scanResultUrl;
  final String? screenshotUrl;
  final String? screenshotPath;
  final String? scanTime;
  final String? analysisTime;

  const UrlScanInfo({
    this.scanId,
    this.scanResultUrl,
    this.screenshotUrl,
    this.screenshotPath,
    this.scanTime,
    this.analysisTime,
  });

  factory UrlScanInfo.fromJson(Map<String, dynamic> json) {
    return UrlScanInfo(
      scanId: json['scan_id'],
      scanResultUrl: json['scan_result_url'],
      screenshotUrl: json['screenshot_url'],
      screenshotPath: json['screenshot_path'],
      scanTime: json['scan_time'],
      analysisTime: json['analysis_time'],
    );
  }

  @override
  List<Object?> get props => [
    scanId,
    scanResultUrl,
    screenshotUrl,
    screenshotPath,
    scanTime,
    analysisTime,
  ];
}

class UrlEnhancedSecurity extends Equatable {
  final bool? mixedContent;
  final List<dynamic>? vulnerableLibraries;
  final bool? suspiciousRedirects;
  final bool? insecureCookies;

  const UrlEnhancedSecurity({
    this.mixedContent,
    this.vulnerableLibraries,
    this.suspiciousRedirects,
    this.insecureCookies,
  });

  factory UrlEnhancedSecurity.fromJson(Map<String, dynamic> json) {
    return UrlEnhancedSecurity(
      mixedContent: json['mixed_content'],
      vulnerableLibraries: json['vulnerable_libraries'],
      suspiciousRedirects: json['suspicious_redirects'],
      insecureCookies: json['insecure_cookies'],
    );
  }

  @override
  List<Object?> get props => [
    mixedContent,
    vulnerableLibraries,
    suspiciousRedirects,
    insecureCookies,
  ];
}

class UrlReputation extends Equatable {
  final UrlDomainAge? domainAge;
  final UrlSslValidity? sslValidity;
  final String? blacklistStatus;

  const UrlReputation({this.domainAge, this.sslValidity, this.blacklistStatus});

  factory UrlReputation.fromJson(Map<String, dynamic> json) {
    return UrlReputation(
      domainAge:
          json['domain_age'] != null
              ? UrlDomainAge.fromJson(json['domain_age'])
              : null,
      sslValidity:
          json['ssl_validity'] != null
              ? UrlSslValidity.fromJson(json['ssl_validity'])
              : null,
      blacklistStatus: json['blacklist_status'],
    );
  }

  @override
  List<Object?> get props => [domainAge, sslValidity, blacklistStatus];
}

class UrlDomainAge extends Equatable {
  final String? error;
  final String? registrationDate;
  final int? ageDays;

  const UrlDomainAge({this.error, this.registrationDate, this.ageDays});

  factory UrlDomainAge.fromJson(Map<String, dynamic> json) {
    return UrlDomainAge(
      error: json['error'],
      registrationDate: json['registration_date'],
      ageDays: json['age_days'],
    );
  }

  @override
  List<Object?> get props => [error, registrationDate, ageDays];
}

class UrlSslValidity extends Equatable {
  final bool? valid;
  final String? reason;

  const UrlSslValidity({this.valid, this.reason});

  factory UrlSslValidity.fromJson(Map<String, dynamic> json) {
    return UrlSslValidity(valid: json['valid'], reason: json['reason']);
  }

  @override
  List<Object?> get props => [valid, reason];
}

class UrlTechnologyStack extends Equatable {
  final String? server;
  final List<String>? frameworks;
  final List<String>? analytics;
  final String? cms;

  const UrlTechnologyStack({
    this.server,
    this.frameworks,
    this.analytics,
    this.cms,
  });

  factory UrlTechnologyStack.fromJson(Map<String, dynamic> json) {
    return UrlTechnologyStack(
      server: json['server'],
      frameworks: (json['frameworks'] as List?)?.cast<String>(),
      analytics: (json['analytics'] as List?)?.cast<String>(),
      cms: json['cms'],
    );
  }

  @override
  List<Object?> get props => [server, frameworks, analytics, cms];
}

class UrlScanEngine extends Equatable {
  final String name;
  final String result;
  final double confidence;
  final String? riskLevel;
  final String? details;
  final String? version;
  final String? updateDate;

  const UrlScanEngine({
    required this.name,
    required this.result,
    required this.confidence,
    this.riskLevel,
    this.details,
    this.version,
    this.updateDate,
  });

  factory UrlScanEngine.fromJson(Map<String, dynamic> json) {
    return UrlScanEngine(
      name: json['name'] ?? '',
      result: json['result'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'],
      details: json['details'],
      version: json['version'],
      updateDate: json['updateDate'],
    );
  }

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

class UrlFinding extends Equatable {
  final String type;
  final String description;
  final String severity;
  final Map<String, dynamic>? details;

  const UrlFinding({
    required this.type,
    required this.description,
    required this.severity,
    this.details,
  });

  factory UrlFinding.fromJson(Map<String, dynamic> json) {
    return UrlFinding(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? '',
      details: json['details'],
    );
  }

  @override
  List<Object?> get props => [type, description, severity, details];
}
