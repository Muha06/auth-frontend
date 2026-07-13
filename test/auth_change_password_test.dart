import 'package:auth_frontend/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'changePassword sends old and new passwords in the request body',
    () async {
      final dio = Dio();
      RequestOptions? capturedRequest;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: {}),
            );
          },
        ),
      );

      final remote = AuthRemoteDs(
        baseUrl: 'https://example.com/auth',
        client: dio,
      );

      await remote.changePassword(
        oldPassword: 'old-pass-123',
        newPassword: 'new-pass-456',
        accessToken: 'abc-token',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'PATCH');
      expect(capturedRequest!.data, {
        'oldPassword': 'old-pass-123',
        'newPassword': 'new-pass-456',
      });
      expect(capturedRequest!.headers['Authorization'], 'Bearer abc-token');
    },
  );
}
