import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../services/storage_service.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final explicitAuthorization = options.headers['Authorization'];
    if (explicitAuthorization != null && explicitAuthorization.toString().isNotEmpty) {
      handler.next(options);
      return;
    }

    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Explicitly remove the header if no token is present
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isLoginRequest(err.requestOptions.path)) {
      await _storageService.clearAuthData();
      Get.offAllNamed(AppRoutes.login);
    }
    handler.next(err);
  }

  bool _isLoginRequest(String path) {
    return path.contains(ApiEndpoints.login);
  }
}
