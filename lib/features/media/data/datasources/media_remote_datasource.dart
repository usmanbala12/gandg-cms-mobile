import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class MediaRemoteDataSource {
  final Dio dio;
  final Logger logger;

  MediaRemoteDataSource({required this.dio, Logger? logger}) : logger = logger ?? Logger();

  Future<Map<String, dynamic>> uploadMedia({
    required File file,
    required String parentType,
    required String parentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'parent_type': parentType,
        'parent_id': parentId,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await dio.post(
        '/api/v1/media/upload',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      throw Exception('Failed to upload media: ${response.statusCode}');
    } catch (e) {
      logger.e('Error uploading media: $e');
      rethrow;
    }
  }

  Future<void> associateMedia({
    required String parentId,
    required String parentType,
    required List<String> mediaIds,
  }) async {
    try {
      final response = await dio.post(
        '/api/v1/media/associate',
        data: {
          'parent_id': parentId,
          'parent_type': parentType,
          'media_ids': mediaIds,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to associate media: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error associating media: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listMedia({
    required String parentType,
    required String parentId,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/media',
        queryParameters: {
          'parent_type': parentType,
          'parent_id': parentId,
        },
      );

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error listing media: $e');
      rethrow;
    }
  }

  Future<String> getDownloadUrl(String mediaId) async {
    try {
      final response = await dio.get('/api/v1/media/$mediaId/download');
      if (response.statusCode == 200) {
        final data = _unwrapMap(response.data);
        return data['url']?.toString() ?? data['fileUrl']?.toString() ?? '';
      }
      throw Exception('Failed to get download URL: ${response.statusCode}');
    } catch (e) {
      logger.e('Error getting download URL: $e');
      rethrow;
    }
  }

  Future<String> getThumbnailUrl(String mediaId) async {
    try {
      final response = await dio.get('/api/v1/media/$mediaId/thumbnail');
      if (response.statusCode == 200) {
        // Assuming the thumbnail endpoint returns a redirect or URL
        // If it returns JSON with a URL, adjust accordingly.
        // The guide says "GET /api/v1/media/{id}/thumbnail"
        // Let's assume it returns JSON with a URL like download.
        final data = _unwrapMap(response.data);
        return data['url']?.toString() ?? data['thumbnailUrl']?.toString() ?? '';
      }
      throw Exception('Failed to get thumbnail URL: ${response.statusCode}');
    } catch (e) {
      logger.e('Error getting thumbnail URL: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}
