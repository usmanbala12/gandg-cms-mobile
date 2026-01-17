import 'package:equatable/equatable.dart';

enum MediaType {
  image,
  video,
  document,
  other;

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => MediaType.other,
    );
  }
}

class MediaEntity extends Equatable {
  final String id;
  final MediaType fileType;
  final int fileSizeBytes;
  final String mimeType;
  final String uploaderId;
  final String uploaderName;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const MediaEntity({
    required this.id,
    required this.fileType,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploaderId,
    required this.uploaderName,
    required this.createdAt,
    this.metadata,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) {
    return MediaEntity(
      id: json['id']?.toString() ?? '',
      fileType: MediaType.fromString(json['fileType']?.toString() ?? 'other'),
      fileSizeBytes: (json['fileSizeBytes'] is num) 
          ? (json['fileSizeBytes'] as num).toInt() 
          : 0,
      mimeType: json['mimeType']?.toString() ?? 'application/octet-stream',
      uploaderId: json['uploaderId']?.toString() ?? '',
      uploaderName: json['uploaderName']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] is Map<String, dynamic> 
          ? json['metadata'] as Map<String, dynamic> 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileType': fileType.name,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        fileType,
        fileSizeBytes,
        mimeType,
        uploaderId,
        uploaderName,
        createdAt,
        metadata,
      ];
}
