import 'package:dio/dio.dart';
import 'package:field_link/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(dio: mockDio);
  });

  test('fetchProjects correctly parses paginated response', () async {
    // Arrange
    final paginatedResponse = {
      'success': true,
      'message': 'Projects retrieved successfully',
      'data': {
        'content': [
          {
            'id': '49f69fce-c578-4ab6-b953-47ad5e1fbfc0',
            'name': 'IBIA- ENUGU ROA',
            'location': 'ENUGU',
            'status': 'ACTIVE',
            'budget': 3000000.0,
          },
          {
            'id': 'f9cc6dc1-b28e-49b0-93bc-5a958f7d0a6f',
            'name': 'URBAN HIGHWAY ABUJA',
            'location': 'ABUJA',
            'status': 'COMPLETED',
            'budget': 10000000.0,
          },
        ],
        'pageNumber': 0,
        'pageSize': 20,
        'totalElements': 2,
        'totalPages': 1,
        'last': true,
        'first': true,
        'empty': false,
      },
      'timestamp': '2025-11-24T11:52:49.334385219',
    };

    when(() => mockDio.get('/api/v1/projects')).thenAnswer(
      (_) async => Response(
        data: paginatedResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v1/projects'),
      ),
    );

    // Act
    final projects = await apiClient.fetchProjects();

    // Assert
    expect(projects.length, 2);
    expect(projects[0]['name'], 'IBIA- ENUGU ROA');
    expect(projects[1]['name'], 'URBAN HIGHWAY ABUJA');
  });

  test(
    'fetchProjects correctly parses direct list response (backward compatibility)',
    () async {
      // Arrange
      final listResponse = {
        'data': [
          {'id': '1', 'name': 'Project 1'},
          {'id': '2', 'name': 'Project 2'},
        ],
      };

      when(() => mockDio.get('/api/v1/projects')).thenAnswer(
        (_) async => Response(
          data: listResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/projects'),
        ),
      );

      // Act
      final projects = await apiClient.fetchProjects();

      // Assert
      expect(projects.length, 2);
      expect(projects[0]['name'], 'Project 1');
    },
  );
}
